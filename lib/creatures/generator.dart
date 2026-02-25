import 'dart:math' as math;
import 'dart:ui';
import 'types.dart';

/// Seeded PRNG (mulberry32) - matches TypeScript version exactly
class Mulberry32 {
  int _seed;

  Mulberry32(this._seed);

  double next() {
    _seed = (_seed + 0x6D2B79F5) & 0xFFFFFFFF;
    int t = ((_seed ^ (_seed >> 15)) * (1 | _seed)) & 0xFFFFFFFF;
    t = ((t + ((t ^ (t >> 7)) * (61 | t)) & 0xFFFFFFFF) ^ t) & 0xFFFFFFFF;
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296.0;
  }
}

int _dateToSeed(String date) {
  int h = 0;
  for (int i = 0; i < date.length; i++) {
    h = (31 * h + date.codeUnitAt(i)) & 0xFFFFFFFF;
    // Sign-extend to match JS |0
    if (h >= 0x80000000) h -= 0x100000000;
  }
  return h;
}

const _elements = Element.values;
const _rarities = [
  Rarity.common, Rarity.common, Rarity.common,
  Rarity.rare, Rarity.rare,
  Rarity.epic,
  Rarity.legendary,
];
const _itemTypes = ItemType.values;
const _shapes = SpriteShape.values;
const _features = ['horns', 'tail', 'wings', 'antenna', 'spikes', 'halo', 'fangs', 'spots'];

const _syllables = [
  'zor', 'mew', 'pik', 'glo', 'bun', 'sha', 'rex', 'nyx', 'flu', 'tor',
  'dra', 'whi', 'kra', 'loo', 'ven', 'hex', 'umi', 'sol', 'vex', 'arc',
  'fen', 'ryu', 'ash', 'ori', 'zen', 'lux', 'kor', 'dai', 'chi', 'boo',
];

const Map<Element, List<String>> _skillNames = {
  Element.fire: ['Ember Blast', 'Flame Dash', 'Inferno Ring', 'Heat Wave'],
  Element.water: ['Tidal Surge', 'Bubble Shield', 'Aqua Jet', 'Whirlpool'],
  Element.earth: ['Stone Slam', 'Quake Stomp', 'Vine Whip', 'Mud Slide'],
  Element.electric: ['Spark Bolt', 'Thunder Clap', 'Static Shock', 'Volt Rush'],
  Element.dark: ['Shadow Strike', 'Void Pull', 'Night Slash', 'Hex Curse'],
  Element.light: ['Radiant Beam', 'Holy Shield', 'Flash Burst', 'Purify'],
  Element.chaos: ['Chaos Rift', 'Reality Warp', 'Entropy Wave', 'Glitch Pulse'],
};

const Map<ItemType, List<String>> _itemNames = {
  ItemType.food: ['Star Berry', 'Moon Fruit', 'Fire Pepper', 'Crystal Apple', 'Shadow Plum'],
  ItemType.weapon: ['Spark Dagger', 'Thorn Blade', 'Frost Bow', 'Thunder Staff', 'Void Edge'],
  ItemType.shield: ['Stone Guard', 'Light Barrier', 'Flame Ward', 'Ice Shell', 'Dark Veil'],
  ItemType.accessory: ['Lucky Charm', 'Speed Ring', 'Power Band', 'Wisdom Gem', 'Ghost Cloak'],
};

const _loreTemplates = [
  'Born from the essence of {trend}, this creature radiates {element} energy.',
  'Legends say {name} appeared when {trend} swept across the land.',
  'A mysterious being linked to {trend}, wielding the power of {element}.',
  'When {trend} echoed through the world, {name} emerged from the shadows.',
  'Drawn to the energy of {trend}, this {element} creature seeks worthy trainers.',
];

const _trendSources = [
  'cosmic alignment', 'solar flare activity', 'deep ocean currents',
  'northern lights surge', 'volcanic tremors', 'meteor shower',
  'tidal bloom event', 'thunderstorm season', 'aurora borealis peak',
  'crystal cave resonance', 'ancient ruins activation', 'forest awakening',
  'digital signal burst', 'magnetic pole shift', 'eclipse aftermath',
];

Color _hslToColor(double h, double s, double l) {
  s /= 100;
  l /= 100;
  final a = s * math.min(l, 1 - l);
  double f(int n) {
    final k = (n + h / 30) % 12;
    return l - a * math.max(math.min(math.min(k - 3, 9 - k), 1), -1);
  }
  return Color.fromARGB(255, (f(0) * 255).round(), (f(8) * 255).round(), (f(4) * 255).round());
}

