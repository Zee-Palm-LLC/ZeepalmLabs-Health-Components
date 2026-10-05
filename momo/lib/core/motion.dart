import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const gentle = Cubic(0.22, 1.0, 0.32, 1.0);
const swift = Cubic(0.16, 0.9, 0.24, 1.0);
const settle = Cubic(0.34, 1.45, 0.42, 1.0);
const breathe = Cubic(0.45, 0.05, 0.55, 0.95);
const launch = Cubic(0.7, 0.0, 0.84, 0.0);
const glide = Cubic(0.65, 0.0, 0.35, 1.0);

double span(double t, double begin, double end, [Curve curve = gentle]) {
  if (end <= begin) return t >= end ? 1 : 0;
  return curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));
}

double lerp(double a, double b, double t) => a + (b - a) * t;

double wave(double seconds, double period, [double phase = 0]) => math.sin((seconds / period + phase) * math.pi * 2);

double spring(double t, {double bounce = 0.4, double freq = 3.2}) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  return 1 - math.exp(-6.4 * t) * math.cos(freq * math.pi * t) * (1 + bounce * (1 - t));
}

class Clock extends ChangeNotifier {
  static bool frozen = false;

  Duration _elapsed = Duration.zero;

  double get seconds => _elapsed.inMicroseconds / 1e6;

  void tick(Duration elapsed) {
    if (frozen) return;
    _elapsed = elapsed;
    notifyListeners();
  }
}

class ClockScope extends InheritedWidget {
  const ClockScope({super.key, required this.clock, required super.child});

  final Clock clock;

  static Clock of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ClockScope>()!.clock;

  @override
  bool updateShouldNotify(ClockScope old) => old.clock != clock;
}

class ClockHost extends StatefulWidget {
  const ClockHost({super.key, required this.child});

  final Widget child;

  @override
  State<ClockHost> createState() => _ClockHostState();
}

class _ClockHostState extends State<ClockHost> with SingleTickerProviderStateMixin {
  final _clock = Clock();
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_clock.tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClockScope(clock: _clock, child: widget.child);
}

class Tick extends StatelessWidget {
  const Tick({super.key, required this.builder, this.child});

  final Widget Function(BuildContext context, double seconds, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final clock = ClockScope.of(context);
    final live = TickerMode.valuesOf(context).enabled;
    return ListenableBuilder(
      listenable: live ? clock : const AlwaysStoppedAnimation(0),
      builder: (context, child) => builder(context, clock.seconds, child),
      child: child,
    );
  }
}

class Staged extends StatelessWidget {
  const Staged({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotateX = 0.0,
    this.rotateY = 0.0,
    this.rotateZ = 0.0,
    this.curve = gentle,
    this.alignment = Alignment.center,
    this.fade = true,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;
  final Offset offset;
  final double scale;
  final double rotateX;
  final double rotateY;
  final double rotateZ;
  final Curve curve;
  final Alignment alignment;
  final bool fade;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final t = span(animation.value, begin, end, curve);
        final rest = 1 - t;
        final m = Matrix4.identity()..setEntry(3, 2, 0.0014);
        m.translateByDouble(offset.dx * rest, offset.dy * rest, 0, 1);
        if (rotateX != 0) m.rotateX(rotateX * rest);
        if (rotateY != 0) m.rotateY(rotateY * rest);
        if (rotateZ != 0) m.rotateZ(rotateZ * rest);
        final s = lerp(scale, 1, t);
        m.scaleByDouble(s, s, 1, 1);
        return Opacity(
          opacity: fade ? span(animation.value, begin, begin + (end - begin) * 0.45, Curves.linear) : 1,
          child: Transform(alignment: alignment, transform: m, child: inner),
        );
      },
      child: child,
    );
  }
}

class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.95, this.haptic = true});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

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

  void _down(TapDownDetails _) => _c.animateTo(1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut);

  void _up() => _c.animateBack(0, duration: const Duration(milliseconds: 520), curve: settle);

  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: active ? _down : null,
      onTapUp: active ? (_) => _up() : null,
      onTapCancel: active ? _up : null,
      onTap: active
          ? () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.scale(scale: lerp(1, widget.scale, _c.value), child: child),
        child: widget.child,
      ),
    );
  }
}

class Entrance extends StatefulWidget {
  const Entrance({super.key, required this.duration, required this.builder, this.delay = Duration.zero});

  final Duration duration;
  final Duration delay;
  final Widget Function(BuildContext context, Animation<double> animation) builder;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _c);
}
