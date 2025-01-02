import 'dart:math';

import 'package:equatable/equatable.dart';

import '../components/bird.dart';
import 'neural_network.dart';

final class GeneticAlgorithm extends Equatable {
  final int populationSize;
  final double mutationRate;
  final Random random;
  final List<int> networkLayers;

  GeneticAlgorithm({
    required this.populationSize,
    required this.networkLayers,
    this.mutationRate = 0.1,
    Random? random,
  }) : random = random ?? Random();

  List<Bird> createInitialPopulation(double startX, double startY) {
    return List.generate(populationSize, (index) {
      return Bird(
        x: startX,
        y: startY,
        brain: NeuralNetwork(layers: networkLayers),
      );
    });
  }

  List<Bird> evolve(List<Bird> oldPopulation) {
    if (oldPopulation.isEmpty) return [];

    // Sort birds by fitness (score)
    final sortedPopulation = List<Bird>.from(oldPopulation)
      ..sort((a, b) => b.score.compareTo(a.score));

    // Select top performers
    final topPerformers = sortedPopulation.take((populationSize * 0.2).ceil()).toList();

    // Create new population
    final newPopulation = <Bird>[];

    // Keep top performers
    for (var bird in topPerformers) {
      if (bird.brain != null) {
        newPopulation.add(Bird(
          x: bird.x,
          y: bird.y,
          brain: bird.brain!.clone(),
        ));
      }
    }

    // Fill rest of population with offspring
    while (newPopulation.length < populationSize) {
      final parent1 = _selectParent(topPerformers);
      final parent2 = _selectParent(topPerformers);
      
      if (parent1.brain != null && parent2.brain != null) {
        final child = _crossover(parent1, parent2);
        final mutatedBrain = child.brain?.mutate(mutationRate);
        if (mutatedBrain != null) {
          newPopulation.add(child.copyWith(brain: mutatedBrain));
        }
      }
    }

    return newPopulation;
  }

  Bird _selectParent(List<Bird> population) {
    // Tournament selection
    final tournamentSize = 3;
    Bird selected = population[random.nextInt(population.length)];
    
    for (int i = 0; i < tournamentSize - 1; i++) {
      final candidate = population[random.nextInt(population.length)];
      if (candidate.score > selected.score) {
        selected = candidate;
      }
    }
    
    return selected;
  }

  Bird _crossover(Bird parent1, Bird parent2) {
    if (parent1.brain == null || parent2.brain == null) {
      return Bird(x: parent1.x, y: parent1.y);
    }

    return Bird(
      x: parent1.x,
      y: parent1.y,
      brain: NeuralNetwork(
        layers: networkLayers,
        initialWeights: _crossoverWeights(parent1.brain!.weights, parent2.brain!.weights),
        initialBiases: _crossoverBiases(parent1.brain!.biases, parent2.brain!.biases),
      ),
    );
  }

  List<List<List<double>>> _crossoverWeights(
    List<List<List<double>>> weights1,
    List<List<List<double>>> weights2,
  ) {
    final crossedWeights = <List<List<double>>>[];
    
    for (int i = 0; i < weights1.length; i++) {
      final layerWeights = <List<double>>[];
      
      for (int j = 0; j < weights1[i].length; j++) {
        final neuronWeights = <double>[];
        
        for (int k = 0; k < weights1[i][j].length; k++) {
          // Randomly choose weight from either parent
          final weight = random.nextBool() ? weights1[i][j][k] : weights2[i][j][k];
          neuronWeights.add(weight);
        }
        
        layerWeights.add(neuronWeights);
      }
      
      crossedWeights.add(layerWeights);
    }
    
    return crossedWeights;
  }

  List<List<double>> _crossoverBiases(
    List<List<double>> biases1,
    List<List<double>> biases2,
  ) {
    final crossedBiases = <List<double>>[];
    
    for (int i = 0; i < biases1.length; i++) {
      final layerBiases = <double>[];
      
      for (int j = 0; j < biases1[i].length; j++) {
        // Randomly choose bias from either parent
        final bias = random.nextBool() ? biases1[i][j] : biases2[i][j];
        layerBiases.add(bias);
      }
      
      crossedBiases.add(layerBiases);
    }
    
    return crossedBiases;
  }

  @override
  List<Object> get props => [
    populationSize,
    mutationRate,
    networkLayers,
  ];
} 