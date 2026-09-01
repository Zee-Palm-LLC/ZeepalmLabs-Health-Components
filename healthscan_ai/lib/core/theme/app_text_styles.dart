import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get greeting => GoogleFonts.plusJakartaSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get userName => GoogleFonts.plusJakartaSans(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get date => GoogleFonts.plusJakartaSans(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get sectionTitle => GoogleFonts.plusJakartaSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get cardLabel => GoogleFonts.plusJakartaSans(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get cardValue => GoogleFonts.plusJakartaSans(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get heroScore => GoogleFonts.plusJakartaSans(
        fontSize: 36.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        height: 1,
        letterSpacing: -1,
      );

  static TextStyle get screenTitle => GoogleFonts.plusJakartaSans(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get link => GoogleFonts.plusJakartaSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.blue,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get navLabel => GoogleFonts.plusJakartaSans(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
      );
}
