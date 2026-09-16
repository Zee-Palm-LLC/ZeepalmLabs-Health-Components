import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

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
