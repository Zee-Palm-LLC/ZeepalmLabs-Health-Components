import 'package:flutter/material.dart';

import 'core/canvas.dart';
import 'core/motion.dart';
import 'core/style.dart';
import 'game/run_page.dart';
import 'screens/race_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/world_screen.dart';

class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Tone.space,
        fontFamily: 'Baloo',
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      builder: (context, child) => ClockHost(child: DesignCanvas(child: child!)),
      home: home ?? const OrbitFlow(),
    );
  }
}

class OrbitFlow extends StatelessWidget {
  const OrbitFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onStart: () => Navigator.of(context).pushReplacement(_hatch(const WorldHub())));
  }
}

class WorldHub extends StatelessWidget {
  const WorldHub({super.key});

  @override
  Widget build(BuildContext context) {
    return WorldScreen(
      onOpen: (hub) {
        final nav = Navigator.of(context);
        if (hub == Hub.heart) nav.push(_zoom(RunPage(onExit: () => nav.pop())));
        if (hub == Hub.star) nav.push(_space(RaceScreen(onBack: () => nav.pop())));
      },
    );
  }
}

PageRouteBuilder<void> _hatch(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 700),
    pageBuilder: (context, a, b) => page,
    transitionsBuilder: (context, a, b, child) => FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
  );
}

PageRouteBuilder<void> _zoom(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 650),
    reverseTransitionDuration: const Duration(milliseconds: 480),
    pageBuilder: (context, a, b) => page,
    transitionsBuilder: (context, a, b, child) {
      final c = CurvedAnimation(parent: a, curve: gentle, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: c,
        child: ScaleTransition(scale: Tween(begin: 1.12, end: 1.0).animate(c), child: child),
      );
    },
  );
}

PageRouteBuilder<void> _space(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, a, b) => page,
    transitionsBuilder: (context, a, b, child) {
      final c = CurvedAnimation(parent: a, curve: gentle, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: c,
        child: SlideTransition(position: Tween(begin: const Offset(0, -0.08), end: Offset.zero).animate(c), child: child),
      );
    },
  );
}
