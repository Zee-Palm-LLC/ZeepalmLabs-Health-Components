import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const gentle = Cubic(0.22, 1.0, 0.32, 1.0);
const swift = Cubic(0.16, 0.9, 0.24, 1.0);
const settle = Cubic(0.34, 1.32, 0.42, 1.0);
const breathe = Cubic(0.45, 0.05, 0.55, 0.95);

double span(double t, double begin, double end, [Curve curve = gentle]) {
  if (end <= begin) return t >= end ? 1 : 0;
  return curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));
}

double lerp(double a, double b, double t) => a + (b - a) * t;

double ease(double t) => t * t * (3 - 2 * t);

double wave(double seconds, double period, [double phase = 0]) =>
    math.sin((seconds / period + phase) * math.pi * 2);

double spring(double t, {double bounce = 0.36, double freq = 3.1}) {
  if (t >= 1) return 1;
  return 1 - math.exp(-6.2 * t) * math.cos(freq * math.pi * t) * (1 + bounce * (1 - t));
}

mixin ClockMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  double get seconds => _elapsed.inMicroseconds / 1e6;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) {
      setState(() => _elapsed = d);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

class Staged extends StatelessWidget {
  const Staged({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.offset = const Offset(0, 26),
    this.scale = 1.0,
    this.rotateX = 0.0,
    this.curve = gentle,
    this.blur = false,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;
  final Offset offset;
  final double scale;
  final double rotateX;
  final Curve curve;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final t = span(animation.value, begin, end, curve);
        final rest = 1 - t;
        final m = Matrix4.identity()..setEntry(3, 2, 0.0012);
        m.translateByDouble(offset.dx * rest, offset.dy * rest, 0, 1);
        if (rotateX != 0) m.rotateX(rotateX * rest);
        if (scale != 1.0) m.scaleByDouble(lerp(scale, 1, t), lerp(scale, 1, t), 1, 1);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform(alignment: Alignment.center, transform: m, child: inner),
        );
      },
      child: child,
    );
  }
}

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.94,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 460));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down(_) => _c.animateTo(1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut);

  void _up() => _c.animateBack(0, duration: const Duration(milliseconds: 420), curve: settle);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: widget.onTap == null ? null : _down,
      onTapUp: widget.onTap == null ? null : (_) => _up(),
      onTapCancel: widget.onTap == null ? null : _up,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.scale(scale: lerp(1, widget.scale, _c.value), child: child),
        child: widget.child,
      ),
    );
  }
}
