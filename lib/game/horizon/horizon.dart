import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flappy_bat/game/horizon/horizon_line.dart';

class Horizon extends PositionComponent
    with Resizable, HasGameRef, Tapable, ComposedComponent {
  Horizon(Image spriteImage, Image spriteBat) {
    horizonLine = HorizonLine(spriteImage, spriteBat);
    add(horizonLine);
  }

  HorizonLine horizonLine;

  @override
  void update(double t) {
    horizonLine.y = y;
    super.update(t);
  }

  void updateWithSpeed(double t, double speed) {
    if (size == null) {
      return;
    }

    y = (size.height / 2) + 21.0;

    for (final c in components) {
      final positionComponent = c as PositionComponent;
      positionComponent.y = y;
    }

    horizonLine.updateWithSpeed(t, speed);
    super.update(t);
  }

  void reset() {
    horizonLine.reset();
  }
}
