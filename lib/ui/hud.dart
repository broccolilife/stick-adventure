import 'package:flutter/material.dart';
import '../game/stick_adventure_game.dart';

class GameHUD extends StatelessWidget {
  final StickAdventureGame game;

  const GameHUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // HP bar
                  _buildHpBar(),
                  const SizedBox(width: 12),
                  // Level + XP
                  _buildLevelXp(),
                  const Spacer(),
                  // Zone info
                  _buildZoneInfo(),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Secondary info row
            Row(
              children: [
                if (game.meta.currentStreak > 0)
                  _pill('🔥${game.meta.currentStreak}', Colors.deepOrange),
                const SizedBox(width: 6),
                if (game.isAtHome)
                  _pill('🏠 Safe Zone', Colors.green),
                if (game.creatureSpawner.isTodayAvailable)
                  _pill('🎯 Creature nearby!', Colors.amber),
                const Spacer(),
                // Idle toggle
                GestureDetector(
                  onTap: () => game.toggleIdle(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: game.idleManager.active
                          ? const Color(0xFF44ff88).withValues(alpha: 0.3)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: game.idleManager.active
                            ? const Color(0xFF44ff88)
                            : Colors.white24,
                      ),
                    ),
                    child: Text(
                      game.idleManager.active ? '🚶 AUTO' : '🚶 IDLE',
                      style: TextStyle(
                        color: game.idleManager.active
                            ? const Color(0xFF44ff88)
                            : Colors.white54,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Idle alert
            if (game.idleManager.currentAlert != null)
              _buildAlertOverlay(),
            // Combat result
            if (game.combatResult != null)
              _buildCombatResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildHpBar() {
    final ratio = game.hpRatio;
    final color = ratio > 0.5
        ? Colors.green
        : ratio > 0.2
            ? Colors.yellow
            : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${game.playerHp}/${game.leveling.maxHp}',
          style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
        ),
        SizedBox(
          width: 100,
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              backgroundColor: Colors.grey.shade800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelXp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Lv.${game.leveling.level}',
          style: const TextStyle(
            color: Color(0xFFffcc00),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(
          width: 60,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: game.leveling.progress.clamp(0, 1),
              backgroundColor: Colors.grey.shade800,
              color: const Color(0xFF44aaff),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '📍 ${game.zoneName}',
          style: const TextStyle(color: Color(0xFFaaffaa), fontSize: 11, fontFamily: 'monospace'),
        ),
        Text(
          '${game.playerDistance.round()}m from home',
          style: const TextStyle(color: Colors.grey, fontSize: 9, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildAlertOverlay() {
    final alert = game.idleManager.currentAlert!;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              alert.message,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => game.dismissIdleAlert(),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombatResult() {
    final r = game.combatResult!;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              r.won ? '⚔️ Defeated ${r.enemyName}! +${r.xpEarned}XP' : '💀 Defeated by ${r.enemyName}',
              style: TextStyle(
                color: r.won ? const Color(0xFF44ff88) : Colors.red,
                fontSize: 14,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '-${r.damageTaken} HP',
              style: const TextStyle(color: Color(0xFFff8844), fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
