import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../components/bird.dart';
import '../components/pipe.dart';
import '../game/game_manager.dart';

final class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

final class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  GameManager? _gameManager;
  Ticker? _ticker;
  int _speedMultiplierIndex = 0;
  final List<double> _speedMultiplierList = [1.0, 2.0, 3.0, 4.0, 5.0];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    
    // Initialize or update game manager if screen size changed
    if (_gameManager == null ||
        _gameManager!.screenWidth != size.width ||
        _gameManager!.screenHeight != size.height) {
      _gameManager = GameManager(
        screenWidth: size.width,
        screenHeight: size.height,
        speedMultiplier: _speedMultiplierList[_speedMultiplierIndex],
      );
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_gameManager == null) return;
    
    setState(() {
      _gameManager = _gameManager!.update();
    });
  }

  void _toggleSpeed() {
    setState(() {
      _speedMultiplierIndex = (_speedMultiplierIndex + 1) % _speedMultiplierList.length;
      if (_gameManager != null) {
        _gameManager = _gameManager!.copyWith(speedMultiplier: _speedMultiplierList[_speedMultiplierIndex]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_gameManager == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GameBackground(),
          CustomPaint(
            painter: GamePainter(
              birds: _gameManager!.birds,
              pipes: _gameManager!.pipes,
            ),
            size: Size(
              _gameManager!.screenWidth,
              _gameManager!.screenHeight,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: GameStatusOverlay(
              generation: _gameManager!.generation,
              bestScore: _gameManager!.bestScore,
              isPlaying: _gameManager!.isPlaying,
              onStart: () {
                setState(() {
                  _gameManager = _gameManager!.start();
                });
                _ticker?.start();
              },
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleSpeed,
              child: Text('${_speedMultiplierList[_speedMultiplierIndex]}x'),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 20,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }
}

final class GameBackground extends StatelessWidget {
  const GameBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background-day.png'),
          fit: BoxFit.cover,
          repeat: ImageRepeat.repeatX,
        ),
      ),
    );
  }
}

final class GamePainter extends CustomPainter {
  final List<Bird> birds;
  final List<Pipe> pipes;

  const GamePainter({
    required this.birds,
    required this.pipes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw pipes
    for (final pipe in pipes) {
      pipe.draw(canvas, size);
    }

    // Draw birds
    for (final bird in birds) {
      bird.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}

final class GameStatusOverlay extends StatelessWidget {
  final int generation;
  final int bestScore;
  final bool isPlaying;
  final VoidCallback onStart;

  const GameStatusOverlay({
    super.key,
    required this.generation,
    required this.bestScore,
    required this.isPlaying,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusBar(),
        if (!isPlaying) ...[
          const SizedBox(height: 20),
          _buildGameControls(),
        ],
      ],
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
      mainAxisSize: MainAxisSize.min,
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
      ],
    );
  }
} 