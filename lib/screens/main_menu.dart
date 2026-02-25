import 'package:flutter/material.dart';
import '../data/storage.dart';
import '../creatures/monsterdex.dart';
import 'game_screen.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await GameStorage.init();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🏃 Stick Adventure',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Daily Monster Hunt',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            _MenuButton(
              label: '▶ PLAY',
              color: const Color(0xFF44ff88),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GameScreen())),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              label: '📖 MonsterDex',
              color: const Color(0xFFffcc00),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MonsterDexScreen())),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              label: '🎒 Inventory',
              color: const Color(0xFF4488ff),
              onTap: () {
                // TODO: inventory screen
              },
            ),
            const SizedBox(height: 12),
            _MenuButton(
              label: '⚙ Settings',
              color: Colors.grey,
              onTap: () {
                // TODO: settings screen
              },
            ),
            const SizedBox(height: 30),
            Builder(builder: (_) {
              final meta = GameStorage.getMeta();
              if (meta.currentStreak > 0) {
                return Text(
                  '🔥 ${meta.currentStreak} day streak',
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
