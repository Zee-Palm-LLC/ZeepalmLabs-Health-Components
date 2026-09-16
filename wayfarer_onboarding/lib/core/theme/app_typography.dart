import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle _figtree({
    required double size,
    required FontWeight weight,
    Color color = AppColors.ink,
    double? height,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.figtree(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static final brand = _figtree(size: 23, weight: FontWeight.w800, letterSpacing: -0.6);
  static final headline = _figtree(size: 31.5, weight: FontWeight.w700, height: 1.25, letterSpacing: -0.5);
  static final body = _figtree(size: 12.5, weight: FontWeight.w400, height: 1.47, color: AppColors.inkMuted);
  static final button = _figtree(size: 16, weight: FontWeight.w600, color: AppColors.surface, letterSpacing: 0.1);
  static final cardTitle = _figtree(size: 12, weight: FontWeight.w700, letterSpacing: -0.1);
  static final cardBody = _figtree(size: 9.5, weight: FontWeight.w400, color: AppColors.inkMuted, height: 1.3);
  static final micro = _figtree(size: 8, weight: FontWeight.w600, color: AppColors.inkMuted, height: 1.1);
}
