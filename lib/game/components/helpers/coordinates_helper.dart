import 'package:flame/components.dart';
import 'package:towerup/game/components/obsticles/collision_block.dart';

class CoordinatesHelper {
  /// Helper
  static Vector2 getMidpoint(Vector2 point1, Vector2 point2) {
    double x = (point1.x + point2.x) / 2;
    double y = (point1.y + point2.y) / 2;

    return Vector2(x, y);
  }

  static Vector2 getClosestCornerInRectangleOfCollision(
    Vector2 intersectionPoint1,
    Vector2 intersectionPoint2,
    CollisionBlock collisionBlock,
  ) {
    // Get the corners of the rectangle
    Vector2 topLeftCorner = Vector2(collisionBlock.x, collisionBlock.y);
    final Vector2 topRightCorner = Vector2(
      collisionBlock.x + collisionBlock.width,
      collisionBlock.y,
    );
    final Vector2 bottomLeftCorner = Vector2(
      collisionBlock.x,
      collisionBlock.y + collisionBlock.height,
    );
    final Vector2 bottomRightCorner = Vector2(
      collisionBlock.x + collisionBlock.width,
      collisionBlock.y + collisionBlock.height,
    );

    // GetMidpoint of intersections
    Vector2 intersectionsMidpoint = CoordinatesHelper.getMidpoint(
      intersectionPoint1,
      intersectionPoint2,
    );

    // Get closest corner to midpoint
    final distances = <Vector2, double>{
      for (final point in [
        topLeftCorner,
        topRightCorner,
        bottomLeftCorner,
        bottomRightCorner,
      ].whereType<Vector2>())
        point: point.distanceTo(intersectionsMidpoint),
    };

    // Get shortest distance from the lines collisions
    Vector2 closestCorner = distances.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;

    return closestCorner;
  }
}
