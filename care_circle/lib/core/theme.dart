import 'package:flutter/painting.dart';

abstract final class Hue {
  static const canvas = Color(0xFFFBF8F4);
  static const canvasDeep = Color(0xFFF4EEE7);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFEEE8F2);

  static const ink = Color(0xFF2A2230);
  static const inkSoft = Color(0xFF6B6273);
  static const inkMute = Color(0xFFA59CAB);

  static const iris = Color(0xFF7B5CF5);
  static const irisDeep = Color(0xFF6242E4);
  static const irisLight = Color(0xFF9D84FF);
  static const irisSoft = Color(0xFFF0EBFF);
  static const irisMist = Color(0xFFF7F4FF);

  static const sage = Color(0xFF2FAF77);
  static const sageSoft = Color(0xFFE4F6EC);
  static const coral = Color(0xFFEF5F57);
  static const coralSoft = Color(0xFFFDEBE8);
  static const honey = Color(0xFFF2A12B);
  static const honeySoft = Color(0xFFFFF2DC);
  static const blush = Color(0xFFF58DB4);
  static const blushSoft = Color(0xFFFDEAF1);

  static const shadow = Color(0xFF5B3FD0);

  static const irisGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9A7BFF), Color(0xFF6B48EC)],
  );
}

TextStyle jakarta(
  double size,
  double weight, {
  Color color = Hue.ink,
  double spacing = 0,
  double? height,
}) {
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

List<BoxShadow> softShadow([double strength = 1]) {
  return [
    BoxShadow(color: Hue.shadow.withValues(alpha: 0.06 * strength), blurRadius: 24, offset: const Offset(0, 10)),
    BoxShadow(color: Hue.shadow.withValues(alpha: 0.04 * strength), blurRadius: 4, offset: const Offset(0, 1)),
  ];
}
