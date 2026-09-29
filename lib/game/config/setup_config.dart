import 'package:flutter/material.dart';
import 'package:towerup/game/config/levels_config.dart';

class SetupConfig {
  static Color backgroundColor = Colors.white24;
  static double cameraWidth = 512;
  static double cameraHeight = 800;
  static double joystickKnobSize = 48;
  static double joystickBackgroundSize = 124;
  static EdgeInsets joystickMargin = const EdgeInsets.only(left: 60, bottom: 40);
  static String startLevel = LevelsConfig.level1;
}