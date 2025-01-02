import 'package:flutter/material.dart';

class GameStatusOverlay extends StatelessWidget {
  final int generation;
  final int bestScore;
  final bool isPlaying;
  final VoidCallback onStart;
  final VoidCallback onReset;

  const GameStatusOverlay({
    super.key,
    required this.generation,
    required this.bestScore,
    required this.isPlaying,
    required this.onStart,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusBar(),
            const Spacer(),
            if (!isPlaying) _buildGameControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Generation: $generation',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Best Score: $bestScore',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameControls() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
          ),
          child: const Text(
            'Start Evolution',
            style: TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onReset,
          child: const Text(
            'Reset',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
} 