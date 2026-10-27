import 'dart:math';

import 'package:flutter/painting.dart';

import 'package:google_fonts/google_fonts.dart';

/// The design is drawn on a 390 × 844 pt canvas (iPhone 14/15). [Geo] maps
/// design points to the device: everything scales with width, content is
/// pinned to the top (below the status bar) and the character to the bottom.
class Geo {
  Geo(this.size, {this.safeTop = 0, this.safeBottom = 0}) : s = size.width / 390;

  final Size size;
  final double s;
  final double safeTop;
  final double safeBottom;

  /// Extra offset when the device's status bar is taller than the design's 47pt.
  double get shift => max(0, safeTop - 47 * s);

  double x(double v) => v * s;
  double y(double v) => shift + v * s;

  Offset get orbCenter => Offset(size.width / 2, max(size.height - 98 * s, y(720)));
  double get orbR => 172 * s;

  @override
  bool operator ==(Object other) => other is Geo && other.size == size && other.shift == shift;

  @override
  int get hashCode => Object.hash(size, shift);
}

TextStyle inter(
  double size,
  FontWeight weight,
  Color color, {
  double ls = 0,
  double height = 1.15,
  bool tabular = false,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: ls,
      height: height,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
