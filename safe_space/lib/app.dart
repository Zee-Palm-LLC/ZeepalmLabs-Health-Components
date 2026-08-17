import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/onboarding/onboarding_screen.dart';
import 'theme/app_theme.dart';

class SafeSpaceApp extends StatelessWidget {
  const SafeSpaceApp({super.key});

  static const SystemUiOverlayStyle overlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarContrastEnforced: false,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Safe Space',
        theme: AppTheme.light,
        home: const OnboardingScreen(),
      ),
    );
  }
}
