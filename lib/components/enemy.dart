import 'dart:math' as math;
import '../zones/zone_manager.dart';

class CombatResult {
  final bool won;
  final int damageDealt;
  final int damageTaken;
  final int xpEarned;
  final String enemyName;
  final int enemyLevel;

  const CombatResult({
    required this.won,
    required this.damageDealt,
    required this.damageTaken,
    required this.xpEarned,
    required this.enemyName,
    required this.enemyLevel,
  });
}

class AutoCombat {
  static bool canAutoFight(EnemyData enemy, int playerLevel) {
    return enemy.level < playerLevel;
  }

  static CombatResult resolve(EnemyData enemy, int playerLevel, int playerAtk) {
    final effectiveAtk = playerAtk + playerLevel * 2;
    final rounds = (enemy.hp / effectiveAtk).ceil();
    final damageTaken = math.max(0, rounds * enemy.atk - playerLevel);

    return CombatResult(
      won: true,
      damageDealt: enemy.hp,
      damageTaken: (damageTaken * 0.5).round(),
      xpEarned: (enemy.level * 5).clamp(10, 50),
      enemyName: enemy.name,
      enemyLevel: enemy.level,
    );
  }
}
