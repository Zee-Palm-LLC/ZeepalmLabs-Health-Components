import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Critically-damped spring feel — settles cleanly, almost no overshoot.
class SoftSpringCurve extends Curve {
  const SoftSpringCurve({this.tension = 7.2});

  final double tension;

  @override
  double transformInternal(double t) {
    final x = t.clamp(0.0, 1.0);
    // x(t) = 1 - e^(-τt)(1 + τt)  → premium settle, not bouncy
    return 1 - math.exp(-tension * x) * (1 + tension * x);
  }
}

/// Soft underdamped spring — tiny elastic settle, then calm.
class ElasticPageCurve extends Curve {
  const ElasticPageCurve({
    this.decay = 5.1,
    this.freq = 4.6,
  });

  final double decay;
  final double freq;

  @override
  double transformInternal(double t) {
    final x = t.clamp(0.0, 1.0);
    // Approaches 1 with a gentle overshoot (~3–5%), then settles.
    return 1 - math.exp(-decay * x) * math.cos(freq * x);
  }
}

/// Page snap with a springy settle (swipe + fling).
class ElasticPagePhysics extends PageScrollPhysics {
  const ElasticPagePhysics({super.parent});

  @override
  ElasticPagePhysics applyTo(ScrollPhysics? ancestor) {
    return ElasticPagePhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.85,
        stiffness: 95,
        damping: 13.5,
      );
}

class AppMotion {
  static const soft = SoftSpringCurve();
  static const softTight = SoftSpringCurve(tension: 9.0);
  static const elasticPage = ElasticPageCurve();
  static const enter = Duration(milliseconds: 780);
  static const page = Duration(milliseconds: 780);
  static const press = Duration(milliseconds: 160);

  static SpringDescription get softSpring => const SpringDescription(
        mass: 1,
        stiffness: 160,
        damping: 22,
      );

  static Duration stagger(int i, {int step = 70, int from = 0}) =>
      Duration(milliseconds: from + i * step);
}
