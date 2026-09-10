import 'package:flutter/material.dart';

abstract final class AegisColors {
  static const background = Color(0xFF040A0E);
  static const panel = Color(0xFF08111A);
  static const panelRaised = Color(0xFF0B1725);
  static const hairline = Color(0x17FFFFFF);
  static const mapBase = Color(0xFF0B141B);

  static const textPrimary = Color(0xFFF4F6F7);
  static const textSecondary = Color(0xFFB6C0CB);
  static const textMuted = Color(0xFF7F8A98);
  static const warmWhite = Color(0xFFFFF7E8);

  static const amber = Color(0xFFF0B560);
  static const amberBright = Color(0xFFFFD47E);
  static const ember = Color(0xFFE98A3A);
  static const alert = Color(0xFFE8483A);
  static const alertText = Color(0xFFF46A56);
  static const teal = Color(0xFF3EC9A3);
  static const tealBright = Color(0xFF6BF4D6);
  static const inactive = Color(0xFF394755);
}

abstract final class AegisFonts {
  static const serif = 'SourceSerif4Display';
  static const sans = 'Inter';
}

abstract final class AegisText {
  static const wordmark = TextStyle(
    fontFamily: AegisFonts.serif,
    fontSize: 28,
    height: 1,
    color: AegisColors.textPrimary,
  );
  static const cardTitle = TextStyle(
    fontSize: 14,
    color: AegisColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: AegisColors.textSecondary,
  );
  static const caption = TextStyle(
    fontSize: 12.5,
    height: 1.35,
    color: AegisColors.textMuted,
  );
  static const value = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AegisColors.textPrimary,
  );
  static const display = TextStyle(
    fontFamily: AegisFonts.serif,
    fontSize: 36,
    height: 1.1,
    color: AegisColors.textPrimary,
  );
}

ThemeData buildAegisTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: AegisColors.amber,
      onPrimary: AegisColors.background,
      secondary: AegisColors.teal,
      error: AegisColors.alert,
      surface: AegisColors.panel,
      onSurface: AegisColors.textPrimary,
    ),
    scaffoldBackgroundColor: AegisColors.background,
    fontFamily: AegisFonts.sans,
    dividerTheme: const DividerThemeData(color: AegisColors.hairline),
    splashFactory: InkRipple.splashFactory,
    // The app bar paints its own frosted backdrop, so the theme only needs to
    // stop Material tinting it.
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AegisColors.textPrimary),
      titleTextStyle: AegisText.wordmark,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AegisColors.panelRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AegisColors.hairline),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        color: AegisColors.textSecondary,
      ),
    ),
  );
}
