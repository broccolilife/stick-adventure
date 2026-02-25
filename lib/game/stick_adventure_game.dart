import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show TextStyle;

import '../components/player.dart';
import '../components/enemy.dart';
import '../creatures/spawner.dart';
import '../creatures/types.dart' show Rarity, rarityColors, MonsterDexMeta;
import '../data/storage.dart';
import '../idle/idle_manager.dart';
import '../progression/leveling.dart';
import '../zones/zone_manager.dart';

enum GameState { playing, paused, gameOver }

class StickAdventureGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late ZoneManager zoneManager;
  late IdleManager idleManager;
  late LevelingSystem leveling;
  late CreatureSpawner creatureSpawner;

  GameState state = GameState.playing;
  double groundY = 0;
  double cameraOffset = 0;
  int playerHp = 100;
  double _exploredDistance = 0;
  double _lastExploreXpDist = 0;
  double _gameTime = 0;
  EnemyData? _currentEnemy;
  CombatResult? _combatResult;
  double _combatResultTimer = 0;

  // Input state set by overlay joystick/buttons
  bool inputLeft = false;
  bool inputRight = false;
  bool inputJump = false;
  bool inputCatch = false;
  bool inputAttack = false;

  // Callbacks for UI overlay
  void Function(String message)? onAlert;
  void Function()? onStateChanged;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    groundY = size.y * 0.8;

    zoneManager = ZoneManager();
    idleManager = IdleManager();
    leveling = LevelingSystem();
    creatureSpawner = CreatureSpawner();

    playerHp = leveling.maxHp;

    player = Player();
    player.position = Vector2(50, groundY);
    add(player);

    // Spawn creature in world (using pixel width of ~6000 for level)
    creatureSpawner.spawnForToday(6000, groundY);
  }

  @override
  void update(double dt) {
    if (state != GameState.playing) return;
    super.update(dt);
    _gameTime += dt;

    // Sync
    zoneManager.playerLevel = leveling.level;
    zoneManager.playerHp = playerHp;
    zoneManager.playerMaxHp = leveling.maxHp;
    leveling.update(dt);

    // Idle auto-move
    if (idleManager.isActive) {
      final nextZoneLevel = zoneManager.currentZone.id < 4
          ? zoneManager.currentZone.requiredLevel + 5
          : 999;
      final dx = idleManager.update(
        dt, playerHp, leveling.maxHp,
        zoneManager.playerDistance,
        zoneManager.currentZoneEndPixel,
        player.position.x,
        zoneManager.getNearestSafeDistance(),
        leveling.level, nextZoneLevel,
      );
      if (dx != 0) player.applyIdleMove(dx);
    }

    // Manual input
    if (!idleManager.active) {
      player.applyInput(dt, inputLeft, inputRight, inputJump);
    } else {
      player.position.y = groundY;
      player.velocity.y = 0;
      player.isGrounded = true;
    }

    // Zone update
    final result = zoneManager.update(dt, player.position.x);

    if (result.hpDrain > 0) {
      playerHp = math.max(0, playerHp - result.hpDrain);
    }

    if (result.blocked) {
      final endPx = zoneManager.currentZoneEndPixel;
      player.position.x = math.min(player.position.x, endPx - 30);
    }

    if (result.zoneChanged) {
      leveling.addXp(XpRewards.completeZone);
    }

    // Enemy
    if (result.enemyEncounter != null) {
      _handleEnemyEncounter(result.enemyEncounter!);
    }

    // Rest spot
    if (result.restSpotFound != null) {
      leveling.addXp(XpRewards.findRestSpot);
      final restore = (leveling.maxHp * result.restSpotFound!.hpRestorePercent).round();
      playerHp = math.min(leveling.maxHp, playerHp + restore);
      if (idleManager.active) {
        idleManager.triggerAlert(AlertType.restSpot,
            'Discovered ${result.restSpotFound!.name}! HP +${(result.restSpotFound!.hpRestorePercent * 100).round()}%');
      }
    }

    // Home base
    final homeRestore = zoneManager.homeBase.update(
        dt, zoneManager.playerDistance, playerHp, leveling.maxHp);
    if (homeRestore > 0) {
      playerHp = math.min(leveling.maxHp, playerHp + homeRestore);
    }

    // Exploration XP
    _exploredDistance = zoneManager.playerDistance;
    while (_exploredDistance - _lastExploreXpDist >= 100) {
      _lastExploreXpDist += 100;
      leveling.addXp(XpRewards.explore100m);
    }

    // Combat result timer
    if (_combatResult != null) {
      _combatResultTimer -= dt;
      if (_combatResultTimer <= 0) _combatResult = null;
    }

    // Creature spawner
    creatureSpawner.update(dt, player.position.x, player.position.y);

    // Catch input
    if (inputCatch && creatureSpawner.canCatch) {
      inputCatch = false;
      final creature = creatureSpawner.catchCreature();
      if (creature != null) {
        leveling.addXp(XpRewards.catchCreature(creature.rarity));
        onAlert?.call('Caught ${creature.name}!');
      }
    }

    // Creature alert in idle
    if (idleManager.active && creatureSpawner.canCatch) {
      idleManager.triggerAlert(AlertType.creature, "TODAY'S CREATURE IS RIGHT HERE!");
      idleManager.toggle();
    }

    // Death
    if (playerHp <= 0) {
      state = GameState.gameOver;
      onStateChanged?.call();
    }

    // Camera
    cameraOffset = math.max(0, player.position.x - size.x / 3);

    onStateChanged?.call();
  }

  void _handleEnemyEncounter(EnemyData enemy) {
    _currentEnemy = enemy;
    if (idleManager.active) {
      if (AutoCombat.canAutoFight(enemy, leveling.level)) {
        _resolveAutoFight(enemy);
      } else {
        idleManager.triggerAlert(AlertType.enemy,
            'Lv.${enemy.level} ${enemy.name} attacks!');
      }
    } else {
      _resolveAutoFight(enemy);
    }
  }

  void _resolveAutoFight(EnemyData enemy) {
    final result = AutoCombat.resolve(enemy, leveling.level, 10);
    playerHp = math.max(0, playerHp - result.damageTaken);
    leveling.addXp(result.xpEarned);
    _combatResult = result;
    _combatResultTimer = 2;
    _currentEnemy = null;
  }

  void dismissIdleAlert() {
    final alertType = idleManager.currentAlert?.type;
    idleManager.dismissAlert();
    if (alertType == AlertType.enemy && _currentEnemy != null) {
      _resolveAutoFight(_currentEnemy!);
    }
  }

  void toggleIdle() => idleManager.toggle();

  @override
  void render(Canvas canvas) {
    // Background
    _renderBackground(canvas);
    super.render(canvas);
    _renderCreature(canvas);
    _renderRestSpots(canvas);
    _renderHome(canvas);
  }

  void _renderBackground(Canvas canvas) {
    final zone = zoneManager.currentZone;
    // Sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, groundY),
      Paint()..color = zone.bgColor,
    );
    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.x, size.y - groundY),
      Paint()..color = zone.groundColor,
    );
    // Transition flash
    if (zoneManager.transitionAlpha > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Color.fromRGBO(255, 255, 255, zoneManager.transitionAlpha * 0.3),
      );
    }
  }

  void _renderCreature(Canvas canvas) {
    if (creatureSpawner.spawned == null || !creatureSpawner.spawned!.active) return;
    final s = creatureSpawner.spawned!;
    final sx = s.x - cameraOffset;
    final sy = s.y + math.sin(_gameTime * 3) * 3; // bob

    // Glow
    if (s.creature.rarity != Rarity.common) {
      final glowColor = rarityColors[s.creature.rarity]!;
      canvas.drawCircle(
        Offset(sx, sy),
        30,
        Paint()..color = glowColor.withValues(alpha: 0.15 + math.sin(_gameTime * 3) * 0.1),
      );
    }

    // Sparkles
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 + _gameTime * 2;
      final dist = 30 + math.sin(_gameTime * 4 + i) * 5;
      final spx = sx + math.cos(angle) * dist;
      final spy = sy + math.sin(angle) * dist;
      canvas.drawCircle(
        Offset(spx, spy), 2,
        Paint()..color = Color.fromRGBO(255, 255, 255, 0.3 + math.sin(_gameTime * 5 + i * 2) * 0.3),
      );
    }

    // Simple creature body
    final bodyPaint = Paint()..color = s.creature.sprite.bodyColor;
    canvas.drawCircle(Offset(sx, sy), 16, bodyPaint);
    // Eyes
    final eyePaint = Paint()..color = s.creature.sprite.eyeColor;
    canvas.drawRect(Rect.fromLTWH(sx - 6, sy - 3, 4, 3), eyePaint);
    canvas.drawRect(Rect.fromLTWH(sx + 2, sy - 3, 4, 3), eyePaint);

    // Catch prompt
    if (creatureSpawner.catchProximity) {
      final tp = TextPaint(
        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontFamily: 'monospace'),
      );
      tp.render(canvas, 'Tap CATCH!', Vector2(sx - 30, sy - 35));
    }
  }

  void _renderRestSpots(Canvas canvas) {
    for (final spot in zoneManager.restSpots.discovered) {
      final px = spot.distance * 2 - cameraOffset;
      if (px < -50 || px > size.x + 50) continue;
      final colors = {
        'spring': const Color(0xFF44aaff),
        'oasis': const Color(0xFF44ffaa),
        'foodCart': const Color(0xFFffaa44),
        'campfire': const Color(0xFFff6644),
      };
      final c = colors[spot.type.name] ?? const Color(0xFFaaaaaa);
      canvas.drawCircle(Offset(px, groundY - 8), 5, Paint()..color = c);
      final tp = TextPaint(
        style: TextStyle(color: const Color(0xFFaaaaaa), fontSize: 9, fontFamily: 'monospace'),
      );
      tp.render(canvas, spot.name, Vector2(px - 20, groundY - 24));
    }
  }

  void _renderHome(Canvas canvas) {
    if (zoneManager.playerDistance > 30) return;
    final homeX = 10.0 - cameraOffset;
    // Campfire logs
    final brownPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(Rect.fromLTWH(homeX + 5, groundY - 15, 4, 15), brownPaint);
    canvas.drawRect(Rect.fromLTWH(homeX + 25, groundY - 15, 4, 15), brownPaint);
    canvas.drawRect(Rect.fromLTWH(homeX + 5, groundY - 15, 24, 4), brownPaint);
    // Fire
    canvas.drawCircle(Offset(homeX + 17, groundY - 6), 6, Paint()..color = const Color(0xFFff6600));
    canvas.drawCircle(Offset(homeX + 17, groundY - 8), 3, Paint()..color = const Color(0xFFffcc00));
    // Label
    final tp = TextPaint(
      style: const TextStyle(color: Color(0xFFffcc00), fontSize: 10, fontFamily: 'monospace'),
    );
    tp.render(canvas, '🏠 HOME', Vector2(homeX + 2, groundY - 30));
  }

  // Getters for HUD overlay
  double get hpRatio => playerHp / leveling.maxHp;
  String get zoneName => zoneManager.currentZone.name;
  double get playerDistance => zoneManager.playerDistance;
  bool get isAtHome => zoneManager.homeBase.isHome;
  CombatResult? get combatResult => _combatResult;
  MonsterDexMeta get meta => GameStorage.getMeta();
}
