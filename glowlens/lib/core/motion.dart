import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Animation<double> stage(Animation<double> parent, double begin, double end, {Curve curve = Curves.easeOutCubic}) {
  return CurvedAnimation(
    parent: parent,
    curve: Interval(begin, end, curve: curve),
  );
}

double lerp(double a, double b, double t) => a + (b - a) * t;

double window(double t, double begin, double end, [Curve curve = Curves.linear]) {
  if (t <= begin) return 0;
  if (t >= end) return 1;
  return curve.transform((t - begin) / (end - begin));
}

class Entrance extends AnimatedWidget {
  const Entrance({
    super.key,
    required Animation<double> animation,
    required this.child,
    this.offset = const Offset(0, 22),
    this.blur = 0,
    this.scale = 1,
    this.alignment = Alignment.center,
  }) : super(listenable: animation);

  final Widget child;
  final Offset offset;
  final double blur;
  final double scale;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    if (t >= 1) return child;
    final visible = t.clamp(0.0, 1.0);
    Widget result = child;
    final sigma = blur * (1 - visible);
    if (sigma > 0.05) {
      result = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: result,
      );
    }
    if (scale != 1) {
      result = Transform.scale(scale: lerp(scale, 1, t), alignment: alignment, child: result);
    }
    return Opacity(
      opacity: visible,
      child: Transform.translate(offset: offset * (1 - t), child: result),
    );
  }
}

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.94,
    this.haptic = true,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  static const _release = SpringDescription(mass: 1, stiffness: 520, damping: 18);

  @override
  void initState() {
    super.initState();
    _press = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down() {
    if (widget.haptic) HapticFeedback.selectionClick();
    _press.animateTo(1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut);
  }

  void _up() {
    _press.animateWith(SpringSimulation(_release, _press.value, 0, 0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: widget.onTap == null ? null : (_) => _down(),
      onTapUp: widget.onTap == null ? null : (_) => _up(),
      onTapCancel: widget.onTap == null ? null : _up,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _press,
        child: widget.child,
        builder: (context, child) {
          final amount = 1 - (1 - widget.scale) * _press.value;
          return Transform.scale(scale: amount, child: child);
        },
      ),
    );
  }
}

mixin ClockMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  final ValueNotifier<double> clock = ValueNotifier(0);
  Ticker? _clockTicker;

  void startClock() {
    _clockTicker ??= createTicker((elapsed) {
      clock.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    })..start();
  }

  void disposeClock() {
    _clockTicker?.dispose();
    clock.dispose();
  }
}

double wave(double seconds, double period, [double phase = 0]) {
  return math.sin((seconds / period + phase) * math.pi * 2);
}

class Swing extends StatefulWidget {
  const Swing({
    super.key,
    required this.child,
    required this.trigger,
    this.alignment = Alignment.topCenter,
    this.amount = 0.32,
  });

  final Widget child;
  final int trigger;
  final Alignment alignment;
  final double amount;

  @override
  State<Swing> createState() => _SwingState();
}

class _SwingState extends State<Swing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  }

  @override
  void didUpdateWidget(Swing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final angle = math.sin(t * math.pi * 7) * math.pow(1 - t, 2.2) * widget.amount;
        return Transform.rotate(angle: angle, alignment: widget.alignment, child: child);
      },
    );
  }
}
