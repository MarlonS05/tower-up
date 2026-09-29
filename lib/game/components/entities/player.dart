import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:towerup/game/components/helpers/collision_helper.dart';
import 'package:towerup/game/components/obsticles/collision_block.dart';
import 'package:towerup/game/config/person_enums.dart';
import 'package:towerup/game/config/player_config.dart';
import 'package:towerup/game/tower_up_game.dart';
import 'package:towerup/logger/logger.dart';

import '../helpers/entity_helper.dart';

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<TowerUpGame>, CollisionCallbacks {
  Player({super.position});

  double health = 100;
  DateTime lastHurt = DateTime.now();

  // Animations variables
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runXAnimation;
  late final SpriteAnimation runYUpAnimation;
  late final SpriteAnimation runYDownAnimation;
  late final SpriteAnimation deathAnimation;

  PersonDirection playerDirection = PersonDirection.none;
  bool isFacingRight = true;
  List<MoveableDirection> allowedDirections = MoveableDirection.values.toList();

  Map<CollisionBlock, List<MoveableDirection>> collisionBlocks = {};

  @override
  FutureOr<void> onLoad() {
    // Increase size on player
    scale = PlayerConfig.playerScale;

    _createHitbox();

    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);

    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is CollisionBlock) {
      List<MoveableDirection> unavailableDirections =
          CollisionHelper.getCollisionDirections(
            intersectionPoints.first,
            intersectionPoints.last,
            other,
            this,
          );

      collisionBlocks[other] = unavailableDirections;

      _updateAvailableDirections();
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    collisionBlocks.remove(other);

    _updateAvailableDirections();

    super.onCollisionEnd(other);
  }

  void _createHitbox() {
    add(
      RectangleHitbox(
        size: PlayerConfig.playerHitboxSize,
        position: PlayerConfig.playerHitboxPosition,
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnimation = EntityHelper.createAnimation(
      "player/idle.png",
      2,
      null,
      game,
      PlayerConfig.animationCycleTime,
    );
    runXAnimation = EntityHelper.createAnimation(
      "player/walk.png",
      4,
      Vector2(0, 33),
      game,
      PlayerConfig.animationCycleTime,
    );
    runYUpAnimation = EntityHelper.createAnimation(
      "player/walk.png",
      4,
      Vector2(0, 65),
      game,
      PlayerConfig.animationCycleTime,
    );
    runYDownAnimation = EntityHelper.createAnimation(
      "player/walk.png",
      4,
      null,
      game,
      PlayerConfig.animationCycleTime,
    );
    deathAnimation = EntityHelper.createAnimation(
      "player/death.png",
      3,
      Vector2(0, 33),
      game,
      PlayerConfig.animationCycleTime,
      loop: false,
    );

    // Map all animations
    animations = {
      PersonState.idle: idleAnimation,
      PersonState.runX: runXAnimation,
      PersonState.runYUp: runYUpAnimation,
      PersonState.runYDown: runYDownAnimation,
      PersonState.death: deathAnimation,
    };

    // Set starting animation
    current = PersonState.idle;
  }

  void _updatePlayerMovement(double dt) {
    if (current != PersonState.death) {
      double directionX = 0.0;
      double directionY = 0.0;

      double moveSpeed = PlayerConfig.moveSpeed;
      double diagonalMoveSpeed = PlayerConfig.diagonalMoveSpeed;

      // Calculate player movement, through direction
      switch (playerDirection) {
        case PersonDirection.left:
          directionX -= moveSpeed;
          if (isFacingRight) {
            isFacingRight = false;
            flipHorizontallyAroundCenter();
          }
          current = PersonState.runX;
          break;
        case PersonDirection.topLeft:
          directionX -= diagonalMoveSpeed;
          directionY -= diagonalMoveSpeed;
          current = PersonState.runYUp;
          break;
        case PersonDirection.top:
          directionY -= moveSpeed;
          current = PersonState.runYUp;
          break;
        case PersonDirection.topRight:
          directionX += diagonalMoveSpeed;
          directionY -= diagonalMoveSpeed;
          current = PersonState.runYUp;
          break;
        case PersonDirection.right:
          if (!isFacingRight) {
            isFacingRight = true;
            flipHorizontallyAroundCenter();
          }
          directionX += moveSpeed;
          current = PersonState.runX;
          break;
        case PersonDirection.bottomRight:
          directionX += diagonalMoveSpeed;
          directionY += diagonalMoveSpeed;
          current = PersonState.runYDown;
          break;
        case PersonDirection.bottom:
          directionY += moveSpeed;
          current = PersonState.runYDown;
          break;
        case PersonDirection.bottomLeft:
          directionX -= diagonalMoveSpeed;
          directionY += diagonalMoveSpeed;
          current = PersonState.runYDown;
          break;
        case PersonDirection.none:
          current = PersonState.idle;
          break;
      }

      // Check if directions are allowed
      if (!allowedDirections.contains(MoveableDirection.left) && directionX < 0)
        directionX = 0;
      if (!allowedDirections.contains(MoveableDirection.right) &&
          directionX > 0)
        directionX = 0;
      if (!allowedDirections.contains(MoveableDirection.up) && directionY < 0)
        directionY = 0;
      if (!allowedDirections.contains(MoveableDirection.down) && directionY > 0)
        directionY = 0;

      Vector2 velocity = Vector2(directionX, directionY);
      position += velocity * dt;
    }
  }

  // Check collisionBlocks Map for forbidden directions
  void _updateAvailableDirections() {
    List<MoveableDirection> allowedDirectionsLocal = MoveableDirection.values
        .toList();
    Iterable<MoveableDirection> forbiddenDirections = collisionBlocks.values
        .expand((directions) => directions);

    allowedDirectionsLocal.removeWhere(forbiddenDirections.toSet().contains);

    allowedDirections = allowedDirectionsLocal;
  }

  void hurtPlayer(double damage) {
    DateTime hurtThreshold = DateTime.now().subtract(
      Duration(milliseconds: PlayerConfig.hurtCooldown),
    );
    if (lastHurt.isBefore(hurtThreshold)) {
      lastHurt = DateTime.now();
      health -= damage;
    }

    if (health <= 0) {
      logger.d("died");
      current = PersonState.death;
      allowedDirections.clear();
    }
  }
}
