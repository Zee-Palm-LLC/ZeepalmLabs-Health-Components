import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const gentle = Cubic(0.22, 1.0, 0.32, 1.0);
const swift = Cubic(0.16, 0.9, 0.24, 1.0);
const settle = Cubic(0.34, 1.36, 0.42, 1.0);
const glide = Cubic(0.65, 0.0, 0.35, 1.0);
const gravity = Cubic(0.55, 0.0, 0.9, 0.45);

double span(double t, double begin, double end, [Curve curve = gentle]) {
  if (end <= begin) return t >= end ? 1 : 0;
  return curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));
}

double lerp(double a, double b, double t) => a + (b - a) * t;

double wave(double seconds, double period, [double phase = 0]) =>
    math.sin((seconds / period + phase) * math.pi * 2);

double spring(double t, {double bounce = 0.36, double freq = 3.1}) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  return 1 - math.exp(-6.2 * t) * math.cos(freq * math.pi * t) * (1 + bounce * (1 - t));
}

class Clock extends ChangeNotifier {
  Clock(TickerProvider vsync) {
    _ticker = vsync.createTicker((elapsed) {
      seconds = elapsed.inMicroseconds / 1e6;
      notifyListeners();
    })..start();
  }

  late final Ticker _ticker;
  double seconds = 0;

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
    this.offset = const Offset(0, 22),
    this.scale = 1.0,
    this.rotateX = 0.0,
    this.curve = gentle,
    this.alignment = Alignment.center,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;
  final Offset offset;
  final double scale;
  final double rotateX;
  final Curve curve;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final t = span(animation.value, begin, end, curve);
        final opacity = span(animation.value, begin, begin + (end - begin) * 0.45, Curves.easeOut);
        final rest = 1 - t;
        final m = Matrix4.identity()..setEntry(3, 2, 0.0014);
        m.translateByDouble(offset.dx * rest, offset.dy * rest, 0, 1);
        if (rotateX != 0) m.rotateX(rotateX * rest);
        final s = lerp(scale, 1, t);
        if (scale != 1.0) m.scaleByDouble(s, s, 1, 1);
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform(alignment: alignment, transform: m, child: inner),
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
    this.scale = 0.95,
    this.jelly = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool jelly;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with TickerProviderStateMixin {
  late final AnimationController _press;
  late final AnimationController _wobble;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 460));
    _wobble = AnimationController(vsync: this, duration: const Duration(milliseconds: 720));
  }

  @override
  void dispose() {
    _press.dispose();
    _wobble.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) => _press.animateTo(1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut);

  void _up() {
    _press.animateBack(0, duration: const Duration(milliseconds: 420), curve: settle);
    if (widget.jelly) _wobble.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _down : null,
      onTapUp: enabled ? (_) => _up() : null,
      onTapCancel: enabled ? _up : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_press, _wobble]),
        builder: (context, child) {
          final s = lerp(1, widget.scale, _press.value);
          final w = _wobble.value;
          final jelly = w == 0 ? 0.0 : math.sin(w * math.pi * 3.2) * math.exp(-4.2 * w) * 0.09;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(s * (1 + jelly), s * (1 - jelly), 1),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
