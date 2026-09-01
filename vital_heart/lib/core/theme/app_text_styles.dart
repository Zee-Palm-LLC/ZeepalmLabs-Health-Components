import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle get screenTitle => GoogleFonts.plusJakartaSans(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.title,
        letterSpacing: -0.2,
      );

  static TextStyle get heroBpm => GoogleFonts.plusJakartaSans(
        fontSize: 52.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.title,
        height: 1,
        letterSpacing: -1.5,
      );

  static TextStyle get sectionTitle => GoogleFonts.plusJakartaSans(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.title,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
      );

  static TextStyle get statValue => GoogleFonts.plusJakartaSans(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.title,
        height: 1,
        letterSpacing: -0.6,
      );

  static TextStyle get statUnit => GoogleFonts.plusJakartaSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.subtitle,
      );

  static TextStyle get historyValue => GoogleFonts.plusJakartaSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.title,
      );
}
