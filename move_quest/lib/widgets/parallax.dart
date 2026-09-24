import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../core/motion.dart';

class Tilt extends InheritedNotifier<ValueNotifier<Offset>> {
  const Tilt({super.key, required ValueNotifier<Offset> tilt, required super.child}) : super(notifier: tilt);

  static ValueNotifier<Offset> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Tilt>()!.notifier!;
}

class TiltField extends StatefulWidget {
  const TiltField({super.key, required this.child, this.drift = true});

  final Widget child;
  final bool drift;

  @override
  State<TiltField> createState() => _TiltFieldState();
}

class _TiltFieldState extends State<TiltField> with SingleTickerProviderStateMixin {
  final _tilt = ValueNotifier(Offset.zero);
  late final AnimationController _spring;
  Offset _held = Offset.zero;
  Offset _release = Offset.zero;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _spring = AnimationController.unbounded(vsync: this)..addListener(_tick);
  }

  void _tick() {
    if (_dragging) return;
    _tilt.value = _release * (1 - _spring.value);
  }

  @override
  void dispose() {
    _spring.dispose();
    _tilt.dispose();
    super.dispose();
  }

  void _start(DragStartDetails d) {
    _dragging = true;
    _spring.stop();
    _held = _tilt.value;
  }

  void _update(DragUpdateDetails d) {
    final size = context.size ?? const Size(393, 852);
    _held += Offset(d.delta.dx / size.width * 2.4, d.delta.dy / size.height * 2.4);
    _tilt.value = Offset(_held.dx.clamp(-1.0, 1.0), _held.dy.clamp(-1.0, 1.0));
  }

  void _end(DragEndDetails d) {
    _dragging = false;
    _release = _tilt.value;
    final sim = SpringSimulation(const SpringDescription(mass: 1, stiffness: 120, damping: 9), 0, 1, 0);
    _spring.animateWith(sim);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: _start,
      onPanUpdate: _update,
      onPanEnd: _end,
      child: Tilt(tilt: _tilt, child: widget.child),
    );
  }
}

class Depth extends StatelessWidget {
  const Depth({super.key, required this.depth, required this.child, this.idle = 0.35});

  final double depth;
  final Widget child;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final tilt = Tilt.of(context);
    return Tick(
      child: child,
      builder: (context, s, child) {
        final drift = Offset(math.sin(s * 0.37) * idle, math.sin(s * 0.29) * idle * 0.6);
        final o = (tilt.value + drift) * depth;
        return Transform.translate(offset: o, child: child);
      },
    );
  }
}

class Breathe extends StatelessWidget {
  const Breathe({
    super.key,
    required this.child,
    this.period = 3.6,
    this.amount = 0.012,
    this.bob = 1.2,
    this.alignment = Alignment.bottomCenter,
    this.phase = 0,
  });

  final Widget child;
  final double period;
  final double amount;
  final double bob;
  final Alignment alignment;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return Tick(
      child: child,
      builder: (context, s, child) {
        final w = wave(s, period, phase);
        final m = Matrix4.identity()
          ..translateByDouble(0, -bob * w, 0, 1)
          ..scaleByDouble(1 - amount * 0.35 * w, 1 + amount * w, 1, 1);
        return Transform(alignment: alignment, transform: m, child: child);
      },
    );
  }
}
