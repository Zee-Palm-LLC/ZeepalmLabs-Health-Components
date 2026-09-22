import 'package:flutter/painting.dart';

import 'palette.dart';

abstract final class Typo {
  static const family = 'Poppins';

  static TextStyle display(
    double size, {
    Color color = Night.text,
    double spacing = 0,
    double height = 1.1,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size * 0.98,
    height: height,
    letterSpacing: spacing + size * 0.01,
    color: color,
    fontWeight: FontWeight.w400,
  );

  static TextStyle serifText(
    double size, {
    Color color = Night.text,
    double spacing = 0,
    double height = 1.3,
    double weight = 400,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size * 0.95,
    height: height,
    letterSpacing: spacing - size * 0.008,
    color: color,
    fontWeight: weight >= 420 ? FontWeight.w500 : FontWeight.w400,
  );

  static TextStyle ui(
    double size, {
    Color color = Night.text,
    double weight = 400,
    double spacing = 0,
    double height = 1.3,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size * 0.96,
    height: height,
    letterSpacing: spacing,
    color: color,
    fontWeight: _weight(weight),
  );

  static FontWeight _weight(double w) {
    if (w >= 560) return FontWeight.w600;
    if (w >= 450) return FontWeight.w500;
    if (w >= 390) return FontWeight.w400;
    return FontWeight.w300;
  }
}
