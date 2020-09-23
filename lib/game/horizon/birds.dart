import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/sprite.dart';
import 'package:flappy_bat/game/custom/util.dart';
import 'package:flappy_bat/game/horizon/config.dart';

class BirdManager extends PositionComponent
    with HasGameRef, Tapable, ComposedComponent, Resizable {
  BirdManager(this.spriteImage) : super();

  Image spriteImage;

  void updateWithSpeed(double t, double speed) {
    final double birdSpeed = HorizonConfig.bgBirdSpeed / 1000 * t * speed;
    final int numBirds = components.length;

    if (numBirds > 0) {
      for (final c in components) {
        final bird = c as Bird;
        bird.updateWithSpeed(t, birdSpeed);
      }

      final lastBird = components.last as Bird;
      if (numBirds < HorizonConfig.maxBirds &&
          (size.width / 2 - lastBird.x) > lastBird.birdGap) {
        addBird();
      }
    } else {
      addBird();
    }
  }

  void addBird() {
    final bird = Bird(spriteImage);
    bird.x = size.width + BirdConfig.width + 10;
    bird.y = (y / 2 - (BirdConfig.maxSkyLevel - BirdConfig.minSkyLevel)) +
        getRandomNum(BirdConfig.minSkyLevel, BirdConfig.maxSkyLevel);
    components.add(bird);
  }

  void reset() {
    components.clear();
  }
}

// class Bird extends AnimationComponent {
//   Bird(Image spriteImage)
//       : super(
//           BirdConfig.width,
//           BirdConfig.height,
//           Animation.spriteList(
//             [
//               Sprite.fromImage(
//                 spriteImage,
//                 width: BirdConfig.width,
//                 height: BirdConfig.width,
//                 x: 260.0,
//                 y: 14.0,
//               ),
//               Sprite.fromImage(
//                 spriteImage,
//                 width: BirdConfig.width,
//                 height: 59,
//                 x: 352.0,
//                 y: 2.0,
//               ),
//             ],
//           ),
//         );

// class Bird extends SpriteComponent with Resizable {
//   Bird(Image spriteImage)
//       : birdGap = getRandomNum(BirdConfig.minBirdGap, BirdConfig.maxBirdGap),
//         super.fromSprite(
//           BirdConfig.width,
//           BirdConfig.height,
//           Sprite.fromImage(
//             spriteImage,
//             width: BirdConfig.width,
//             height: BirdConfig.width,
//             x: 260.0,
//             y: 14.0,
//           ),
//         );

class Bird extends SpriteComponent with Resizable {
  Bird(Image spriteImage)
      : birdGap = getRandomNum(BirdConfig.minBirdGap, BirdConfig.maxBirdGap),
        flyingBird = FlyingBird(spriteImage),
        super();

  FlyingBird flyingBird;

  final double birdGap;
  bool toRemove = false;

  void updateWithSpeed(double t, double speed) {
    if (toRemove) {
      return;
    }

    x -= speed.ceil() * 50 * t;

    if (!isVisible) {
      toRemove = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    flyingBird.x = x;
    flyingBird.y = y;
    flyingBird.update(dt);
  }

  @override
  void render(Canvas c) {
    if (size == null) {
      return;
    }
    flyingBird.render(c);
  }

  @override
  bool destroy() {
    return toRemove;
  }

  bool get isVisible {
    return x + BirdConfig.width > 0;
  }

  @override
  void resize(Size size) {
    y = (y / 2 - (BirdConfig.maxSkyLevel - BirdConfig.minSkyLevel)) +
        getRandomNum(BirdConfig.minSkyLevel, BirdConfig.maxSkyLevel);
  }
}

class FlyingBird extends AnimationComponent {
  FlyingBird(Image spriteImage)
      : super(
          BirdConfig.width,
          BirdConfig.height,
          Animation.spriteList(
            [
              Sprite.fromImage(
                spriteImage,
                width: BirdConfig.width,
                height: BirdConfig.width,
                x: 260.0,
                y: 14.0,
              ),
              Sprite.fromImage(
                spriteImage,
                width: BirdConfig.width,
                height: 59,
                x: 352.0,
                y: 2.0,
              ),
            ],
            stepTime: 0.2,
            loop: true,
          ),
        );
}
