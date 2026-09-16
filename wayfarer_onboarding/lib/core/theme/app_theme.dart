import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        primary: AppColors.orange,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.figtreeTextTheme(),
    );
  }
}
