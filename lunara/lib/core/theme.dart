import 'package:flutter/material.dart';

class Hue {
  static const night = Color(0xFF241634);
  static const deep = Color(0xFF2D1B42);
  static const deepCard = Color(0xFF362050);
  static const lift = Color(0xFF452C60);
  static const veil = Color(0xFF5A3D75);

  static const canvas = Color(0xFF1B1029);
  static const surface = Color(0xFF2B1B40);
  static const mist = Color(0xFF35234C);
  static const tile = Color(0xFF3E2A59);

  static const ink = Color(0xFFF4EFFA);
  static const inkSoft = Color(0xFFCABEDA);
  static const inkMuted = Color(0xFF9D90B1);
  static const inkFaint = Color(0xFF6F6182);

  static const rose = Color(0xFFFF6F8B);
  static const peach = Color(0xFFFFA36C);
  static const amber = Color(0xFFFFC163);
  static const mint = Color(0xFF3FC6A0);
  static const violet = Color(0xFFA279E8);
  static const sky = Color(0xFF7FB2F0);

  static const menstrual = Color(0xFFFF6B7A);
  static const follicular = Color(0xFF3FC6A0);
  static const ovulation = Color(0xFFFFB23F);
  static const luteal = Color(0xFFA279E8);

  static const moonlight = Color(0xFFFFEEC9);

  static const phases = [menstrual, follicular, ovulation, luteal];
}

const warmGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Hue.rose, Hue.peach],
);

FontWeight _weight(int value) {
  if (value >= 700) return FontWeight.w700;
  if (value >= 600) return FontWeight.w600;
  if (value >= 500) return FontWeight.w500;
  return FontWeight.w400;
}

TextStyle display(double size, int weight, {Color color = Hue.ink, double spacing = 0, double height = 1.05}) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: size,
    height: height,
    color: color,
    letterSpacing: spacing,
    fontWeight: _weight(weight),
  );
}

TextStyle sans(double size, int weight, {Color color = Hue.inkSoft, double spacing = 0, double height = 1.25}) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: size,
    height: height,
    color: color,
    letterSpacing: spacing,
    fontWeight: _weight(weight),
  );
}

TextStyle serif(double size, int weight, {Color color = Hue.ink, double spacing = 0, double height = 1.2}) {
  return display(size, weight, color: color, spacing: spacing, height: height);
}

List<BoxShadow> softShadow([double scale = 1]) {
  return [
    BoxShadow(color: Color.fromRGBO(10, 4, 20, 0.34 * scale), blurRadius: 26 * scale, offset: Offset(0, 14 * scale)),
    BoxShadow(color: Color.fromRGBO(10, 4, 20, 0.18 * scale), blurRadius: 6 * scale, offset: Offset(0, 2 * scale)),
  ];
}

List<BoxShadow> lifted([Color tone = Hue.rose, double scale = 1]) {
  return [
    BoxShadow(
      color: tone.withValues(alpha: 0.34 * scale),
      blurRadius: 22 * scale,
      offset: Offset(0, 10 * scale),
    ),
    BoxShadow(
      color: tone.withValues(alpha: 0.18 * scale),
      blurRadius: 8 * scale,
      offset: Offset(0, 3 * scale),
    ),
  ];
}
