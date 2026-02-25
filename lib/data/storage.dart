import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../creatures/types.dart';

class GameStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs!;

  // ---- MonsterDex ----

  static void saveCaughtCreature(Creature creature) {
    creature.caught = true;
    prefs.setString('monsterdex-${creature.id}', jsonEncode(creature.toJson()));
    _updateMetaOnCatch(creature.date);
    addItemToInventory(creature.item);
  }

  static Creature? getCreature(String dateStr) {
    final raw = prefs.getString('monsterdex-$dateStr');
    if (raw == null) return null;
    return Creature.fromJson(jsonDecode(raw));
  }

  static bool isCreatureCaught(String dateStr) {
    final c = getCreature(dateStr);
    return c?.caught == true;
  }

  static MonsterDexMeta getMeta() {
    final raw = prefs.getString('monsterdex-meta');
    if (raw != null) return MonsterDexMeta.fromJson(jsonDecode(raw));
    return MonsterDexMeta();
  }

  static void _updateMetaOnCatch(String dateStr) {
    final meta = getMeta();
    meta.totalCaught++;
    if (meta.lastCaughtDate != null) {
      final last = DateTime.parse(meta.lastCaughtDate!);
      final cur = DateTime.parse(dateStr);
      final diff = cur.difference(last).inDays;
      if (diff == 1) {
        meta.currentStreak++;
      } else if (diff > 1) {
        meta.currentStreak = 1;
      }
    } else {
      meta.currentStreak = 1;
    }
    meta.longestStreak =
        meta.currentStreak > meta.longestStreak ? meta.currentStreak : meta.longestStreak;
    meta.lastCaughtDate = dateStr;
    prefs.setString('monsterdex-meta', jsonEncode(meta.toJson()));
  }

  static Map<int, Creature> getCaughtForMonth(int year, int month) {
    final result = <int, Creature>{};
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int d = 1; d <= daysInMonth; d++) {
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      final creature = getCreature(dateStr);
      if (creature?.caught == true) result[d] = creature!;
    }
    return result;
  }

  // ---- Inventory ----

  static List<Item> getInventory() {
    final raw = prefs.getString('monsterdex-inventory');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => Item.fromJson(j)).toList();
  }

  static void addItemToInventory(Item item) {
    final inv = getInventory();
    inv.add(item);
    prefs.setString('monsterdex-inventory', jsonEncode(inv.map((i) => i.toJson()).toList()));
  }

  static void removeItemFromInventory(String itemId) {
    final inv = getInventory();
    inv.removeWhere((i) => i.id == itemId);
    prefs.setString('monsterdex-inventory', jsonEncode(inv.map((i) => i.toJson()).toList()));
  }

  // ---- Player State ----

  static void savePlayerState({
    required int level,
    required int xp,
    required int hp,
    required double distance,
  }) {
    prefs.setString('stick_player', jsonEncode({
      'level': level,
      'xp': xp,
      'hp': hp,
      'distance': distance,
    }));
  }

  static Map<String, dynamic>? loadPlayerState() {
    final raw = prefs.getString('stick_player');
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  // ---- Rest Spots ----

  static Set<String> getDiscoveredRestSpots() {
    final raw = prefs.getString('stick_rest_spots');
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw));
  }

  static void saveDiscoveredRestSpots(Set<String> ids) {
    prefs.setString('stick_rest_spots', jsonEncode(ids.toList()));
  }

  // ---- Leveling ----

  static void saveLeveling(int level, int xp) {
    prefs.setString('stick_leveling', jsonEncode({'level': level, 'xp': xp}));
  }

  static Map<String, dynamic>? loadLeveling() {
    final raw = prefs.getString('stick_leveling');
    if (raw == null) return null;
    return jsonDecode(raw);
  }
}
