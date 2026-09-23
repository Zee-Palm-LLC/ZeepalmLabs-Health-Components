import 'package:flutter/material.dart';

class Ember {
  const Ember._();

  static const void_ = Color(0xFF080302);
  static const night = Color(0xFF130804);
  static const rust = Color(0xFF3B1409);
  static const clay = Color(0xFF7A2A0C);
  static const flame = Color(0xFFC85A14);
  static const amber = Color(0xFFF2891C);
  static const gold = Color(0xFFFFC63C);
  static const cream = Color(0xFFFFF2DE);
  static const ash = Color(0xFFD9BCA6);
}

const goldGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFF5821A), Color(0xFFF99A24), Color(0xFFFFC63C)],
  stops: [0.0, 0.45, 1.0],
);

const fabGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF79218), Color(0xFFFFB939), Color(0xFFFFD766)],
  stops: [0.0, 0.55, 1.0],
);

Color panelFill(double opacity) => Color(0xFF0A0402).withValues(alpha: opacity);

const hairline = Color(0x2EFFE2C4);
const hairlineSoft = Color(0x1AFFE2C4);

class Mood {
  const Mood(this.name, this.tint, this.curve);

  final String name;
  final Color tint;
  final double curve;

  static const all = [
    Mood('Heavy', Color(0xFF8C93C8), -1.0),
    Mood('Gloomy', Color(0xFFB08AC8), -0.45),
    Mood('Calm', Color(0xFFFFC63C), 0.25),
    Mood('Bright', Color(0xFFFFB03A), 0.7),
    Mood('Alive', Color(0xFFFF8A3C), 1.0),
  ];
}
