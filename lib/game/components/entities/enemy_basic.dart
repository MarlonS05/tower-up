import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:towerup/game/components/entities/player.dart';
import 'package:towerup/game/config/enemy_config.dart';
import 'package:towerup/game/config/person_enums.dart';
import 'package:towerup/game/tower_up_game.dart';
import 'package:towerup/logger/logger.dart';

import '../helpers/entity_helper.dart';

class EnemyBasic extends SpriteAnimationGroupComponent
    with HasGameReference<TowerUpGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runXAnimation;
  late final SpriteAnimation runYUpAnimation;
  late final SpriteAnimation runYDownAnimation;
  PersonDirection enemyDirection = PersonDirection.none;
  bool isFacingRight = true;
  List<Vector2> waypoints = [];

  EnemyBasic(this.waypoints);

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    // Increase size on enemy
    scale = Vector2.all(EnemyConfig.baseEnemyScale.toDouble());

    _createHitbox();

    _loadAllAnimations();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _checkDirectionToNextWaypoint();
    _updateMovement(dt);

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.hurtPlayer(80);
    }

    super.onCollision(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    String imgPath = "enemy/walk.png";
    idleAnimation = EntityHelper.createAnimation(
      "enemy/idle.png",
      4,
      null,
      game,
      EnemyConfig.animationCycleTime,
    );
    runXAnimation = EntityHelper.createAnimation(
      imgPath,
      2,
      Vector2(0, 33),
      game,
      EnemyConfig.animationCycleTime,
    );
    runYUpAnimation = EntityHelper.createAnimation(
      imgPath,
      2,
      Vector2(0, 65),
      game,
      EnemyConfig.animationCycleTime,
    );
    runYDownAnimation = EntityHelper.createAnimation(
      imgPath,
      2,
      null,
      game,
      EnemyConfig.animationCycleTime,
    );

    // Map all animations
    animations = {
      PersonState.idle: idleAnimation,
      PersonState.runX: runXAnimation,
      PersonState.runYUp: runYUpAnimation,
      PersonState.runYDown: runYDownAnimation,
    };

    // Set starting animation
    current = PersonState.idle;
  }

  void _createHitbox() {
    add(
      RectangleHitbox(
        size: EnemyConfig.baseEnemyHitboxSize,
        position: EnemyConfig.baseEnemyHitboxPosition,
      ),
    );
  }

  void _updateMovement(double dt) {
    double directionX = 0.0;
    double directionY = 0.0;

    double moveSpeed = EnemyConfig.baseEnemyMoveSpeed;
    double diagonalMoveSpeed = EnemyConfig.baseEnemyDiagonalMoveSpeed;

    // Calculate enemy movement, through direction
    switch (enemyDirection) {
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

    Vector2 velocity = Vector2(directionX, directionY);
    position += velocity * dt;
  }

  void _checkDirectionToNextWaypoint() {
    if (waypoints.isEmpty) {
      enemyDirection = PersonDirection.none;
      return;
    }

    Vector2 nextWaypoint = waypoints.first;

    int enemyX = isFacingRight ? position.x.floor() : position.x.floor() - EnemyConfig.baseEnemyScale * width.toInt();
    int enemyY = position.y.floor();

    int waypointX = nextWaypoint.x.floor();
    int waypointY = nextWaypoint.y.floor();

    // Check direction to next waypoint
    if (waypointX < enemyX) {
      enemyDirection = PersonDirection.left;
    } else if (waypointY < enemyY) {
      enemyDirection = PersonDirection.top;
    } else if (waypointX > enemyX) {
      enemyDirection = PersonDirection.right;
    } else if (waypointY > enemyY) {
      enemyDirection = PersonDirection.bottom;
    } else {
      logger.d("hit waypoint");
      // Reached the waypoint, remove it from the list
      waypoints.removeAt(0);
      enemyDirection = PersonDirection.left;
    }
  }
}
