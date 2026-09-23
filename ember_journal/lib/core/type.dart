import 'package:flutter/material.dart';

import 'palette.dart';

TextStyle font(
  double size,
  int weight, {
  Color color = Ember.cream,
  double height = 1.0,
  double spacing = 0,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: size,
    height: height,
    letterSpacing: spacing,
    color: color,
    fontWeight: FontWeight.values[weight ~/ 100 - 1],
    shadows: shadows,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

const lift = [Shadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 2))];

TextStyle get heroStyle => font(37, 500, height: 1.19, spacing: -0.6, shadows: lift);

TextStyle get navTitle => font(16.5, 500, shadows: lift);

TextStyle get largeTitle => font(27, 500, spacing: -0.3, shadows: lift);

TextStyle get quoteStyle => font(26.5, 500, height: 1.55, spacing: -0.4, shadows: lift);

TextStyle get cardTitle => font(19.5, 500, height: 1.42, spacing: -0.2);

TextStyle body(double alpha) => font(13.7, 400, height: 1.72, color: Ember.ash.withValues(alpha: alpha));

TextStyle label(Color color) => font(13.2, 500, color: color);

TextStyle meta(double alpha) => font(11.6, 400, color: Ember.ash.withValues(alpha: alpha));
