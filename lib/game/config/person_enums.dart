enum PersonState { idle, runX, runYUp, runYDown, death }

enum PersonDirection {
  left,
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  none,
}

enum MoveableDirection { left, up, right, down }

MoveableDirection getMoveableDirectionOpposite(MoveableDirection direction) {
  switch (direction) {
    case MoveableDirection.left:
      return MoveableDirection.right;
    case MoveableDirection.up:
      return MoveableDirection.down;
    case MoveableDirection.right:
      return MoveableDirection.left;
    case MoveableDirection.down:
      return MoveableDirection.up;
  }
}
