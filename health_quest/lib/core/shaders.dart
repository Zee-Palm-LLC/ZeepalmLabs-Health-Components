import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// Loads the atmosphere program once, before the first frame.
///
/// If it will not compile on this platform the screen still works: every
/// caller falls back to a painted layer, so a shader failure costs sparkle,
/// never the screen.
class Shaders {
  Shaders._();

  static ui.FragmentProgram? _stardust;
  static bool _tried = false;

  static bool get ready => _stardust != null;

  static Future<void> warmUp() async {
    if (_tried) return;
    _tried = true;
    try {
      _stardust = await ui.FragmentProgram.fromAsset('shaders/stardust.frag');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('stardust.frag unavailable, painting the fallback: $e');
      }
    }
  }

  static ui.FragmentShader? stardust() => _stardust?.fragmentShader();
}
