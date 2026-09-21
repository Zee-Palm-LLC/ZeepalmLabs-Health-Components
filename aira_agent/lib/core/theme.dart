import 'package:flutter/painting.dart';

abstract final class Tone {
  static const flame = Color(0xFFF26A1B);
  static const ember = Color(0xFFE2580B);
  static const blaze = Color(0xFFF7922E);
  static const char = Color(0xFF0B0B0B);
  static const snow = Color(0xFFF2F2F2);
  static const mist = Color(0xFF8C8C8C);
  static const ash = Color(0xFF6E6E6E);
  static const hush = Color(0x66FFFFFF);
}

TextStyle inter(
  double size,
  double weight, {
  Color color = Tone.snow,
  double spacing = 0,
  double? height,
  double? optical,
}) {
  final opsz = optical ?? size.clamp(14.0, 32.0);
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight), FontVariation('opsz', opsz)],
    letterSpacing: spacing,
    height: height,
    color: color,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

TextStyle get transcriptStyle => inter(22, 500, color: Tone.snow, height: 29 / 22, spacing: -0.1);
