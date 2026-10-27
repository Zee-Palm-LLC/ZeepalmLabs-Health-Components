import 'package:flutter/foundation.dart';

/// Tiny shared app state: the check-in feeds the Home summary live.
abstract final class AppState {
  static final pain = ValueNotifier<int>(0); // 0..4, Home shows "Low" until a check-in
  static final painChecked = ValueNotifier<bool>(false);
  static final done = ValueNotifier<Set<int>>({0}); // completed exercise indices

  static const painWords = ['Low', 'Mild', 'Moderate', 'High', 'Very high'];

  static int get recovery => 84 - (painChecked.value ? (pain.value - 0) * 4 : 0);
}
