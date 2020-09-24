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
  BirdManager(this.spriteImage, this.spriteBat) : super();

  Image spriteImage;
  Image spriteBat;

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
          (size.width / 2 - lastBird.flyingBird.x) > lastBird.birdGap) {
        addBird();
      }
    } else {
      addBird();
    }
  }

  void addBird() {
    final bird = Bird(spriteImage, spriteBat);
    bird.flyingBird.x = size.width + BirdConfig.width + 10;
    bird.flyingBird.y =
        (y / 2 - (BirdConfig.maxSkyLevel - BirdConfig.minSkyLevel)) +
            getRandomNum(BirdConfig.minSkyLevel, BirdConfig.maxSkyLevel);
    components.add(bird);
  }

  void reset() {
    components.clear();
  }
}

class Bird extends PositionComponent with Resizable {
  Bird(Image spriteImage, Image spriteBat)
      : birdGap = getRandomNum(BirdConfig.minBirdGap, BirdConfig.maxBirdGap),
        flyingBird = FlyingBird(spriteImage),
        super();

  FlyingBird flyingBird;
  PositionComponent get position {
    return flyingBird;
  }

  final double birdGap;
  bool toRemove = false;

  void updateWithSpeed(double t, double speed) {
    if (toRemove) {
      return;
    }

    position.x -= speed.ceil() * 50 * t;

    if (!isVisible) {
      toRemove = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    //ninjada burası null gelmiyor, burası null geldiği için kapattım - araştır neden null
    // if (size == null) {
    //   return;
    // }

    position.render(c);
  }

  @override
  bool destroy() {
    return toRemove;
  }

  bool get isVisible {
    return position.x + BirdConfig.width > 0;
  }

  @override
  void resize(Size size) {
    super.resize(size);
    position.y =
        (position.y / 2 - (BirdConfig.maxSkyLevel - BirdConfig.minSkyLevel)) +
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
                height: BirdConfig.height,
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

class FlyingBat extends AnimationComponent {
  FlyingBat(Image spriteBat)
      : super(
          BatConfig.width,
          BatConfig.height,
          Animation.spriteList(
            [
              Sprite.fromImage(
                spriteBat,
                width: 125,
                height: 95,
                x: 29.0,
                y: 6.0,
              ),
              Sprite.fromImage(
                spriteBat,
                width: 134,
                height: 95,
                x: 192.0,
                y: 8.0,
              ),
              Sprite.fromImage(
                spriteBat,
                width: 147,
                height: 95,
                x: 349.0,
                y: 8.0,
              ),
              Sprite.fromImage(
                spriteBat,
                width: 165,
                height: 95,
                x: 5.0,
                y: 104.0,
              ),
              Sprite.fromImage(
                spriteBat,
                width: 145,
                height: 95,
                x: 178.0,
                y: 112.0,
              ),
              Sprite.fromImage(
                spriteBat,
                width: 170,
                height: 99,
                x: 337.0,
                y: 112.0,
              ),
            ],
            stepTime: 0.2,
            loop: true,
          ),
        );
}
