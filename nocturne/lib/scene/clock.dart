import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class SceneClock extends ChangeNotifier implements ValueListenable<double> {
  SceneClock._();

  static final SceneClock instance = SceneClock._();

  double _seconds = 0;
  double? _frozen;

  @override
  double get value => _frozen ?? _seconds;

  void freeze(double? seconds) {
    _frozen = seconds;
    notifyListeners();
  }

  void tick(Duration elapsed) {
    _seconds = elapsed.inMicroseconds / 1e6;
    notifyListeners();
  }
}

abstract final class Shaders {
  static ui.FragmentProgram? orb;
  static ui.FragmentProgram? vessel;

  static Future<void> load() async {
    try {
      orb = await ui.FragmentProgram.fromAsset('shaders/orb.frag');
    } catch (_) {
      orb = null;
    }
    try {
      vessel = await ui.FragmentProgram.fromAsset('shaders/vessel.frag');
    } catch (_) {
      vessel = null;
    }
  }
}

class ClockDriver extends StatefulWidget {
  const ClockDriver({super.key, required this.child});

  final Widget child;

  @override
  State<ClockDriver> createState() => _ClockDriverState();
}

class _ClockDriverState extends State<ClockDriver>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(SceneClock.instance.tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
