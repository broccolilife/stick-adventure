import 'dart:math' as math;
import 'zone.dart';
import 'rest_spot.dart';
import 'home_base.dart';

class EnemyData {
  final String id;
  final String name;
  int hp;
  final int maxHp;
  final int atk;
  final int level;
  final int zoneId;
  final double distance;
  bool defeated;

  EnemyData({
    required this.id,
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.atk,
    required this.level,
    required this.zoneId,
    required this.distance,
    this.defeated = false,
  });
}

class ZoneUpdateResult {
  final int hpDrain;
  final bool zoneChanged;
  final bool blocked;
  final Zone? newZone;
  final EnemyData? enemyEncounter;
  final RestSpotData? restSpotFound;

  const ZoneUpdateResult({
    this.hpDrain = 0,
    this.zoneChanged = false,
    this.blocked = false,
    this.newZone,
    this.enemyEncounter,
    this.restSpotFound,
  });
}

class ZoneManager {
  double playerDistance = 0;
  Zone currentZone = zones[0];
  int playerLevel = 1;
  int playerHp = 100;
  int playerMaxHp = 100;

  double _hpDrainAccum = 0;
  double _transitionAlpha = 0;
  double _nextEnemyDistance = 80;
  String? _blockedMessage;
  double _blockedTimer = 0;

  final RestSpotManager restSpots = RestSpotManager();
  final HomeBase homeBase = HomeBase();

  final _rng = math.Random();
  static const _enemyNames = ['Slime', 'Goblin', 'Wolf', 'Wraith', 'Golem', 'Drake', 'Shade', 'Imp'];

  double pixelToDistance(double px) => px * 0.5;
  double distanceToPixel(double meters) => meters * 2;

  ZoneUpdateResult update(double dt, double playerPixelX) {
    playerDistance = pixelToDistance(playerPixelX);
    final zone = getZoneAtDistance(playerDistance);
    bool blocked = false;
    bool zoneChanged = false;
    Zone? newZone;

    if (zone.id != currentZone.id) {
      if (zone.requiredLevel > playerLevel) {
        blocked = true;
        _blockedMessage = 'Level ${zone.requiredLevel} required for ${zone.name}!';
        _blockedTimer = 3;
      } else {
        currentZone = zone;
        _transitionAlpha = 1;
        zoneChanged = true;
        newZone = zone;
      }
    }

    if (_transitionAlpha > 0) {
      _transitionAlpha = math.max(0, _transitionAlpha - dt * 2);
    }
    if (_blockedTimer > 0) _blockedTimer -= dt;

    // HP drain
    int hpDrain = 0;
    if (playerDistance > 10) {
      _hpDrainAccum += currentZone.hpDrainPerMin * dt / 60;
      if (_hpDrainAccum >= 1) {
        hpDrain = _hpDrainAccum.floor();
        _hpDrainAccum -= hpDrain;
      }
    }

    // Enemy spawning
    EnemyData? enemyEncounter;
    if (playerDistance >= _nextEnemyDistance && playerDistance > 20) {
      enemyEncounter = _spawnEnemy();
      _nextEnemyDistance = playerDistance + 60 + _rng.nextDouble() * 100;
    }

    // Rest spot
    final restSpotFound = restSpots.checkDiscovery(playerDistance);

    return ZoneUpdateResult(
      hpDrain: hpDrain,
      zoneChanged: zoneChanged,
      blocked: blocked,
      newZone: newZone,
      enemyEncounter: enemyEncounter,
      restSpotFound: restSpotFound,
    );
  }

  EnemyData _spawnEnemy() {
    final z = currentZone;
    final atk = z.enemyAtkMin + _rng.nextDouble() * (z.enemyAtkMax - z.enemyAtkMin);
    final hp = z.enemyHpMin + _rng.nextDouble() * (z.enemyHpMax - z.enemyHpMin);
    final level = z.requiredLevel + _rng.nextInt(5);
    return EnemyData(
      id: 'enemy_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(10000)}',
      name: _enemyNames[_rng.nextInt(_enemyNames.length)],
      hp: hp.round(),
      maxHp: hp.round(),
      atk: atk.round(),
      level: level,
      zoneId: z.id,
      distance: playerDistance,
    );
  }

  String? get blockedMessage => _blockedTimer > 0 ? _blockedMessage : null;
  double get transitionAlpha => _transitionAlpha;

  double get currentZoneEndPixel => distanceToPixel(currentZone.distanceEnd);

  double getNearestSafeDistance() {
    final spots = restSpots.discovered;
    double nearest = 0;
    double minDist = playerDistance;
    for (final s in spots) {
      final d = (s.distance - playerDistance).abs();
      if (d < minDist) {
        minDist = d;
        nearest = s.distance;
      }
    }
    return nearest;
  }
}
