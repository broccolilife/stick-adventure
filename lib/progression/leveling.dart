import '../data/storage.dart';
import '../creatures/types.dart' show Rarity;

class LevelingSystem {
  int xp = 0;
  int level = 1;
  int maxHp = 100;
  double levelUpFlash = 0;

  LevelingSystem() {
    _load();
  }

  static int xpForLevel(int level) => level * 100;

  bool addXp(int amount) {
    xp += amount;
    bool leveled = false;
    while (xp >= xpForLevel(level + 1)) {
      xp -= xpForLevel(level + 1);
      level++;
      maxHp = 100 + (level - 1) * 15;
      levelUpFlash = 2;
      leveled = true;
    }
    _save();
    return leveled;
  }

  double get progress {
    final needed = xpForLevel(level + 1);
    return needed > 0 ? xp / needed : 0;
  }

  void update(double dt) {
    if (levelUpFlash > 0) levelUpFlash -= dt;
  }

  void _save() => GameStorage.saveLeveling(level, xp);

  void _load() {
    final data = GameStorage.loadLeveling();
    if (data != null) {
      xp = data['xp'] ?? 0;
      level = data['level'] ?? 1;
      maxHp = 100 + (level - 1) * 15;
    }
  }
}

class XpRewards {
  static int catchCreature(Rarity rarity) => 50 * rarity.multiplier;
  static int killEnemy(int enemyLevel) => (enemyLevel * 5).clamp(10, 50);
  static const explore100m = 5;
  static const findRestSpot = 20;
  static const completeZone = 200;
  static const dailyLogin = 25;
}
