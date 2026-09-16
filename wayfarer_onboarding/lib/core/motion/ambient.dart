import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Seamless sine for a 0..1 looping controller; [cycles] must be whole to avoid a
/// jump when the loop wraps.
double wave(double t, {double phase = 0, int cycles = 1}) {
  return math.sin((t * cycles + phase) * 2 * math.pi);
}

class Floating extends StatelessWidget {
  const Floating({
    super.key,
    required this.animation,
    required this.child,
    this.amplitude = const Offset(0, 3),
    this.phase = 0,
  });

  final Animation<double> animation;
  final Offset amplitude;
  final double phase;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Transform.translate(
        offset: amplitude * wave(animation.value, phase: phase),
        child: child,
      ),
    );
  }
}

class PulseRing extends StatelessWidget {
  const PulseRing({
    super.key,
    required this.animation,
    required this.color,
    required this.diameter,
    this.cycles = 3,
  });

  final Animation<double> animation;
  final Color color;
  final double diameter;
  final int cycles;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: diameter,
      child: CustomPaint(
        painter: _PulseRingPainter(animation: animation, color: color, cycles: cycles),
      ),
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  _PulseRingPainter({required this.animation, required this.color, required this.cycles})
      : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final int cycles;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final lag in const [0.0, 0.5]) {
      final progress = (animation.value * cycles + lag) % 1.0;
      paint.color = color.withValues(alpha: color.a * (1 - progress) * 0.8);
      canvas.drawCircle(center, maxRadius * Curves.easeOut.transform(progress), paint);
    }
  }

  @override
  bool shouldRepaint(_PulseRingPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.color != color ||
        oldDelegate.cycles != cycles;
  }
}
