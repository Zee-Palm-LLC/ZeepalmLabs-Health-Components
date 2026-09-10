import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppText {
  const AppText._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.textPrimary,
    double height = 1.15,
    double letterSpacing = 0,
  }) => GoogleFonts.playfairDisplay(
    fontSize: size.sp,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double height = 1.35,
    double letterSpacing = 0,
  }) => GoogleFonts.poppins(
    fontSize: size.sp,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle label({Color color = AppColors.textSecondary}) =>
      body(12.5, weight: FontWeight.w500, color: color, letterSpacing: 0.1);

  static TextStyle metric({Color color = AppColors.textPrimary}) =>
      body(22, weight: FontWeight.w600, color: color, height: 1.1);

  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      body(11.5, weight: FontWeight.w400, color: color);

  static TextStyle sectionTitle() =>
      body(17, weight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle screenTitle() => display(29, weight: FontWeight.w500);
}
