import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../components/bird.dart';
import '../components/pipe.dart';
import '../models/genetic_algorithm.dart';

final class GameManager extends Equatable {
  // Game properties
  final double screenWidth;
  final double screenHeight;
  final Random random;
  final GeneticAlgorithm geneticAlgorithm;
  final List<Bird> birds;
  final List<Pipe> pipes;
  final int frameCount;
  final int generation;
  final int bestScore;
  final bool isPlaying;
  final double speedMultiplier;

  // Game constants
  static const double pipeSpacing = 250.0;  // Distance between pipes
  static const double gameSpeed = 3.0;      // Game scroll speed
  static const double birdStartX = 100.0;   // Starting X position for birds
  static const int networkInputs = 4;       // Neural network inputs
  static const List<int> networkLayers = [networkInputs, 6, 1];

  GameManager({
    required this.screenWidth,
    required this.screenHeight,
    Random? random,
    GeneticAlgorithm? geneticAlgorithm,
    this.birds = const [],
    this.pipes = const [],
    this.frameCount = 0,
    this.generation = 1,
    this.bestScore = 0,
    this.isPlaying = false,
    this.speedMultiplier = 1.0,
  })  : random = random ?? Random(),
        geneticAlgorithm = geneticAlgorithm ??
            GeneticAlgorithm(
              populationSize: 50,
              networkLayers: networkLayers,
            ) {
    dev.log('Game initialized with screen size: ${screenWidth}x$screenHeight');
  }

  GameManager copyWith({
    double? screenWidth,
    double? screenHeight,
    Random? random,
    GeneticAlgorithm? geneticAlgorithm,
    List<Bird>? birds,
    List<Pipe>? pipes,
    int? frameCount,
    int? generation,
    int? bestScore,
    bool? isPlaying,
    double? speedMultiplier,
  }) {
    return GameManager(
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      random: random ?? this.random,
      geneticAlgorithm: geneticAlgorithm ?? this.geneticAlgorithm,
      birds: birds ?? this.birds,
      pipes: pipes ?? this.pipes,
      frameCount: frameCount ?? this.frameCount,
      generation: generation ?? this.generation,
      bestScore: bestScore ?? this.bestScore,
      isPlaying: isPlaying ?? this.isPlaying,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
    );
  }

  GameManager start() {
    if (isPlaying) return this;
    
    dev.log('Starting new game');
    final startY = screenHeight * 0.5;
    
    // Create initial pipes with proper spacing
    final initialPipes = <Pipe>[];
    for (int i = 0; i < 3; i++) {
      initialPipes.add(_createPipe(screenWidth + (i * pipeSpacing)));
    }
    
    return copyWith(
      isPlaying: true,
      birds: geneticAlgorithm.createInitialPopulation(birdStartX, startY),
      pipes: initialPipes,
      frameCount: 0,
    );
  }

  GameManager update() {
    if (!isPlaying) return this;

    var updatedBirds = List<Bird>.from(birds);
    var updatedPipes = List<Pipe>.from(pipes);
    var newBestScore = bestScore;
    var newFrameCount = frameCount + 1;

    // Update and check collisions for each bird
    for (var i = updatedBirds.length - 1; i >= 0; i--) {
      if (!updatedBirds[i].isDead) {
        final inputs = _getBirdInputs(updatedBirds[i]);
        var updatedBird = updatedBirds[i].think(inputs).update();

        // Check collisions
        if (_checkBirdCollisions(updatedBird)) {
          dev.log('Bird ${i + 1} died at position (${updatedBird.x}, ${updatedBird.y})');
          updatedBird = updatedBird.die();
        } else {
          updatedBird = updatedBird.copyWith(score: updatedBird.score + 1);
          if (updatedBird.score > newBestScore) {
            newBestScore = updatedBird.score;
            dev.log('New best score: $newBestScore');
          }
        }

        updatedBirds[i] = updatedBird;
      }
    }

    // Update pipes
    for (var i = updatedPipes.length - 1; i >= 0; i--) {
      updatedPipes[i] = updatedPipes[i].update(gameSpeed * speedMultiplier);
      
      if (updatedPipes[i].isOffScreen()) {
        updatedPipes.removeAt(i);
        dev.log('Removed off-screen pipe');
      }
    }

    // Generate new pipes
    if (updatedPipes.isEmpty || 
        updatedPipes.last.x <= screenWidth - pipeSpacing) {
      updatedPipes.add(_createPipe());
      dev.log('Added new pipe');
    }

    var updatedManager = copyWith(
      birds: updatedBirds,
      pipes: updatedPipes,
      frameCount: newFrameCount,
      bestScore: newBestScore,
    );

    // Check if all birds are dead
    if (updatedBirds.every((bird) => bird.isDead)) {
      dev.log('Generation ${generation} ended. Best score: $newBestScore');
      return updatedManager._evolve();
    }

    return updatedManager;
  }

