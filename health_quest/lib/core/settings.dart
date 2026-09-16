import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings extends ChangeNotifier {
  GameSettings._();

  static final GameSettings instance = GameSettings._();

  static const String _kSound = 'settings.sound';
  static const String _kVolume = 'settings.volume';
  static const String _kHaptics = 'settings.haptics';
  static const String _kReminders = 'settings.reminders';
  static const String _kStreakAlerts = 'settings.streakAlerts';

  bool _sound = true;
  double _volume = 0.8;
  bool _haptics = true;
  bool _reminders = true;
  bool _streakAlerts = true;

  bool get sound => _sound;
  double get volume => _volume;
  bool get haptics => _haptics;
  bool get reminders => _reminders;
  bool get streakAlerts => _streakAlerts;

  set sound(bool v) => _set(() => _sound = v, (p) => p.setBool(_kSound, v));
  set volume(double v) {
    final clamped = v.clamp(0.0, 1.0);
    _set(() => _volume = clamped, (p) => p.setDouble(_kVolume, clamped));
  }

  set haptics(bool v) =>
      _set(() => _haptics = v, (p) => p.setBool(_kHaptics, v));
  set reminders(bool v) =>
      _set(() => _reminders = v, (p) => p.setBool(_kReminders, v));
  set streakAlerts(bool v) =>
      _set(() => _streakAlerts = v, (p) => p.setBool(_kStreakAlerts, v));

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _sound = p.getBool(_kSound) ?? _sound;
      _volume = p.getDouble(_kVolume) ?? _volume;
      _haptics = p.getBool(_kHaptics) ?? _haptics;
      _reminders = p.getBool(_kReminders) ?? _reminders;
      _streakAlerts = p.getBool(_kStreakAlerts) ?? _streakAlerts;
      notifyListeners();
    } catch (_) {
    }
  }

  void _set(
    void Function() apply,
    Future<bool> Function(SharedPreferences) save,
  ) {
    apply();
    notifyListeners();
    SharedPreferences.getInstance().then(save).ignore();
  }

  @visibleForTesting
  void reset() {
    _sound = true;
    _volume = 0.8;
    _haptics = true;
    _reminders = true;
    _streakAlerts = true;
    notifyListeners();
  }
}
