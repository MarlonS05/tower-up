import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:towerup/game/tower_up_game.dart';
import 'package:towerup/logger/logger.dart';

void main() async {
  // Mobile framing and init
  WidgetsFlutterBinding.ensureInitialized();
  logger.i('Starting Tower Up');
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();


  TowerUpGame game = TowerUpGame();

  // Make game reset after restart for testing
  runApp(GameWidget(game: kDebugMode ? TowerUpGame() : game));
}