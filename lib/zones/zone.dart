import 'dart:ui';
import '../creatures/types.dart' show Rarity;

class Zone {
  final int id;
  final String name;
  final double distanceStart;
  final double distanceEnd; // double.infinity for last zone
  final int requiredLevel;
  final double hpDrainPerMin;
  final int enemyAtkMin;
  final int enemyAtkMax;
  final int enemyHpMin;
  final int enemyHpMax;
  final List<Rarity> creatureRarities;
  final Color bgColor;
  final Color groundColor;
  final String description;

  const Zone({
    required this.id,
    required this.name,
    required this.distanceStart,
    required this.distanceEnd,
    required this.requiredLevel,
    required this.hpDrainPerMin,
    required this.enemyAtkMin,
    required this.enemyAtkMax,
    required this.enemyHpMin,
    required this.enemyHpMax,
    required this.creatureRarities,
    required this.bgColor,
    required this.groundColor,
    required this.description,
  });
}

const List<Zone> zones = [
  Zone(
    id: 1,
    name: 'Peaceful Meadow',
    distanceStart: 0,
    distanceEnd: 500,
    requiredLevel: 1,
    hpDrainPerMin: 1,
    enemyAtkMin: 2, enemyAtkMax: 5,
    enemyHpMin: 10, enemyHpMax: 25,
    creatureRarities: [Rarity.common],
    bgColor: Color(0xFF1a2a1a),
    groundColor: Color(0xFF3a5a28),
    description: 'Soft grass sways in a gentle breeze.',
  ),
  Zone(
    id: 2,
    name: 'Whispering Forest',
    distanceStart: 500,
    distanceEnd: 1500,
    requiredLevel: 5,
    hpDrainPerMin: 3,
    enemyAtkMin: 8, enemyAtkMax: 15,
    enemyHpMin: 30, enemyHpMax: 60,
    creatureRarities: [Rarity.common, Rarity.rare],
    bgColor: Color(0xFF0d1a0d),
    groundColor: Color(0xFF2a3a20),
    description: 'Ancient trees loom overhead.',
  ),
  Zone(
    id: 3,
    name: 'Scorched Highlands',
    distanceStart: 1500,
    distanceEnd: 3000,
    requiredLevel: 15,
    hpDrainPerMin: 5,
    enemyAtkMin: 15, enemyAtkMax: 30,
    enemyHpMin: 60, enemyHpMax: 120,
    creatureRarities: [Rarity.rare, Rarity.epic],
    bgColor: Color(0xFF2a1a0a),
    groundColor: Color(0xFF5a3a1a),
    description: 'Cracked earth radiates heat.',
  ),
  Zone(
    id: 4,
    name: 'Abyssal Edge',
    distanceStart: 3000,
    distanceEnd: double.infinity,
    requiredLevel: 30,
    hpDrainPerMin: 10,
    enemyAtkMin: 30, enemyAtkMax: 60,
    enemyHpMin: 120, enemyHpMax: 300,
    creatureRarities: [Rarity.epic, Rarity.legendary],
    bgColor: Color(0xFF0a0a1a),
    groundColor: Color(0xFF1a1a3a),
    description: 'Reality warps at the edge of the world.',
  ),
];

Zone getZoneAtDistance(double distance) {
  for (int i = zones.length - 1; i >= 0; i--) {
    if (distance >= zones[i].distanceStart) return zones[i];
  }
  return zones[0];
}
