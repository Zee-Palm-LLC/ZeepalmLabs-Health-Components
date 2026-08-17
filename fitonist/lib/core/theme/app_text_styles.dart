import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get logo => GoogleFonts.syne(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      );

  static TextStyle get tagline => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: AppColors.accentPurple,
      );

  static TextStyle get headline => GoogleFonts.inter(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get navTitle => GoogleFonts.inter(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get formHeadline => GoogleFonts.inter(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get inputLabel => GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.8,
        color: AppColors.textMuted,
      );

  static TextStyle get inputValue => GoogleFonts.inter(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get banner => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.bannerText,
      );
}
