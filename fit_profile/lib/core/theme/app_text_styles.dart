import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle get title => GoogleFonts.plusJakartaSans(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.title,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle get subtitle => GoogleFonts.plusJakartaSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.subtitle,
        height: 1.45,
      );

  static TextStyle get cardLabel => GoogleFonts.plusJakartaSans(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.title,
      );

  static TextStyle get valueLarge => GoogleFonts.plusJakartaSans(
        fontSize: 42.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.title,
        letterSpacing: -1,
        height: 1,
      );

  static TextStyle get valueUnit => GoogleFonts.plusJakartaSans(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.title,
      );

  static TextStyle get pickerSelected => GoogleFonts.plusJakartaSans(
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.accent,
        height: 1,
      );

  static TextStyle get pickerNear => GoogleFonts.plusJakartaSans(
        fontSize: 26.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.subtitle,
        height: 1,
      );

  static TextStyle get pickerFar => GoogleFonts.plusJakartaSans(
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1,
      );
}
