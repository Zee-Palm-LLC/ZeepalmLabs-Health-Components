import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// `?still` in the URL (web previews) starts every animation at its end state.
final bool stillMode = Uri.base.queryParameters.containsKey('still');

/// A [Curve] sampled from a real damped spring, so staggered UI motion has
/// the same overshoot/settle character as the physics-driven parts.
class SpringCurve extends Curve {
  SpringCurve({double damping = 0.72, double stiffness = 180}) : _sim = _make(damping, stiffness);

  final SpringSimulation _sim;

  static SpringSimulation _make(double ratio, double k) {
    final desc = SpringDescription.withDampingRatio(mass: 1, stiffness: k, ratio: ratio);
    return SpringSimulation(desc, 0, 1, 0);
  }

  // Settle time of the spring maps to t = 1.
  late final double _end = () {
    var t = 0.0;
    while (t < 4 && !(_sim.isDone(t) && (_sim.x(t) - 1).abs() < 0.002)) {
      t += 1 / 120;
    }
    return t;
  }();

  @override
  double transformInternal(double t) => t >= 1 ? 1 : _sim.x(t * _end);
}

final springy = SpringCurve(damping: 0.68, stiffness: 170);
final springSoft = SpringCurve(damping: 0.86, stiffness: 140);

/// Staggered entrance: fade + rise + de-scale driven by one shared controller.
/// Each child only listens to its own interval, and transforms happen in the
/// compositor (FadeTransition / Transform), so nothing re-lays out per frame.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.anim,
    required this.index,
    required this.child,
    this.count = 12,
    this.dy = 22,
    this.scale = 0.96,
  });

  final Animation<double> anim;
  final int index;
  final int count;
  final double dy;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index / count * 0.55).clamp(0.0, 0.9);
    final end = math.min(1.0, start + 0.45);
    final moved = CurvedAnimation(parent: anim, curve: Interval(start, end, curve: springy));
    final faded = CurvedAnimation(parent: anim, curve: Interval(start, math.min(1.0, start + 0.25), curve: Curves.easeOut));
    return FadeTransition(
      opacity: faded,
      child: AnimatedBuilder(
        animation: moved,
        child: child,
        builder: (context, child) {
          final v = moved.value;
          final s = scale + (1 - scale) * v;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translateByDouble(0, dy * (1 - v), 0, 1)
              ..scaleByDouble(s, s, 1, 1),
            child: child,
          );
        },
      ),
    );
  }
}

/// Press micro-interaction: squash on touch-down, spring back with overshoot
/// on release, light haptic.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.955, this.haptic = true});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this, value: 1);
  static final _spring = SpringDescription.withDampingRatio(mass: 1, stiffness: 520, ratio: 0.42);

  void _to(double target, {double velocity = 0}) =>
      _c.animateWith(SpringSimulation(_spring, _c.value, target, velocity));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _c.animateTo(widget.scale, duration: const Duration(milliseconds: 90), curve: Curves.easeOut),
      onTapCancel: () => _to(1),
      onTapUp: (_) {
        _to(1, velocity: 2.5);
        if (widget.haptic) HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: ScaleTransition(scale: _c, child: widget.child),
    );
  }
}
