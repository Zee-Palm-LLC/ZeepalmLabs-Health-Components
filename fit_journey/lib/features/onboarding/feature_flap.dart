import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/onboarding_pages.dart';
import '../../widgets/icon_orb.dart';

class FeatureFlap extends StatelessWidget {
  const FeatureFlap({
    super.key,
    required this.top,
    required this.previous,
    required this.current,
    required this.flip,
    required this.enter,
    required this.seconds,
  });

  final double top;
  final Feature previous;
  final Feature current;
  final double flip;
  final double enter;
  final double seconds;

  static const left = 225.0;
  static const width = 147.0;
  static const height = 62.0;

  @override
  Widget build(BuildContext context) {
    final entering = enter < 1;
    Widget face;
    Matrix4 m = Matrix4.identity()..setEntry(3, 2, 0.0016);
    Alignment pivot = Alignment.center;
    double shade = 0;
    if (entering) {
      final e = spring(enter, bounce: 0.32, freq: 2.3);
      m.rotateX(-(1 - e) * math.pi / 2);
      pivot = Alignment.topCenter;
      shade = (1 - e).clamp(0.0, 1.0) * 0.18;
      face = _Face(feature: current, fill: span(enter, 0.3, 1.0, Curves.linear), pulse: span(enter, 0.75, 1.0, Curves.linear), seconds: seconds);
    } else if (flip < 1) {
      final angle = math.pi * Curves.easeInOutCubic.transform(flip);
      final showNew = angle > math.pi / 2;
      m.rotateX(showNew ? angle - math.pi : angle);
      shade = math.sin(angle) * 0.16;
      face = showNew
          ? _Face(feature: current, fill: span(flip, 0.5, 1.0, Curves.linear), pulse: span(flip, 0.8, 1.0, Curves.linear), seconds: seconds)
          : _Face(feature: previous, fill: 1, pulse: 0, seconds: seconds);
    } else {
      face = _Face(feature: current, fill: 1, pulse: 0, seconds: seconds);
    }
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Opacity(
        opacity: entering ? span(enter, 0.0, 0.25, Curves.easeOut) : 1,
        child: Transform(
          alignment: pivot,
          transform: m,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Palette.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Palette.shadow.withValues(alpha: 0.075), blurRadius: 12, offset: const Offset(0, 3)),
              ],
            ),
            child: Stack(
              children: [
                face,
                if (shade > 0)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.navy.withValues(alpha: shade),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({required this.feature, required this.fill, required this.pulse, required this.seconds});

  final Feature feature;
  final double fill;
  final double pulse;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final lines = feature.label.split('\n');
    final style = font(13.6, 700, color: const Color(0xFF22344A), height: 1.16);
    final bases = lines.length == 1 ? [36.2] : [27.8, 43.6];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 9.5,
          top: 6.5,
          child: IconOrb(swatch: feature.swatch, icon: feature.icon, fill: fill, pulse: pulse, seconds: seconds),
        ),
        for (var i = 0; i < lines.length; i++) Label(lines[i], x: 69.4, base: bases[i], style: style),
      ],
    );
  }
}
