import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:towerup/game/components/entities/player.dart';
import 'package:towerup/game/components/inputs/buttons.dart';
import 'package:towerup/game/components/inputs/joystick.dart';
import 'package:towerup/game/components/level.dart';
import 'package:towerup/game/components/placeables/turret.dart';
import 'package:towerup/game/config/setup_config.dart';

class TowerUpGame extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => SetupConfig.backgroundColor;

  Player player = Player();

  late JoystickComponent joystick;
  late HudButtonComponent turretButton;

  late final CameraComponent cameraComponent;

  int test = 0; // TODO: testing var, remove later

  @override
  FutureOr<void> onLoad() async {
    // Load images into cache
    await images.loadAllImages();

    // Create the world
    final world = Level(levelName: SetupConfig.startLevel, player: player);

    // Add camera and game screen size
    cameraComponent = CameraComponent.withFixedResolution(
      world: world,
      width: SetupConfig.cameraWidth,
      height: SetupConfig.cameraHeight,
    );

    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([world, cameraComponent]);

    joystick = createJoystick(images);
    add(joystick);
    turretButton = createTurretButton(images);
    turretButton.onPressed = () {
      test++; // TODO: remove after testing
      if (test < 3) {
        Turret newTurret = turretButtonPressed(turretButton.position);
        add(newTurret);
      }
    };
    add(turretButton);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    player = updateJoystick(joystick, player);

    super.update(dt);
  }


}
