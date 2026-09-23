import 'package:flutter/widgets.dart';

import 'palette.dart';

class Typo {
  Typo._();

  static const String display = 'Saira';
  static const String body = 'Inter';

  static TextStyle metric(
    double size, {
    double weight = 700,
    double width = 100,
    Color color = Tone.bright,
    double height = 0.94,
    double letterSpacing = -1.0,
  }) => TextStyle(
    fontFamily: display,
    fontSize: size,
    height: height,
    color: color,
    letterSpacing: letterSpacing,
    fontVariations: <FontVariation>[
      FontVariation('wght', weight),
      FontVariation('wdth', width),
    ],
  );

  static TextStyle text(
    double size, {
    double weight = 500,
    Color color = Tone.secondary,
    double height = 1.32,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: body,
    fontSize: size,
    height: height,
    color: color,
    letterSpacing: letterSpacing,
    fontVariations: <FontVariation>[FontVariation('wght', weight)],
  );

  static TextStyle label(
    double size, {
    double weight = 600,
    Color color = Tone.muted,
    double letterSpacing = 1.6,
  }) => text(
    size,
    weight: weight,
    color: color,
    height: 1.0,
    letterSpacing: letterSpacing,
  );

  static TextStyle get hero => metric(76, weight: 700, letterSpacing: -3.0);
  static TextStyle get headline => metric(46, weight: 700, letterSpacing: -1.6);
  static TextStyle get statValue =>
      metric(27, weight: 600, letterSpacing: -0.6);
  static TextStyle get statUnit =>
      text(12.5, weight: 600, color: Tone.muted, height: 1.0);
  static TextStyle get statLabel => label(10, letterSpacing: 1.5);
  static TextStyle get sectionTitle =>
      text(14.5, weight: 600, color: Tone.primary, height: 1.1);
  static TextStyle get cardTitle =>
      text(16, weight: 600, color: Tone.bright, height: 1.15);
  static TextStyle get bodyText =>
      text(13.5, weight: 400, color: Tone.secondary);
  static TextStyle get caption => text(11.5, weight: 500, color: Tone.muted);
  static TextStyle get button => text(
    14,
    weight: 700,
    color: Tone.bright,
    letterSpacing: 2.2,
    height: 1.0,
  );
  static TextStyle get wordmark => metric(
    21,
    weight: 700,
    color: Tone.bright,
    letterSpacing: 0.4,
    height: 1.0,
  );
}
