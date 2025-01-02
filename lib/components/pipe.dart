import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

final class Pipe extends Equatable {
  // Static image handling
  static ui.Image? _pipeImage;
  static bool _isLoading = false;

  static Future<void> loadAssets(ImageProvider provider) async {
    if (_pipeImage != null) return;
    if (_isLoading) return;
    
    _isLoading = true;
    dev.log('Loading pipe image...');
    
    try {
      final completer = Completer<ui.Image>();
      final stream = provider.resolve(ImageConfiguration.empty);
      
      final listener = ImageStreamListener((info, _) {
        completer.complete(info.image);
        dev.log('Pipe image loaded successfully');
      });
      
      stream.addListener(listener);
      _pipeImage = await completer.future;
      stream.removeListener(listener);
    } catch (e) {
      dev.log('Error loading pipe image: $e');
    } finally {
      _isLoading = false;
    }
  }

  // Pipe properties
  final double x;
  final double topHeight;
  final double gap;
  final double width;
  final bool passed;

  // Constants
  static const double defaultWidth = 52.0;  // Match sprite width
  static const double defaultGap = 140.0;   // Reduced gap between pipes
  static const double minHeight = 100.0;    // Increased minimum pipe height
  static const double maxHeight = 320.0;    // Added maximum pipe height
  static const double maxGap = 160.0;       // Reduced maximum gap

  const Pipe({
    required this.x,
    required this.topHeight,
    this.gap = defaultGap,
    this.width = defaultWidth,
    this.passed = false,
  });

  Pipe copyWith({
    double? x,
    double? topHeight,
    double? gap,
    double? width,
    bool? passed,
  }) {
    return Pipe(
      x: x ?? this.x,
      topHeight: topHeight ?? this.topHeight,
      gap: gap ?? this.gap,
      width: width ?? this.width,
      passed: passed ?? this.passed,
    );
  }

  void draw(Canvas canvas, Size size) {
    if (_pipeImage == null) {
      dev.log('Pipe image not loaded, attempting to load...');
      loadAssets(const AssetImage('assets/images/pipe-green.png'));
      // Draw placeholder until image loads
      final placeholder = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      
      // Draw top pipe placeholder
      canvas.drawRect(
        Rect.fromLTWH(x, 0, width, topHeight),
        placeholder,
      );
      
      // Draw bottom pipe placeholder
      canvas.drawRect(
        Rect.fromLTWH(x, topHeight + gap, width, size.height - (topHeight + gap)),
        placeholder,
      );
      return;
    }

    // Draw top pipe (flipped)
    canvas.save();
    canvas.translate(x + width / 2, topHeight / 2);
    canvas.scale(1, -1);  // Flip vertically
    canvas.translate(-(x + width / 2), -topHeight / 2);
    
    canvas.drawImageRect(
      _pipeImage!,
      Rect.fromLTWH(0, 0, _pipeImage!.width.toDouble(), _pipeImage!.height.toDouble()),
      Rect.fromLTWH(x, 0, width, topHeight),
      Paint(),
    );
    canvas.restore();

    // Draw bottom pipe
    canvas.drawImageRect(
      _pipeImage!,
      Rect.fromLTWH(0, 0, _pipeImage!.width.toDouble(), _pipeImage!.height.toDouble()),
      Rect.fromLTWH(x, topHeight + gap, width, size.height - (topHeight + gap)),
      Paint(),
    );
  }

  List<Rect> getCollisionRects(Size size) {
    return [
      // Top pipe collision rect
      Rect.fromLTWH(x, 0, width, topHeight),
      // Bottom pipe collision rect
      Rect.fromLTWH(x, topHeight + gap, width, size.height - (topHeight + gap)),
    ];
  }

  Pipe update(double speed) {
    return copyWith(x: x - speed);
  }

  bool isOffScreen() {
    return x + width < 0;
  }

  @override
  List<Object> get props => [x, topHeight, gap, width, passed];
} 