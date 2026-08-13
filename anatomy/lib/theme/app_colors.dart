import 'package:flutter/material.dart';

/// Clinical Atelier palette — cool mist surfaces, deep teal ink, bone whites.
abstract final class AppColors {
  static const Color ink = Color(0xFF142428);
  static const Color inkSoft = Color(0xFF2A3D42);
  static const Color muted = Color(0xFF6B7C80);
  static const Color mutedLight = Color(0xFF93A3A7);

  static const Color background = Color(0xFFF3F6F5);
  static const Color backgroundDeep = Color(0xFFE8EEEC);
  static const Color surface = Color(0xFFFBFCFB);
  static const Color surfaceRaised = Color(0xFFFFFFFF);

  static const Color accent = Color(0xFF1B7A6C);
  static const Color accentSoft = Color(0xFFD5EDE8);
  static const Color accentMuted = Color(0xFF4A9E90);
  static const Color accentDeep = Color(0xFF0F5A50);

  static const Color border = Color(0xFFDCE5E2);
  static const Color borderStrong = Color(0xFFC5D2CE);

  static const Color highlight = Color(0xFFE8A87C);
  static const Color danger = Color(0xFFC45C5C);
  static const Color success = Color(0xFF3D8B6E);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F5A50),
      Color(0xFF1B7A6C),
      Color(0xFF2A8F7E),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient mistGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF7FAF9),
      Color(0xFFF3F6F5),
      Color(0xFFE8EEEC),
    ],
  );

  static const LinearGradient avatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B7A6C), Color(0xFF0F5A50)],
  );
}
