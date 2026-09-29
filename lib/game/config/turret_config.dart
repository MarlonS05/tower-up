import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

class TurretConfig {

  /// Positioning
  static Vector2 size = Vector2.all(64);
  static EdgeInsets borderMargin = EdgeInsets.only(bottom: 98, right: 36);
  static Vector2 scale = Vector2.all(2);
  static Vector2 hitboxSize = Vector2.all(32);
  static Vector2 hitboxPosition = Vector2.all(0);

  /// Functionality
  static double animationCycleTime = 0.25;
  static int cooldown = 500;
}

enum TurretState { idle, shoot }
