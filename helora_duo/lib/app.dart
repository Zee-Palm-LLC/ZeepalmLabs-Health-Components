import 'package:flutter/material.dart';

import 'core/style.dart';
import 'shell/home.dart';

class HeloraApp extends StatelessWidget {
  const HeloraApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Tone.canvas,
        fontFamily: 'PlusJakartaSans',
        splashFactory: InkSparkle.splashFactory,
        colorScheme: ColorScheme.fromSeed(seedColor: Tone.red, surface: Tone.canvas),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3)),
        child: child!,
      ),
      home: home ?? const Home(),
    );
  }
}
