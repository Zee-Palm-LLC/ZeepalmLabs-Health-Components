import 'package:flutter/material.dart';

import 'core/canvas.dart';
import 'core/motion.dart';
import 'core/palette.dart';
import 'features/onboarding/onboarding_screen.dart';

class FitziApp extends StatelessWidget {
  const FitziApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitzi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Palette.cream,
        fontFamily: 'Inter',
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      builder: (context, child) => ClockHost(child: DesignCanvas(child: child!)),
      home: home ?? const OnboardingScreen(),
    );
  }
}
