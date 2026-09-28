import 'package:flutter/material.dart';

import 'core/canvas.dart';
import 'core/kitchen.dart';
import 'core/motion.dart';
import 'features/splash/splash_screen.dart';

class PocketChefApp extends StatefulWidget {
  const PocketChefApp({super.key, this.home});

  final Widget? home;

  @override
  State<PocketChefApp> createState() => _PocketChefAppState();
}

class _PocketChefAppState extends State<PocketChefApp> {
  final _kitchen = Kitchen();

  @override
  void dispose() {
    _kitchen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KitchenScope(
      kitchen: _kitchen,
      child: MaterialApp(
        title: 'PocketChef',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFCF7F0),
          fontFamily: 'Inter',
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFC2240)),
        ),
        builder: (context, child) => ClockHost(child: DesignCanvas(child: child!)),
        home: widget.home ?? const SplashScreen(),
      ),
    );
  }
}
