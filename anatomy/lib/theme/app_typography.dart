import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle display({
    double? size,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.fraunces(
      fontSize: (size ?? 28).sp,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      height: height ?? 1.15,
      letterSpacing: letterSpacing ?? -0.4,
    );
  }

  static TextStyle title({
    double? size,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.fraunces(
      fontSize: (size ?? 22).sp,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      height: height ?? 1.2,
      letterSpacing: -0.3,
    );
  }

  static TextStyle body({
    double? size,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return GoogleFonts.workSans(
      fontSize: (size ?? 14).sp,
      fontWeight: weight,
      color: color ?? AppColors.inkSoft,
      height: height ?? 1.45,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle label({
    double? size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.workSans(
      fontSize: (size ?? 12).sp,
      fontWeight: weight,
      color: color ?? AppColors.muted,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }

  static TextStyle overline({
    double? size,
    Color? color,
  }) {
    return GoogleFonts.workSans(
      fontSize: (size ?? 11).sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.accent,
      letterSpacing: 1.4,
    );
  }
}
