import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/stick_adventure_game.dart';
import '../ui/hud.dart';
import '../ui/joystick.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late StickAdventureGame _game;

  @override
  void initState() {
    super.initState();
    _game = StickAdventureGame();
    _game.onStateChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          GameHUD(game: _game),
          GameJoystick(game: _game),
          if (_game.state == GameState.gameOver)
            _buildGameOver(),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💀 GAME OVER',
              style: TextStyle(
                color: Colors.red,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reached ${_game.playerDistance.round()}m • Level ${_game.leveling.level}',
              style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
