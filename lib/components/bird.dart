import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/neural_network.dart';

final class Bird extends Equatable {
  // Static image handling
  static ui.Image? _birdImage;
  static bool _isLoading = false;

  static Future<void> loadAssets(ImageProvider provider) async {
    if (_birdImage != null) return;
    if (_isLoading) return;
    
    _isLoading = true;
    dev.log('Loading bird image...');
    
    try {
      final completer = Completer<ui.Image>();
      final stream = provider.resolve(ImageConfiguration.empty);
      
      final listener = ImageStreamListener((info, _) {
        completer.complete(info.image);
        dev.log('Bird image loaded successfully');
      });
      
      stream.addListener(listener);
      _birdImage = await completer.future;
      stream.removeListener(listener);
    } catch (e) {
      dev.log('Error loading bird image: $e');
    } finally {
      _isLoading = false;
    }
  }

  // Bird properties
  final double x;
  final double y;
  final double velocity;
  final bool isDead;
  final int score;
  final NeuralNetwork? brain;

  // Physics constants
  static const double gravity = 0.8;
  static const double jumpForce = -12.0;
  static const double birdWidth = 34.0;
  static const double birdHeight = 24.0;

  const Bird({
    required this.x,
    required this.y,
    this.velocity = 0,
    this.isDead = false,
    this.score = 0,
    this.brain,
  });

  Bird copyWith({
    double? x,
    double? y,
    double? velocity,
    bool? isDead,
    int? score,
    NeuralNetwork? brain,
  }) {
    return Bird(
      x: x ?? this.x,
      y: y ?? this.y,
      velocity: velocity ?? this.velocity,
      isDead: isDead ?? this.isDead,
      score: score ?? this.score,
      brain: brain ?? this.brain,
    );
  }

  Bird update() {
    if (isDead) return this;
    
    final newVelocity = velocity + gravity;
    return copyWith(
      velocity: newVelocity,
      y: y + newVelocity,
    );
  }

  Bird think(List<double> inputs) {
    if (brain == null || isDead) return this;
    
    final outputs = brain!.feedForward(inputs);
    if (outputs[0] > 0.5) {
      return jump();
    }
    return this;
  }

  Bird jump() {
    if (isDead) return this;
    return copyWith(velocity: jumpForce);
  }

  void draw(Canvas canvas) {
    if (isDead) return;

    if (_birdImage == null) {
      dev.log('Bird image not loaded, attempting to load...');
      loadAssets(const AssetImage('assets/images/bird.png'));
      // Draw placeholder until image loads
      final placeholder = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), birdHeight / 2, placeholder);
      return;
    }

    canvas.save();
    // Rotate the bird based on velocity (clamped to avoid extreme angles)
    final rotation = (velocity * 0.04).clamp(-0.8, 0.8);
    canvas.translate(x, y);
    canvas.rotate(rotation);
    canvas.translate(-x, -y);
    
    canvas.drawImageRect(
      _birdImage!,
      Rect.fromLTWH(0, 0, _birdImage!.width.toDouble(), _birdImage!.height.toDouble()),
      Rect.fromCenter(center: Offset(x, y), width: birdWidth, height: birdHeight),
      Paint(),
    );
    canvas.restore();
  }

  bool checkCollision(Rect obstacle) {
    if (isDead) return false;

    final birdRect = Rect.fromCenter(
      center: Offset(x, y),
      width: birdWidth - 4, // Slightly smaller for better gameplay
      height: birdHeight - 4,
    );

    final collided = birdRect.overlaps(obstacle);
    if (collided) {
      dev.log('Bird collision at (${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})');
    }
    return collided;
  }

  Bird die() => copyWith(isDead: true);

  Bird reset() => copyWith(
    velocity: 0,
    isDead: false,
    score: 0,
  );

  @override
  List<Object?> get props => [x, y, velocity, isDead, score, brain];
} 