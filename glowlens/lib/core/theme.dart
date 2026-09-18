import 'package:flutter/painting.dart';

abstract final class Palette {
  static const ink = Color(0xFF141414);
  static const inkSoft = Color(0xFF3A3A3C);
  static const muted = Color(0xFF5E5E63);
  static const faint = Color(0xFF9A9AA0);
  static const hairline = Color(0xFFECE6F2);

  static const lilacTop = Color(0xFFEFE4FC);
  static const lilacMid = Color(0xFFF4ECFB);
  static const blush = Color(0xFFF9EEF8);
  static const canvas = Color(0xFFF7F4FA);
  static const surface = Color(0xFFFFFFFF);

  static const violet = Color(0xFFC274EB);
  static const rose = Color(0xFFF185A2);
  static const coral = Color(0xFFFC8C92);
  static const orchid = Color(0xFFB872E8);
  static const periwinkle = Color(0xFF7D8CE6);
  static const good = Color(0xFF34A77A);
  static const button = Color(0xFF1B1B1D);

  static const peach = Color(0xFFFBD9D2);
  static const sky = Color(0xFFC7DAF6);
  static const cream = Color(0xFFFEF0DC);
  static const mint = Color(0xFFD3F3F4);
  static const petal = Color(0xFFFBC6C8);
  static const lavender = Color(0xFFE3D2F7);

  static const brand = LinearGradient(colors: [violet, rose, coral], stops: [0, 0.62, 1]);
  static const brandSoft = LinearGradient(colors: [Color(0xFFCE8BF0), Color(0xFFF59BB2)]);
  static const ring = [Color(0xFFF694A6), Color(0xFFE08BC6), Color(0xFFC981E7), Color(0xFFC981E7)];
}

TextStyle inter(double size, int weight, {Color color = Palette.ink, double? height, double spacing = -0.2}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: FontWeight.values[(weight ~/ 100 - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight.toDouble())],
    color: color,
    height: height,
    letterSpacing: spacing,
    decoration: TextDecoration.none,
  );
}
