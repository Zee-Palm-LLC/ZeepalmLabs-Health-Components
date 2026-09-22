import 'package:flutter/painting.dart';

abstract final class Hue {
  static const ink = Color(0xFF0F3B3A);
  static const teal = Color(0xFF0F766E);
  static const aqua = Color(0xFF14B8A6);
  static const orange = Color(0xFFFF8A3D);
  static const green = Color(0xFF4ADE80);
  static const yellow = Color(0xFFFBBF24);
  static const mist = Color(0xFFEEF6F3);

  static const deep = Color(0xFF0B5953);
  static const slate = Color(0xFF3F5553);
  static const gray = Color(0xFF6B7F7C);
  static const hush = Color(0xFF8A9B98);
  static const mint = Color(0xFFE3F3EE);
  static const line = Color(0xFFD5E3DF);
  static const live = Color(0xFF22C55E);
  static const canvas = Color(0xFFF1F8F6);
}

TextStyle jakarta(double size, double weight, {Color color = Hue.ink, double spacing = 0, double? height}) {
  return TextStyle(
    fontFamily: 'Jakarta',
    fontSize: size,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight)],
    letterSpacing: spacing,
    height: height,
    color: color,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

List<BoxShadow> cardShadow([double strength = 1]) {
  return [
    BoxShadow(
      color: const Color(0xFF0F3B3A).withValues(alpha: 0.07 * strength),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: const Color(0xFF0F3B3A).withValues(alpha: 0.04 * strength),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}
