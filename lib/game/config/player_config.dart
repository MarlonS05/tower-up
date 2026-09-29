import 'package:flame/components.dart';

class PlayerConfig {
  static Vector2 playerScale =  Vector2.all(2);
  static Vector2 playerHitboxSize = Vector2(12, 14);
  static Vector2 playerHitboxPosition = Vector2(10, 9);
  static double moveSpeed = 180;
  static double diagonalMoveSpeedDivider = 1.4;
  static double diagonalMoveSpeed = moveSpeed / diagonalMoveSpeedDivider;
  static double animationCycleTime = 0.25;
  static int hurtCooldown = 500;
}
