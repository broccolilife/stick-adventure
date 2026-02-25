import 'dart:ui';

enum Element {
  fire,
  water,
  earth,
  electric,
  dark,
  light,
  chaos;

  String get label => name.toUpperCase();
}

enum Rarity {
  common,
  rare,
  epic,
  legendary;

  String get label => name.toUpperCase();

  int get multiplier {
    switch (this) {
      case Rarity.common:
        return 1;
      case Rarity.rare:
        return 2;
      case Rarity.epic:
        return 4;
      case Rarity.legendary:
        return 8;
    }
  }
}

enum ItemType { food, weapon, shield, accessory }

class Skill {
  final String name;
  final String description;
  final int power;
  final Element element;

  const Skill({
    required this.name,
    required this.description,
    required this.power,
    required this.element,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'power': power,
        'element': element.name,
      };

  factory Skill.fromJson(Map<String, dynamic> j) => Skill(
        name: j['name'],
        description: j['description'],
        power: j['power'],
        element: Element.values.byName(j['element']),
      );
}

class CreatureStats {
  final int atk;
  final int def;
  final int spd;
  final int hp;

  const CreatureStats(
      {required this.atk,
      required this.def,
      required this.spd,
      required this.hp});

  Map<String, dynamic> toJson() =>
      {'atk': atk, 'def': def, 'spd': spd, 'hp': hp};

  factory CreatureStats.fromJson(Map<String, dynamic> j) => CreatureStats(
        atk: j['atk'],
        def: j['def'],
        spd: j['spd'],
        hp: j['hp'],
      );
}

enum SpriteShape { blob, spiky, tall, round, angular, wispy }

class CreatureSprite {
  final Color bodyColor;
  final Color eyeColor;
  final Color accentColor;
  final SpriteShape shape;
  final List<String> features;

  const CreatureSprite({
    required this.bodyColor,
    required this.eyeColor,
    required this.accentColor,
    required this.shape,
    required this.features,
  });

  Map<String, dynamic> toJson() => {
        'bodyColor': bodyColor.toARGB32(),
        'eyeColor': eyeColor.toARGB32(),
        'accentColor': accentColor.toARGB32(),
        'shape': shape.name,
        'features': features,
      };

  factory CreatureSprite.fromJson(Map<String, dynamic> j) => CreatureSprite(
        bodyColor: Color(j['bodyColor']),
        eyeColor: Color(j['eyeColor']),
        accentColor: Color(j['accentColor']),
        shape: SpriteShape.values.byName(j['shape']),
        features: List<String>.from(j['features']),
      );
}

class Item {
  final String id;
  final String name;
  final ItemType type;
  final String description;
  final CreatureStats statBoost;
  final Rarity rarity;

  const Item({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.statBoost,
    required this.rarity,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'description': description,
        'statBoost': statBoost.toJson(),
        'rarity': rarity.name,
      };

  factory Item.fromJson(Map<String, dynamic> j) => Item(
        id: j['id'],
        name: j['name'],
        type: ItemType.values.byName(j['type']),
        description: j['description'],
        statBoost: CreatureStats.fromJson(j['statBoost']),
        rarity: Rarity.values.byName(j['rarity']),
      );
}

class Creature {
  final String id;
  final String date;
  final String name;
  final String lore;
  final String trendSource;
  final Element element;
  final Rarity rarity;
  final CreatureStats stats;
  final List<Skill> skills;
  final Item item;
  final CreatureSprite sprite;
  bool caught;

  Creature({
    required this.id,
    required this.date,
    required this.name,
    required this.lore,
    required this.trendSource,
    required this.element,
    required this.rarity,
    required this.stats,
    required this.skills,
    required this.item,
    required this.sprite,
    this.caught = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'name': name,
        'lore': lore,
        'trendSource': trendSource,
        'element': element.name,
        'rarity': rarity.name,
        'stats': stats.toJson(),
        'skills': skills.map((s) => s.toJson()).toList(),
        'item': item.toJson(),
        'sprite': sprite.toJson(),
        'caught': caught,
      };

  factory Creature.fromJson(Map<String, dynamic> j) => Creature(
        id: j['id'],
        date: j['date'],
        name: j['name'],
        lore: j['lore'],
        trendSource: j['trendSource'],
        element: Element.values.byName(j['element']),
        rarity: Rarity.values.byName(j['rarity']),
        stats: CreatureStats.fromJson(j['stats']),
        skills: (j['skills'] as List).map((s) => Skill.fromJson(s)).toList(),
        item: Item.fromJson(j['item']),
        sprite: CreatureSprite.fromJson(j['sprite']),
        caught: j['caught'] ?? false,
      );
}

class MonsterDexMeta {
  int currentStreak;
  int longestStreak;
  String? lastCaughtDate;
  int totalCaught;

  MonsterDexMeta({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCaughtDate,
    this.totalCaught = 0,
  });

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCaughtDate': lastCaughtDate,
        'totalCaught': totalCaught,
      };

  factory MonsterDexMeta.fromJson(Map<String, dynamic> j) => MonsterDexMeta(
        currentStreak: j['currentStreak'] ?? 0,
        longestStreak: j['longestStreak'] ?? 0,
        lastCaughtDate: j['lastCaughtDate'],
        totalCaught: j['totalCaught'] ?? 0,
      );
}

const Map<Element, Color> elementColors = {
  Element.fire: Color(0xFFff6633),
  Element.water: Color(0xFF3399ff),
  Element.earth: Color(0xFF88aa44),
  Element.electric: Color(0xFFffcc00),
  Element.dark: Color(0xFF8844aa),
  Element.light: Color(0xFFffeeaa),
  Element.chaos: Color(0xFFff44aa),
};

const Map<Rarity, Color> rarityColors = {
  Rarity.common: Color(0xFF999999),
  Rarity.rare: Color(0xFF4488ff),
  Rarity.epic: Color(0xFFaa44ff),
  Rarity.legendary: Color(0xFFffaa00),
};
