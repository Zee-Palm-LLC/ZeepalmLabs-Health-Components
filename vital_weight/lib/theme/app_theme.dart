import 'package:flutter/material.dart';

/// Central palette for the VitalWeight app.
class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF1C1F1E);
  static const Color primaryGreen = Color(0xFF2FBF6D);
  static const Color green = Color(0xFF25B95C);
  static const Color mint = Color(0xFF8EF0BC);
  static const Color softGrey = Color(0xFF8A938D);
  static const Color line = Color(0xFFE7ECE9);

  static const Color bgTop = Color(0xFFE3D6EE);
  static const Color bgMid = Color(0xFFCBE7EA);
  static const Color bgSoft = Color(0xFFF3F6F4);
  static const Color bgBottom = Color(0xFFFFFFFF);

  static const List<Color> backgroundGradient = [
    bgTop,
    bgMid,
    bgSoft,
    bgBottom,
  ];

  static const List<double> backgroundStops = [0.0, 0.28, 0.6, 1.0];

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A1C1F1E),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}

/// App-wide typography helpers.
class AppType {
  AppType._();

  static const String display =
      'Poppins'; // falls back gracefully when unavailable
}
