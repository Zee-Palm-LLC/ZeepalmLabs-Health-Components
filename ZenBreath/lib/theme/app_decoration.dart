import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppRadii {
  const AppRadii._();

  static double get card => 18.r;
  static double get chip => 20.r;
  static double get pill => 30.r;
  static double get tile => 14.r;
  static double get sheet => 32.r;
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.06),
      blurRadius: 18.r,
      offset: Offset(0, 6.h),
    ),
  ];

  static List<BoxShadow> get raised => [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.10),
      blurRadius: 22.r,
      offset: Offset(0, 8.h),
    ),
  ];

  static List<BoxShadow> get nav => [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.07),
      blurRadius: 20.r,
      offset: Offset(0, -4.h),
    ),
  ];
}

class AppDecoration {
  const AppDecoration._();

  static BoxDecoration card({double? radius, Color? color}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(radius ?? AppRadii.card),
    border: Border.all(color: AppColors.border, width: 1),
    boxShadow: AppShadows.card,
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
    stops: [0.0, 0.55, 1.0],
  );

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FCFE), AppColors.background, AppColors.backgroundTint],
    stops: [0.0, 0.45, 1.0],
  );
}
