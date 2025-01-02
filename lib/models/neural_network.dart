import 'dart:math';

import 'package:equatable/equatable.dart';

final class NeuralNetwork extends Equatable {
  final List<int> layers;
  final List<List<List<double>>> weights;
  final List<List<double>> biases;
  final Random random;

  NeuralNetwork._({
    required this.layers,
    required this.weights,
    required this.biases,
    Random? random,
  }) : random = random ?? Random();

  factory NeuralNetwork({
    required List<int> layers,
    List<List<List<double>>>? initialWeights,
    List<List<double>>? initialBiases,
    Random? random,
  }) {
    final rng = random ?? Random();
    final weights = initialWeights ?? _initializeWeights(layers, rng);
    final biases = initialBiases ?? _initializeBiases(layers, rng);

    return NeuralNetwork._(
      layers: layers,
      weights: weights,
      biases: biases,
      random: rng,
    );
  }

  static List<List<List<double>>> _initializeWeights(List<int> layers, Random random) {
    final weights = <List<List<double>>>[];
    
    for (int i = 0; i < layers.length - 1; i++) {
      final layerWeights = List<List<double>>.generate(
        layers[i],
        (index) => List<double>.generate(
          layers[i + 1],
          (index) => _generateRandomWeight(random),
        ),
      );
      weights.add(layerWeights);
    }
    
    return weights;
  }

  static List<List<double>> _initializeBiases(List<int> layers, Random random) {
    final biases = <List<double>>[];
    
    for (int i = 1; i < layers.length; i++) {
      final layerBiases = List<double>.generate(
        layers[i],
        (index) => _generateRandomWeight(random),
      );
      biases.add(layerBiases);
    }
    
    return biases;
  }

  static double _generateRandomWeight(Random random) {
    return random.nextDouble() * 2 - 1; // Random value between -1 and 1
  }

  List<double> feedForward(List<double> inputs) {
    var currentLayer = List<double>.from(inputs);

    for (int i = 0; i < weights.length; i++) {
      final nextLayer = List<double>.filled(layers[i + 1], 0);

      // Calculate weighted sum for each neuron in the next layer
      for (int j = 0; j < weights[i].length; j++) {
        for (int k = 0; k < weights[i][j].length; k++) {
          nextLayer[k] += currentLayer[j] * weights[i][j][k];
        }
      }

      // Add biases and apply activation function
      for (int j = 0; j < nextLayer.length; j++) {
        nextLayer[j] += biases[i][j];
        nextLayer[j] = _activate(nextLayer[j]);
      }

      currentLayer = nextLayer;
    }

    return currentLayer;
  }

  double _activate(double x) {
    // Using ReLU activation function
    return x > 0 ? x : 0;
  }

  NeuralNetwork copyWith({
    List<int>? layers,
    List<List<List<double>>>? weights,
    List<List<double>>? biases,
    Random? random,
  }) {
    return NeuralNetwork._(
      layers: layers ?? this.layers,
      weights: weights ?? this.weights,
      biases: biases ?? this.biases,
      random: random ?? this.random,
    );
  }

  NeuralNetwork clone() {
    return copyWith(
      layers: List<int>.from(layers),
      weights: weights.map((layer) {
        return layer.map((neuron) {
          return List<double>.from(neuron);
        }).toList();
      }).toList(),
      biases: biases.map((layer) {
        return List<double>.from(layer);
      }).toList(),
      random: Random(),
    );
  }

  NeuralNetwork mutate(double mutationRate) {
    final newWeights = weights.map((layer) {
      return layer.map((neuron) {
        return neuron.map((weight) {
          if (random.nextDouble() < mutationRate) {
            return weight + random.nextDouble() * 0.4 - 0.2;
          }
          return weight;
        }).toList();
      }).toList();
    }).toList();

    final newBiases = biases.map((layer) {
      return layer.map((bias) {
        if (random.nextDouble() < mutationRate) {
          return bias + random.nextDouble() * 0.4 - 0.2;
        }
        return bias;
      }).toList();
    }).toList();

    return copyWith(
      weights: newWeights,
      biases: newBiases,
    );
  }

  @override
  List<Object> get props => [
    layers,
    weights,
    biases,
  ];
} 