import 'package:flutter/material.dart';

import 'palette.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Night.abyss,
    fontFamily: Typo.body,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      surface: Night.base,
      primary: Spectrum.cyan,
      secondary: Spectrum.blue,
      onPrimary: Night.abyss,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Spectrum.cyan,
    ),
  );
}
