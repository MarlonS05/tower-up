import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:towerup/game/config/person_enums.dart';
import 'package:towerup/game/config/turret_config.dart';
import 'package:towerup/game/tower_up_game.dart';

import '../helpers/entity_helper.dart';

class Turret extends SpriteAnimationGroupComponent
    with HasGameReference<TowerUpGame>, DragCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation shootAnimation;
  PersonDirection enemyDirection = PersonDirection.none;

  @override
  FutureOr<void> onLoad() {
    priority = 10;

    debugMode = true;
    // Increase size on enemy
    scale = TurretConfig.scale;

    _createHitbox();

    _loadAllAnimations();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) { // TODO: figure out how to start drag when turret button is pressed
    position += event.deviceDelta;
    super.onDragUpdate(event);
  }

  void _loadAllAnimations() {
    idleAnimation = EntityHelper.createAnimation(
      "turret/face.png",
      1,
      null,
      game,
      TurretConfig.animationCycleTime,
    );
    shootAnimation = EntityHelper.createAnimation(
      "turret/face.png",
      10,
      amountPerRow: 1,
      Vector2(0, 33),
      game,
      TurretConfig.animationCycleTime,
      loop: false,
    );

    // Map all animations
    animations = {
      TurretState.idle: idleAnimation,
      TurretState.shoot: shootAnimation,
    };

    // Set starting animation
    current = TurretState.idle;
  }

  void _createHitbox() {
    add(
      RectangleHitbox(
        size: TurretConfig.hitboxSize,
        position: TurretConfig.hitboxPosition,
      ),
    );
  }
}
