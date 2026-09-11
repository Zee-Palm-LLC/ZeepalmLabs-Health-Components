import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppText {
  static TextStyle display({Color? color, double? size}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size ?? 36.sp,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.4,
        color: color ?? AppColors.ink,
      );

  static TextStyle displayCenter({Color? color}) => display(
        color: color ?? AppColors.forest,
        size: 34.sp,
      ).copyWith(height: 1.18);

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: color ?? AppColors.body,
      );

  static TextStyle bodyCenter({Color? color}) => GoogleFonts.inter(
        fontSize: 14.5.sp,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: color ?? AppColors.body,
      );

  static TextStyle skip({Color? color}) => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color ?? AppColors.ink,
      );
}