double _rarityMultiplier(Rarity r) {
  switch (r) {
    case Rarity.common: return 1.0;
    case Rarity.rare: return 1.3;
    case Rarity.epic: return 1.6;
    case Rarity.legendary: return 2.0;
  }
}

String getTodayDateStr() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

Creature getCreatureForDate(String dateStr) {
  // TODO: check for AI-generated creatures from asset
  return generateCreature(dateStr);
}

Creature generateCreature(String dateStr) {
  final rng = Mulberry32(_dateToSeed(dateStr));

  final element = _elements[(rng.next() * _elements.length).floor()];
  final rarity = _rarities[(rng.next() * _rarities.length).floor()];

  // Name
  final syllableCount = 2 + (rng.next() > 0.6 ? 1 : 0);
  var name = '';
  for (int i = 0; i < syllableCount; i++) {
    name += _syllables[(rng.next() * _syllables.length).floor()];
  }
  name = name[0].toUpperCase() + name.substring(1);

  final rm = _rarityMultiplier(rarity);
  final stats = CreatureStats(
    atk: ((5 + rng.next() * 15) * rm).floor(),
    def: ((5 + rng.next() * 15) * rm).floor(),
    spd: ((5 + rng.next() * 15) * rm).floor(),
    hp: ((20 + rng.next() * 30) * rm).floor(),
  );

  // Skills
  final skillPool = _skillNames[element]!;
  final skill1Idx = (rng.next() * skillPool.length).floor();
  var skill2Idx = (rng.next() * skillPool.length).floor();
  if (skill2Idx == skill1Idx) skill2Idx = (skill2Idx + 1) % skillPool.length;

  final skills = <Skill>[
    Skill(
      name: skillPool[skill1Idx],
      description: 'A ${element.name} attack',
      power: (10 + rng.next() * 20 * rm).floor(),
      element: element,
    ),
  ];
  if (rarity != Rarity.common) {
    final el2 = rng.next() > 0.7
        ? _elements[(rng.next() * _elements.length).floor()]
        : element;
    skills.add(Skill(
      name: skillPool[skill2Idx],
      description: 'A powerful ${el2.name} move',
      power: (15 + rng.next() * 25 * rm).floor(),
      element: el2,
    ));
  }

  // Item
  final itemType = _itemTypes[(rng.next() * _itemTypes.length).floor()];
  final itemNameList = _itemNames[itemType]!;
  final itemName = itemNameList[(rng.next() * itemNameList.length).floor()];
  final item = Item(
    id: '$dateStr-item',
    name: itemName,
    type: itemType,
    description: 'A ${rarity.name} ${itemType.name} dropped by $name',
    statBoost: CreatureStats(
      atk: itemType == ItemType.weapon ? (2 + rng.next() * 5 * rm).floor() : 0,
      def: itemType == ItemType.shield ? (2 + rng.next() * 5 * rm).floor() : 0,
      spd: itemType == ItemType.accessory ? (1 + rng.next() * 3 * rm).floor() : 0,
      hp: itemType == ItemType.food ? (5 + rng.next() * 10 * rm).floor() : 0,
    ),
    rarity: rarity,
  );

  // Sprite
  final hue = (rng.next() * 360).floor().toDouble();
  final shape = _shapes[(rng.next() * _shapes.length).floor()];
  final featureCount = 1 + (rng.next() * 3).floor();
  final features = <String>[];
  for (int i = 0; i < featureCount; i++) {
    final f = _features[(rng.next() * _features.length).floor()];
    if (!features.contains(f)) features.add(f);
  }
  final sprite = CreatureSprite(
    bodyColor: _hslToColor(hue, 60 + rng.next() * 30, 40 + rng.next() * 20),
    eyeColor: _hslToColor((hue + 180) % 360, 80, 70),
    accentColor: _hslToColor((hue + 90) % 360, 70, 50),
    shape: shape,
    features: features,
  );

  // Lore
  final trendSource = _trendSources[(rng.next() * _trendSources.length).floor()];
  final loreTemplate = _loreTemplates[(rng.next() * _loreTemplates.length).floor()];
  final lore = loreTemplate
      .replaceAll('{trend}', trendSource)
      .replaceAll('{element}', element.name)
      .replaceAll('{name}', name);

  return Creature(
    id: dateStr,
    date: dateStr,
    name: name,
    lore: lore,
    trendSource: trendSource,
    element: element,
    rarity: rarity,
    stats: stats,
    skills: skills,
    item: item,
    sprite: sprite,
  );
}
