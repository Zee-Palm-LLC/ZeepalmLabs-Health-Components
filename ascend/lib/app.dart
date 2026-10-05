import 'package:flutter/material.dart';

import 'core/canvas.dart';
import 'core/motion.dart';
import 'core/style.dart';
import 'onboarding/onboarding.dart';

class AscendApp extends StatelessWidget {
  const AscendApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Tone.night,
        fontFamily: 'Inter',
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: Tone.violet, brightness: Brightness.dark),
      ),
      builder: (context, child) => ClockHost(child: DesignCanvas(child: child!)),
      home: home ?? const Onboarding(),
    );
  }
}
