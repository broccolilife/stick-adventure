import 'dart:math' as math;
import 'types.dart';
import 'generator.dart';
import '../data/storage.dart';

class SpawnedCreature {
  final Creature creature;
  double x;
  double y;
  final double patrolOriginX;
  final double patrolRange;
  int patrolDir;
  bool active;

  SpawnedCreature({
    required this.creature,
    required this.x,
    required this.y,
    required this.patrolOriginX,
    this.patrolRange = 40,
    this.patrolDir = 1,
    this.active = true,
  });
}

class CreatureSpawner {
  SpawnedCreature? spawned;
  bool catchProximity = false;

  void spawnForToday(double levelWidth, double groundY) {
    final dateStr = getTodayDateStr();
    if (GameStorage.isCreatureCaught(dateStr)) {
      spawned = null;
      return;
    }
    final creature = getCreatureForDate(dateStr);
    final pos = _spawnPosition(dateStr, levelWidth, groundY);
    spawned = SpawnedCreature(
      creature: creature,
      x: pos.x,
      y: pos.y,
      patrolOriginX: pos.x,
    );
  }

  void update(double dt, double playerX, double playerY) {
    if (spawned == null || !spawned!.active) return;
    final s = spawned!;
    s.x += s.patrolDir * 20 * dt;
    if (s.x > s.patrolOriginX + s.patrolRange) s.patrolDir = -1;
    if (s.x < s.patrolOriginX - s.patrolRange) s.patrolDir = 1;

    final dx = playerX - s.x;
    final dy = playerY - s.y;
    catchProximity = math.sqrt(dx * dx + dy * dy) < 60;
  }

  bool get canCatch => catchProximity && (spawned?.active ?? false);

  Creature? catchCreature() {
    if (spawned == null || !spawned!.active) return null;
    final creature = spawned!.creature..caught = true;
    GameStorage.saveCaughtCreature(creature);
    spawned!.active = false;
    return creature;
  }

  bool get isTodayAvailable => !GameStorage.isCreatureCaught(getTodayDateStr());

  _Pos _spawnPosition(String dateStr, double levelWidth, double groundY) {
    int h = 0;
    for (int i = 0; i < dateStr.length; i++) {
      h = (31 * h + dateStr.codeUnitAt(i)) & 0xFFFFFFFF;
      if (h >= 0x80000000) h -= 0x100000000;
    }
    double rng() {
      h = (h + 0x6D2B79F5) & 0xFFFFFFFF;
      if (h >= 0x80000000) h -= 0x100000000;
      int t = ((h ^ (h >> 15)) * (1 | h)) & 0xFFFFFFFF;
      t = ((t + ((t ^ (t >> 7)) * (61 | t)) & 0xFFFFFFFF) ^ t) & 0xFFFFFFFF;
      return ((t ^ (t >> 14)) & 0xFFFFFFFF).abs() / 4294967296.0;
    }
    return _Pos(200 + rng() * (levelWidth - 400), groundY - 20);
  }
}

class _Pos {
  final double x, y;
  _Pos(this.x, this.y);
}
