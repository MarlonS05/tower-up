import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:towerup/game/components/entities/player.dart';
import 'package:towerup/game/config/person_enums.dart';
import 'package:towerup/game/config/setup_config.dart';

JoystickComponent createJoystick(Images images) {
  JoystickComponent joystick = JoystickComponent(
    knob: SpriteComponent(
      sprite: Sprite(images.fromCache("HUD/knob.png")),
      size: Vector2.all(SetupConfig.joystickKnobSize),
    ),
    background: SpriteComponent(
      sprite: Sprite(images.fromCache("HUD/background.png")),
      size: Vector2.all(SetupConfig.joystickBackgroundSize),
    ),
    margin: SetupConfig.joystickMargin,
  );

  return joystick;
}

Player updateJoystick(JoystickComponent joystick, Player player) {
  switch (joystick.direction) {
    case JoystickDirection.up:
      player.playerDirection = PersonDirection.top;
      break;
    case JoystickDirection.upRight:
      player.playerDirection = PersonDirection.topRight;
      break;
    case JoystickDirection.right:
      player.playerDirection = PersonDirection.right;
      break;
    case JoystickDirection.downRight:
      player.playerDirection = PersonDirection.bottomRight;
      break;
    case JoystickDirection.down:
      player.playerDirection = PersonDirection.bottom;
      break;
    case JoystickDirection.downLeft:
      player.playerDirection = PersonDirection.bottomLeft;
      break;
    case JoystickDirection.left:
      player.playerDirection = PersonDirection.left;
      break;
    case JoystickDirection.upLeft:
      player.playerDirection = PersonDirection.topLeft;
      break;
    default:
      player.playerDirection = PersonDirection.none;
      break;
  }

  return player;
}