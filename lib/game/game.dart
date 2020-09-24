import 'dart:ui' as ui;

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flappy_bat/game/audio/audio.dart';
import 'package:flappy_bat/game/collision/collision_utils.dart';
import 'package:flappy_bat/game/game_config.dart';
import 'package:flappy_bat/game/game_over/game_over.dart';
import 'package:flappy_bat/game/horizon/horizon.dart';
import 'package:flappy_bat/game/ninja/ninja.dart';
import 'package:flappy_bat/game/ninja/ninja_config.dart';
import 'package:flappy_bat/game/score/score.dart';
import 'package:flutter/material.dart';

class Background extends Component with Resizable {
  Background(this.game) {
    try {
      bgSprite = Sprite("mounth.png");
    } catch (e) {
      print(e.toString());
    }
  }

  Sprite bgSprite;
  Rect bgRect;
  final Game game;

  // final Paint _paint = Paint()..color = Colors.red;

  @override
  void render(Canvas c) {
    bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    bgSprite.renderRect(c, bgRect);

    // final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // c.drawRect(rect, _paint);
  }

  @override
  void update(double t) {}
}

enum GameStatus { playing, waiting, gameOver }

class Game extends BaseGame with MultiTouchTapDetector, HasTapableComponents {
  Game({ui.Image spriteImage, ui.Image spriteBat}) {
    ninja = Ninja(spriteImage, spriteBat);
    horizon = Horizon(spriteImage, spriteBat);
    score = Score(spriteImage);
    gameOverPanel = GameOverPanel(spriteImage);

    this
      ..add(Background(this))
      ..add(horizon)
      ..add(ninja)
      ..add(gameOverPanel)
      ..add(score);
  }

  Ninja ninja;
  Horizon horizon;
  Score score;
  GameOverPanel gameOverPanel;
  GameStatus status = GameStatus.waiting;

  double currentSpeed = GameConfig.speed;
  double timePlaying = 0.0;

  @override
  void onTapDown(_, __) {
    onAction();
  }

  void onAction() {
    if (gameOver) {
      restart();
      return;
    }

    ninja.startJump(currentSpeed);
  }

  @override
  void update(double t) {
    super.update(t);

    ninja.update(t);
    horizon.updateWithSpeed(0.0, currentSpeed);

    if (gameOver) {
      return;
    }

    if (ninja.playingIntro) {
      if (ninja.x >= NinjaConfig.startXPos) {
        startGame();
      } else {
        horizon.updateWithSpeed(0.0, currentSpeed);
      }
    }

    if (playing) {
      timePlaying += t;
      horizon.updateWithSpeed(t, currentSpeed);
      score.updateScore(timePlaying);

      final obstacles = horizon.horizonLine.obstacleManager.components;
      final hasCollision =
          obstacles.isNotEmpty && checkForCollision(obstacles.first, ninja);

      if (hasCollision) {
        doGameOver();
      } else {
        if (currentSpeed < GameConfig.maxSpeed) {
          currentSpeed += GameConfig.acceleration;
        }
      }
    }
  }

  void startGame() {
    ninja.status = NinjaStatus.running;
    status = GameStatus.playing;
    ninja.hasPlayedIntro = true;
    timePlaying = 0;
    Audio.loopBGM();
    Audio.playNewStart();
  }

  bool get playing => status == GameStatus.playing;
  bool get gameOver => status == GameStatus.gameOver;

  void doGameOver() {
    gameOverPanel.visible = true;
    status = GameStatus.gameOver;
    ninja.status = NinjaStatus.crashed;
    timePlaying = 0;
    Audio.playCrashed();
  }

  void restart() {
    status = GameStatus.playing;
    ninja.reset();
    horizon.reset();
    timePlaying = 0;
    currentSpeed = GameConfig.speed;
    gameOverPanel.visible = false;
    Audio.playNewStart();
  }
}
