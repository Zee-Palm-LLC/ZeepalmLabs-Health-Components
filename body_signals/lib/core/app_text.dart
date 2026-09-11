import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppText {
  const AppText._();

  static TextStyle display() => GoogleFonts.poppins(
        fontSize: 27.sp,
        height: 1.22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: AppColors.textPrimary,
      );

  static TextStyle h1() => GoogleFonts.poppins(
        fontSize: 22.sp,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );

  static TextStyle h2() => GoogleFonts.poppins(
        fontSize: 15.5.sp,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle h3() => GoogleFonts.poppins(
        fontSize: 13.sp,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle body() => GoogleFonts.poppins(
        fontSize: 11.5.sp,
        height: 1.68,
        color: AppColors.textSecondary,
      );

  static TextStyle label() => GoogleFonts.poppins(
        fontSize: 10.5.sp,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle caption() => GoogleFonts.poppins(
        fontSize: 9.sp,
        height: 1.35,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      );

  static TextStyle overline() => GoogleFonts.poppins(
        fontSize: 8.sp,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: AppColors.textTertiary,
      );

  static TextStyle metric() => GoogleFonts.poppins(
        fontSize: 22.sp,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      );
}
