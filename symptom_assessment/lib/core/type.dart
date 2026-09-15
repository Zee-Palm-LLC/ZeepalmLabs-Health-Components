import 'package:flutter/widgets.dart';

import 'palette.dart';

/// Manrope, as a variable font. Weights go through [FontVariation] so one
/// file covers the whole range and the rendering stays crisp at every step.
class T {
  T._();

  static const String family = 'Manrope';

  static TextStyle style(
    double size, {
    double weight = 500,
    Color color = Slate.primary,
    double height = 1.3,
    double letterSpacing = 0,
  }) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        height: height,
        color: color,
        letterSpacing: letterSpacing,
        fontVariations: <FontVariation>[FontVariation('wght', weight)],
      );

  static TextStyle get appBar => style(15, weight: 600, color: Slate.secondary);
  static TextStyle get headline =>
      style(26, weight: 800, height: 1.28, letterSpacing: -0.4);
  static TextStyle get sub => style(12.5, weight: 500, color: Slate.muted);
  static TextStyle get label => style(12, weight: 600, color: Slate.secondary);
  static TextStyle get placeholder =>
      style(14.5, weight: 500, color: Slate.muted);
  static TextStyle get input => style(15, weight: 600, color: Slate.primary);
  static TextStyle get chip => style(13.5, weight: 600, color: Slate.secondary);
  static TextStyle get tileTitle => style(14.5, weight: 700);
  static TextStyle get tileSub => style(12, weight: 500, color: Slate.muted);
  static TextStyle get cardTitle => style(16, weight: 800);
  static TextStyle get cardBody =>
      style(12, weight: 500, color: Slate.muted, height: 1.45);
  static TextStyle get button => style(14.5, weight: 700, color: Paper.white);
  static TextStyle get pill => style(12, weight: 600, color: Slate.secondary);
  static TextStyle get condition => style(12, weight: 600, color: Slate.secondary);
}
