import 'package:flutter/material.dart';

import 'core/canvas.dart';
import 'core/motion.dart';
import 'core/style.dart';
import 'home/player.dart';
import 'onboarding/onboarding.dart';
import 'tutorial/showcase.dart';
import 'widgets/fx.dart';

class StreakApp extends StatefulWidget {
  const StreakApp({super.key, this.home, this.tutorials = true});

  final Widget? home;

  /// False starts with every tutorial chapter already seen.
  final bool tutorials;

  @override
  State<StreakApp> createState() => _StreakAppState();
}

class _StreakAppState extends State<StreakApp> {
  late final _player = Player()..seen.addAll(widget.tutorials ? const [] : const ['home', 'workout', 'quests']);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreakRPG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Tone.night,
        fontFamily: 'Poppins',
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: Tone.violet, brightness: Brightness.dark),
      ),
      builder: (context, child) => ClockHost(
        child: DesignCanvas(
          child: PlayerScope(
            player: _player,
            child: FxLayer(
              child: ShowcaseHost(onReward: _player.gainXp, child: child!),
            ),
          ),
        ),
      ),
      home: widget.home ?? const Onboarding(),
    );
  }
}
