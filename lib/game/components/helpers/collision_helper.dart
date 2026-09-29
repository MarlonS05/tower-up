import 'package:flame/components.dart';
import 'package:towerup/game/components/entities/player.dart';
import 'package:towerup/game/components/helpers/coordinates_helper.dart';
import 'package:towerup/game/components/obsticles/collision_block.dart';
import 'package:towerup/game/config/person_enums.dart';

class CollisionHelper {
  static List<MoveableDirection> getCollisionDirections(
    Vector2 intersectionPoint1,
    Vector2 intersectionPoint2,
    CollisionBlock collisionBlock,
    Player player,
  ) {
    List<MoveableDirection> unavailableDirections = [];

    final MoveableDirection intersectionPoint1Side = _getIntersectionSide(
      intersectionPoint1,
      collisionBlock,
    );
    final MoveableDirection intersectionPoint2Side = _getIntersectionSide(
      intersectionPoint2,
      collisionBlock,
    );

    bool isCollisionFinished = true;

    // Check horizontal collisions
    if (intersectionPoint1Side == MoveableDirection.left &&
        intersectionPoint2Side == MoveableDirection.left) {
      unavailableDirections.add(MoveableDirection.right);
    } else if (intersectionPoint1Side == MoveableDirection.right &&
        intersectionPoint2Side == MoveableDirection.right) {
      unavailableDirections.add(MoveableDirection.left);

      // Check vertical collisions
    } else if (intersectionPoint1Side == MoveableDirection.up &&
        intersectionPoint2Side == MoveableDirection.up) {
      unavailableDirections.add(MoveableDirection.down);
    } else if (intersectionPoint1Side == MoveableDirection.down &&
        intersectionPoint2Side == MoveableDirection.down) {
      unavailableDirections.add(MoveableDirection.up);
    } else {
      isCollisionFinished = false;
    }

    // Check for small collisionBlocks / intersections on opposite sites
    if (!isCollisionFinished &&
        intersectionPoint1Side ==
            getMoveableDirectionOpposite(intersectionPoint2Side)) {
      MoveableDirection intrudedSide = _getIntrudedSideOfSmallCollisionBlock(
        collisionBlock,
        intersectionPoint1,
        intersectionPoint2,
      );

      unavailableDirections.add(getMoveableDirectionOpposite(intrudedSide));

      isCollisionFinished = true;
    }

    // Check for intersections on different sides
    if (!isCollisionFinished) {
      // Check diagonal collisions
      Vector2 closestCorner =
          CoordinatesHelper.getClosestCornerInRectangleOfCollision(
            intersectionPoint1,
            intersectionPoint2,
            collisionBlock,
          );

      MoveableDirection moreIntrudedSide =
          _getMoreIntrudedSideOfRectangleOpposite(
            closestCorner,
            intersectionPoint1,
            getMoveableDirectionOpposite(intersectionPoint1Side),
            intersectionPoint2,
            getMoveableDirectionOpposite(intersectionPoint2Side),
          );

      unavailableDirections.add(moreIntrudedSide);
    }

    return unavailableDirections;
  }

  static MoveableDirection _getMoreIntrudedSideOfRectangleOpposite(
    Vector2 closestCorner,
    Vector2 intersectionPoint1,
    MoveableDirection intersectionPoint1Side,
    Vector2 intersectionPoint2,
    MoveableDirection intersectionPoint2Side,
  ) {
    double distanceToPoint1 = closestCorner.distanceTo(intersectionPoint1);
    double distanceToPoint2 = closestCorner.distanceTo(intersectionPoint2);

    if (distanceToPoint1 < distanceToPoint2) {
      return intersectionPoint2Side;
    } else {
      return intersectionPoint1Side;
    }
  }

  static MoveableDirection _getIntrudedSideOfSmallCollisionBlock(
    CollisionBlock collisionBlock,
    Vector2 intersectionPoint1,
    Vector2 intersectionPoint2,
  ) {
    // Get Midpoints of collisionBlock sides
    Vector2 blockLeftSideMidpoint = CoordinatesHelper.getMidpoint(
      Vector2(collisionBlock.x, collisionBlock.y),
      Vector2(collisionBlock.x, collisionBlock.y + collisionBlock.height),
    );
    Vector2 blockUpSideMidpoint = CoordinatesHelper.getMidpoint(
      Vector2(collisionBlock.x, collisionBlock.y),
      Vector2(collisionBlock.x + collisionBlock.width, collisionBlock.y),
    );
    Vector2 blockRightSideMidpoint = CoordinatesHelper.getMidpoint(
      Vector2(collisionBlock.x + collisionBlock.width, collisionBlock.y),
      Vector2(
        collisionBlock.x + collisionBlock.width,
        collisionBlock.y + collisionBlock.height,
      ),
    );
    Vector2 blockDownSideMidpoint = CoordinatesHelper.getMidpoint(
      Vector2(collisionBlock.x, collisionBlock.y + collisionBlock.height),
      Vector2(
        collisionBlock.x + collisionBlock.width,
        collisionBlock.y + collisionBlock.height,
      ),
    );

    // Get Midpoint of intersections
    Vector2 intersectionsMidpoint = CoordinatesHelper.getMidpoint(
      intersectionPoint1,
      intersectionPoint2,
    );

    // Get closest side midpoint to intersections midpoint
    final distances = <MoveableDirection, double>{
      MoveableDirection.left: blockLeftSideMidpoint.distanceTo(
        intersectionsMidpoint,
      ),
      MoveableDirection.up: blockUpSideMidpoint.distanceTo(
        intersectionsMidpoint,
      ),
      MoveableDirection.right: blockRightSideMidpoint.distanceTo(
        intersectionsMidpoint,
      ),
      MoveableDirection.down: blockDownSideMidpoint.distanceTo(
        intersectionsMidpoint,
      ),
    };

    // Get shortest distance from the lines collisions
    MoveableDirection closestSide = distances.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;

    return closestSide;
  }

  static MoveableDirection _getIntersectionSide(
    Vector2 point,
    CollisionBlock collisionBlock,
  ) {
    if (point.x == collisionBlock.x) {
      return MoveableDirection.left;
    }
    if (point.x == collisionBlock.x + collisionBlock.width) {
      return MoveableDirection.right;
    }
    if (point.y == collisionBlock.y) {
      return MoveableDirection.up;
    }
    return MoveableDirection.down;
  }
}
