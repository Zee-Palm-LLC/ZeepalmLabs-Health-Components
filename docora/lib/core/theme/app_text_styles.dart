import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get greeting => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.body,
      );

  static TextStyle get userName => GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.ink,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.ink,
      );

  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get cardSubtitle => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.body,
      );

  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get doctorName => GoogleFonts.inter(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.ink,
      );

  static TextStyle get price => GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get statValue => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get statLabel => GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.body,
      );

  static TextStyle get tab => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.body,
      );

  static TextStyle get tabActive => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );
}
