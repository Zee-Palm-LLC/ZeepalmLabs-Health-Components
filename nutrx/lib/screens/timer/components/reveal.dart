import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'math_motion.dart';

/// Math-driven entrance: settle + sway + spiral fade + soft scale pop.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 780),
    this.offset = const Offset(0, 28),
    this.scaleFrom = 0.88,
    this.twist = 0.06,
    this.curve = MathCurves.settle,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double scaleFrom;
  final double twist;
  final Curve curve;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final raw = widget.curve.transform(_c.value);
        final fade = MathMotion.spiralBlend(_c.value).clamp(0.0, 1.0);
        final settle = MathMotion.settle(_c.value);
        final sway = MathMotion.wobble(_c.value, amp: 10, freq: 2.2);
        final pop = 0.045 * math.sin(settle.clamp(0.0, 1.0) * math.pi);
        final twist =
            widget.twist * MathMotion.wobble(_c.value, amp: 1, freq: 1.6);

        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(
              widget.offset.dx * (1 - raw) + sway,
              widget.offset.dy * (1 - settle),
            ),
            child: Transform.rotate(
              angle: twist,
              child: Transform.scale(
                scale: widget.scaleFrom +
                    (1 - widget.scaleFrom) * settle +
                    pop,
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Idle sinusoidal breath — subtle living UI.
class Breath extends StatefulWidget {
  const Breath({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 2400),
    this.scaleLo = 0.985,
    this.scaleHi = 1.015,
    this.glow = false,
  });

  final Widget child;
  final Duration period;
  final double scaleLo;
  final double scaleHi;
  final bool glow;

  @override
  State<Breath> createState() => _BreathState();
}

class _BreathState extends State<Breath> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final phase = _c.value * math.pi * 2;
        final s = MathMotion.breath(
          phase,
          lo: widget.scaleLo,
          hi: widget.scaleHi,
        );
        final glowT = 0.5 + 0.5 * math.sin(phase);
        return Transform.scale(
          scale: s,
          child: widget.glow
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFC107)
                            .withValues(alpha: 0.12 + 0.18 * glowT),
                        blurRadius: 10 + 8 * glowT,
                        spreadRadius: 0.5 * glowT,
                      ),
                    ],
                  ),
                  child: child,
                )
              : child,
        );
      },
      child: widget.child,
    );
  }
}

Duration revealDelay(int index, {int stepMs = 78}) {
  // Slight exponential stagger so later items feel cascading.
  final t = index * stepMs + (index * index * 4);
  return Duration(milliseconds: t);
}
