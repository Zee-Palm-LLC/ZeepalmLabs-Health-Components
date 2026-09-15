import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// Loads the fragment programs once and hands out shaders.
///
/// Both programs are small; loading them up front at app start means the
/// first frame of the orb is already the live one and never a fallback.
class Shaders {
  Shaders._();

  static ui.FragmentProgram? _orb;
  static ui.FragmentProgram? _aurora;
  static bool _failed = false;

  static bool get ready => _orb != null && _aurora != null;
  static bool get failed => _failed;

  static Future<void> warmUp() async {
    if (ready || _failed) return;
    try {
      final results = await Future.wait(<Future<ui.FragmentProgram>>[
        ui.FragmentProgram.fromAsset('shaders/orb.frag'),
        ui.FragmentProgram.fromAsset('shaders/aurora.frag'),
      ]);
      _orb = results[0];
      _aurora = results[1];
    } catch (e, st) {
      _failed = true;
      if (kDebugMode) {
        debugPrint('Shaders unavailable, using painted fallbacks: $e\n$st');
      }
    }
  }

  static ui.FragmentShader? orb() => _orb?.fragmentShader();
  static ui.FragmentShader? aurora() => _aurora?.fragmentShader();
}
