import 'package:flutter/material.dart';

import 'core/motion.dart';
import 'core/palette.dart';
import 'core/sprites.dart';
import 'core/type.dart';
import 'features/splash_screen.dart';

class MoveQuestApp extends StatelessWidget {
  const MoveQuestApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return ClockHost(
      child: MaterialApp(
        title: 'MoveQuest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: cabin,
          scaffoldBackgroundColor: Hue.night,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        home: _Preload(child: home ?? const SplashScreen()),
      ),
    );
  }
}

class _Preload extends StatefulWidget {
  const _Preload({required this.child});

  final Widget child;

  @override
  State<_Preload> createState() => _PreloadState();
}

class _PreloadState extends State<_Preload> {
  bool _warmed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_warmed) return;
    _warmed = true;
    for (final scene in [Scenes.splash, Scenes.path, Scenes.map, Scenes.river]) {
      precacheImage(AssetImage(scene), context);
    }
    for (final sprite in Art.all) {
      precacheImage(AssetImage(sprite.asset), context);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
