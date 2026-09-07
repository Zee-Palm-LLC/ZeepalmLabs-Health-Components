import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'nutrx_colors.dart';

abstract final class NutrxText {
  static TextStyle get _base => GoogleFonts.poppins(
        color: NutrxColors.text,
        letterSpacing: -0.2,
      );

  static TextStyle title = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle section = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle cardLabel = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: NutrxColors.textMuted,
    height: 1.2,
  );

  static TextStyle metric = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.6,
  );

  static TextStyle metricSm = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.4,
  );

  static TextStyle percent = _base.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -0.5,
  );

  static TextStyle body = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: NutrxColors.textMuted,
    height: 1.35,
  );

  static TextStyle chip = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle tab = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle workoutTitle = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.3,
  );

  static TextStyle meta = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: NutrxColors.textMuted,
    height: 1.2,
  );
}
