import 'package:flame/components.dart';
import 'package:towerup/game/tower_up_game.dart';

class EntityHelper {
  static SpriteAnimation createAnimation(
    String imgPath,
    int amount,
    Vector2? texturePosition,
    TowerUpGame game,
    double cycleTime, {
    bool loop = true,
    int? amountPerRow = null,
  }) {
    double stepTime = cycleTime / amount;
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(imgPath),
      SpriteAnimationData.sequenced(
        amount: amount,
        amountPerRow: amountPerRow,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        texturePosition: texturePosition,
        // for different directions
        loop: loop,
      ),
    );
  }
}
