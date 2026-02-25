class HomeBase {
  double _restoreTimer = 0;
  bool _isHome = false;

  bool get isHome => _isHome;

  bool checkPlayerAtHome(double playerDistance) {
    _isHome = playerDistance < 20;
    return _isHome;
  }

  /// Returns HP to restore this frame
  int update(double dt, double playerDistance, int currentHp, int maxHp) {
    if (!checkPlayerAtHome(playerDistance)) {
      _restoreTimer = 0;
      return 0;
    }
    _restoreTimer += dt;
    if (_restoreTimer >= 0.5) {
      _restoreTimer -= 0.5;
      final restore = (maxHp * 0.1).ceil().clamp(0, maxHp - currentHp);
      return restore < 0 ? 0 : restore;
    }
    return 0;
  }
}
