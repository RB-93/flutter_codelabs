// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../doodle_dash.dart';
// Core gameplay: Import sprites.dart

enum PlayerState {
  left,
  right,
  center,
  rocket,
  nooglerCenter,
  nooglerLeft,
  nooglerRight
}

class Player extends SpriteGroupComponent<PlayerState>
    with HasGameRef<DoodleDash>, KeyboardHandler, CollisionCallbacks {
  Player({
    super.position,
    required this.character,
    this.jumpSpeed = 600,
  }) : super(
          size: Vector2(79, 109),
          anchor: Anchor.center,
          priority: 1,
        );

  int _hAxisInput = 0;
  final int movingLeftInput = -1;
  final int movingRightInput = 1;
  Vector2 _velocity = Vector2.zero();
  bool get isMovingDown => _velocity.y > 0;
  Character character;
  double jumpSpeed;
  // Core gameplay: Add _gravity property

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Core gameplay: Add circle hitbox to Dash

    // Add a Player to the game: loadCharacterSprites
    await _loadCharacterSprites();
    // Add a Player to the game: Default Dash onLoad to center state
    current = PlayerState.center;
  }

  @override
  void update(double dt) {
    // Add a Player to the game: Add game state check
    if (gameRef.gameManager.isIntro || gameRef.gameManager.isGameOver) return;

    // Add a Player to the game: Add calcualtion for Dash's horizontal velocity
    _velocity.x = _hAxisInput * jumpSpeed;

    final double dashHorizontalCenter = size.x / 2;

    // Add a Player to the game: Add infinite side boundaries logic
    if (position.x < dashHorizontalCenter) {
      position.x = gameRef.size.x - (dashHorizontalCenter);
    }
    if (position.x > gameRef.size.x - (dashHorizontalCenter)) {
      position.x = dashHorizontalCenter;
    }

    // Core gameplay: Add gravity

    // Add a Player to the game: Calculate Dash's current position based on
    // her velocity over elapsed time since last update cycle
    position += _velocity * dt;
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    // Add a Player to the game: Add keypress logic
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      moveLeft();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveRight();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      // jump();
    }
    return true;
  }

  void moveLeft() {
    _hAxisInput = 0;

    // Add a Player to the game: Add logic for moving left
    current = PlayerState.left;

    _hAxisInput += movingLeftInput;
  }

  void moveRight() {
    _hAxisInput = 0;

    // Add a Player to the game: Add logic for moving right
    current = PlayerState.right;

    _hAxisInput += movingRightInput;
  }

  void resetDirection() {
    _hAxisInput = 0;
  }

  // Powerups: Add hasPowerup getter

  // Powerups: Add isInvincible getter

  // Powerups: Add isWearingHat getter

  // Core gameplay: Override onCollision callback

  // Core gameplay: Add a jump method

  void _removePowerupAfterTime(int ms) {
    Future.delayed(Duration(milliseconds: ms), () {
      current = PlayerState.center;
    });
  }

  void setJumpSpeed(double newJumpSpeed) {
    jumpSpeed = newJumpSpeed;
  }

  void reset() {
    _velocity = Vector2.zero();
    current = PlayerState.center;
  }

  void resetPosition() {
    position = Vector2(
      (gameRef.size.x - size.x) / 2,
      (gameRef.size.y - size.y) / 2,
    );
  }

  Future<void> _loadCharacterSprites() async {
    // Load & configure sprite assets
    final left = await gameRef.loadSprite('game/${character.name}_left.png');
    final right = await gameRef.loadSprite('game/${character.name}_right.png');
    final center =
        await gameRef.loadSprite('game/${character.name}_center.png');
    final rocket = await gameRef.loadSprite('game/rocket_4.png');
    final nooglerCenter =
        await gameRef.loadSprite('game/${character.name}_hat_center.png');
    final nooglerLeft =
        await gameRef.loadSprite('game/${character.name}_hat_left.png');
    final nooglerRight =
        await gameRef.loadSprite('game/${character.name}_hat_right.png');

    sprites = <PlayerState, Sprite>{
      PlayerState.left: left,
      PlayerState.right: right,
      PlayerState.center: center,
      PlayerState.rocket: rocket,
      PlayerState.nooglerCenter: nooglerCenter,
      PlayerState.nooglerLeft: nooglerLeft,
      PlayerState.nooglerRight: nooglerRight,
    };
  }
}
