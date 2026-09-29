import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:towerup/game/components/entities/player.dart';
import 'package:towerup/game/components/obsticles/collision_block.dart';
import 'package:towerup/game/config/levels_config.dart';

class Level extends World with HasCollisionDetection {
  Level({required this.levelName, required this.player});

  final String levelName;
  final Player player;
  late TiledComponent level;
  Map<String, Vector2> spawnPoints = {};
  List<CollisionBlock> collisionBlocks = [];
  List<Vector2> pathWaypoints = [];

  @override
  FutureOr<void> onLoad() async {
    await _loadLevel();

    _loadSpawnpoints();

    _loadCollisions();

    _loadPathWaypoints();

    return super.onLoad();
  }

  /// Loads the level from the Tiled map and adds it to the world.
  Future<void> _loadLevel() async {
    level = await TiledComponent.load("$levelName.tmx", LevelsConfig.tileSize);

    add(level);
  }

  /// Loads Spawnpoints from map spawnpoints layer and sets the player position accordingly.
  void _loadSpawnpoints() {
    final ObjectGroup? spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>(
      "spawnpoints",
    );

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case "Player":
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case "Enemy":
            spawnPoints["Enemy"] = Vector2(spawnPoint.x, spawnPoint.y);
            break;
        }
      }
    }
  }

  /// Loads Collisions from map collisions layer and adds them to the world.
  void _loadCollisions() {
    final ObjectGroup? collisionsLayer = level.tileMap.getLayer<ObjectGroup>(
      "collisions",
    );
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        final collisionBlock = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
        );

        collisionBlocks.add(collisionBlock);
        add(collisionBlock);
      }
    }
  }

  /// Loads Path waypoints from map path waypoints layer and adds them to the world.
  void _loadPathWaypoints() {
    final ObjectGroup? waypointsLayer = level.tileMap.getLayer<ObjectGroup>(
      "path waypoints",
    );
    if (waypointsLayer != null) {
      for (final waypoint in waypointsLayer.objects) {
        final waypointVector = Vector2(waypoint.x, waypoint.y);

        pathWaypoints.add(waypointVector);
      }
    }
  }
}