  Pipe _createPipe([double? x]) {
    final pipeX = x ?? (pipes.isEmpty ? screenWidth : pipes.last.x + pipeSpacing);
    
    // Calculate gap position that ensures pipes are visible
    final minGap = screenHeight * 0.25;  // 25% of screen height
    final maxGap = screenHeight * 0.35;  // 35% of screen height
    final gap = minGap + random.nextDouble() * (maxGap - minGap);
    
    // Ensure the gap is always within screen bounds
    final minTopHeight = screenHeight * 0.1;  // At least 10% of screen height
    final maxTopHeight = screenHeight * 0.6;  // At most 60% of screen height
    final topHeight = minTopHeight + random.nextDouble() * (maxTopHeight - minTopHeight);

    dev.log('Creating pipe at x: $pipeX, topHeight: $topHeight, gap: $gap');
    
    return Pipe(
      x: pipeX,
      topHeight: topHeight,
      gap: gap,
    );
  }

  List<double> _getBirdInputs(Bird bird) {
    // Find the next pipe
    Pipe? nextPipe;
    for (final pipe in pipes) {
      if (pipe.x + pipe.width > bird.x) {
        nextPipe = pipe;
        break;
      }
    }

    if (nextPipe == null) {
      return List.filled(networkInputs, 0);
    }

    // Normalize inputs between 0 and 1
    return [
      bird.y / screenHeight,                    // Bird's height
      (bird.velocity + 10) / 20,                // Bird's velocity (normalized between -10 and 10)
      (nextPipe.x - bird.x) / screenWidth,      // Distance to next pipe
      nextPipe.topHeight / screenHeight,        // Height of next pipe
    ];
  }

  bool _checkBirdCollisions(Bird bird) {
    // Check if bird hits the ground or ceiling
    if (bird.y <= 0 || bird.y >= screenHeight) {
      dev.log('Bird hit boundary at y: ${bird.y}');
      return true;
    }

    // Check collision with pipes
    for (final pipe in pipes) {
      for (final rect in pipe.getCollisionRects(Size(screenWidth, screenHeight))) {
        if (bird.checkCollision(rect)) {
          return true;
        }
      }
    }

    return false;
  }

  GameManager _evolve() {
    final startY = screenHeight * 0.5;
    
    final evolvedBirds = geneticAlgorithm.evolve(birds)
      .map((bird) => bird.copyWith(x: birdStartX, y: startY))
      .map((bird) => bird.reset())
      .toList();

    // Create initial pipes for the new generation
    final initialPipes = <Pipe>[];
    for (int i = 0; i < 3; i++) {
      initialPipes.add(_createPipe(screenWidth + (i * pipeSpacing)));
    }

    return copyWith(
      generation: generation + 1,
      birds: evolvedBirds,
      pipes: initialPipes,
      frameCount: 0,
    );
  }

  GameManager reset() {
    return copyWith(
      birds: [],
      pipes: [],
      generation: 1,
      bestScore: 0,
      isPlaying: false,
    );
  }

  @override
  List<Object?> get props => [
    screenWidth,
    screenHeight,
    random,
    geneticAlgorithm,
    birds,
    pipes,
    frameCount,
    generation,
    bestScore,
    isPlaying,
    speedMultiplier,
  ];
} 