import '../data/storage.dart';

enum RestSpotType { oasis, foodCart, spring, campfire }

class RestSpotData {
  final String id;
  final String name;
  final double distance;
  final int zoneId;
  final double hpRestorePercent;
  bool discovered;
  final RestSpotType type;

  RestSpotData({
    required this.id,
    required this.name,
    required this.distance,
    required this.zoneId,
    required this.hpRestorePercent,
    this.discovered = false,
    required this.type,
  });
}

final _spotTemplates = [
  RestSpotData(id: 'rest_0', name: 'Meadow Spring', distance: 120, zoneId: 1, hpRestorePercent: 0.5, type: RestSpotType.spring),
  RestSpotData(id: 'rest_1', name: "Farmer's Cart", distance: 280, zoneId: 1, hpRestorePercent: 0.4, type: RestSpotType.foodCart),
  RestSpotData(id: 'rest_2', name: 'Sunny Clearing', distance: 430, zoneId: 1, hpRestorePercent: 0.3, type: RestSpotType.campfire),
  RestSpotData(id: 'rest_3', name: 'Hidden Pond', distance: 800, zoneId: 2, hpRestorePercent: 0.4, type: RestSpotType.spring),
  RestSpotData(id: 'rest_4', name: 'Mushroom Grove', distance: 1200, zoneId: 2, hpRestorePercent: 0.35, type: RestSpotType.oasis),
  RestSpotData(id: 'rest_5', name: 'Lava Oasis', distance: 2200, zoneId: 3, hpRestorePercent: 0.3, type: RestSpotType.oasis),
  RestSpotData(id: 'rest_6', name: 'Void Sanctuary', distance: 3800, zoneId: 4, hpRestorePercent: 0.3, type: RestSpotType.campfire),
];

class RestSpotManager {
  late final List<RestSpotData> spots;

  RestSpotManager() {
    final saved = GameStorage.getDiscoveredRestSpots();
    spots = _spotTemplates.map((t) => RestSpotData(
      id: t.id, name: t.name, distance: t.distance, zoneId: t.zoneId,
      hpRestorePercent: t.hpRestorePercent, type: t.type,
      discovered: saved.contains(t.id),
    )).toList();
  }

  List<RestSpotData> get discovered => spots.where((s) => s.discovered).toList();

  RestSpotData? checkDiscovery(double playerDistance) {
    for (final spot in spots) {
      if (!spot.discovered && (spot.distance - playerDistance).abs() < 15) {
        spot.discovered = true;
        _save();
        return spot;
      }
    }
    return null;
  }

  int useSpot(String spotId, int maxHp) {
    final spot = spots.firstWhere((s) => s.id == spotId, orElse: () => spots[0]);
    if (!spot.discovered) return 0;
    return (maxHp * spot.hpRestorePercent).round();
  }

  void _save() {
    GameStorage.saveDiscoveredRestSpots(
      spots.where((s) => s.discovered).map((s) => s.id).toSet(),
    );
  }
}
