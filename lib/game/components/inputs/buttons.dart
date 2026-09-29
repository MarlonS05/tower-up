import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:towerup/game/components/placeables/turret.dart';
import 'package:towerup/game/config/turret_config.dart';

HudButtonComponent createTurretButton(Images images) {
  SpriteComponent button = SpriteComponent(
    sprite: Sprite(images.fromCache("HUD/turret.png")),
    size: TurretConfig.size,
  );
  HudButtonComponent hudButton = HudButtonComponent(
    button: button,
    margin: TurretConfig.borderMargin,
    priority: 9,
  );

  return hudButton;
}

Turret turretButtonPressed(Vector2 buttonPosition) {
  Turret turret = Turret()
    ..position = buttonPosition
    ..anchor = Anchor.topLeft;

  return turret;
}