enum AlertType { enemy, creature, lowHp, rareItem, zoneBoundary, restSpot }

class IdleAlert {
  final AlertType type;
  final String message;
  bool dismissed;

  IdleAlert({required this.type, required this.message, this.dismissed = false});
}

class IdleManager {
  bool active = false;
  double distanceTraveled = 0;
  int itemsCollected = 0;
  double timeElapsed = 0;
  double autoMoveSpeed = 120;
  int direction = 1;
  bool returningToSafe = false;

  IdleAlert? currentAlert;

  bool get isActive => active && currentAlert == null;

  void toggle() {
    active = !active;
    if (active) {
      distanceTraveled = 0;
      itemsCollected = 0;
      timeElapsed = 0;
      direction = 1;
      returningToSafe = false;
    }
  }

  void triggerAlert(AlertType type, String message) {
    currentAlert = IdleAlert(type: type, message: message);
  }

  void dismissAlert() {
    currentAlert = null;
  }

  /// Returns pixel delta X
  double update(
    double dt,
    int playerHp,
    int playerMaxHp,
    double playerDistance,
    double zoneEndPixel,
    double playerPixelX,
    double nearestSafeDistance,
    int playerLevel,
    int nextZoneLevel,
  ) {
    if (!active) return 0;
    timeElapsed += dt;
    if (currentAlert != null) return 0;

    final hpRatio = playerHp / playerMaxHp;
    if (hpRatio < 0.2 && !returningToSafe) {
      triggerAlert(AlertType.lowHp, '⚠️ HP Critical! Returning to safety...');
      returningToSafe = true;
      direction = -1;
      return 0;
    }

    if (returningToSafe && playerDistance <= nearestSafeDistance + 15) {
      returningToSafe = false;
      direction = 1;
    }

    if (direction > 0 && playerPixelX >= zoneEndPixel - 20) {
      if (nextZoneLevel > playerLevel) {
        direction = -1;
        return 0;
      }
    }

    final dx = autoMoveSpeed * dt * direction;
    distanceTraveled += dx.abs() * 0.5;
    return dx;
  }
}
