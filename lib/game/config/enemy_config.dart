import 'package:flame/components.dart';

class EnemyConfig {
  static int baseEnemyScale = 2;
  static Vector2 baseEnemyHitboxSize = Vector2(12, 14);
  static Vector2 baseEnemyHitboxPosition = Vector2(10, 9);
  static double baseEnemyMoveSpeed = 30;
  static double baseEnemyDiagonalMoveSpeed =
      baseEnemyMoveSpeed / diagonalMoveSpeedDivider;
  static double animationCycleTime = 0.5;
  static double diagonalMoveSpeedDivider = 1.4;

}
