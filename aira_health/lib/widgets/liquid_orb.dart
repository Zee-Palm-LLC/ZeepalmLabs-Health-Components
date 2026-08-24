import 'dart:math' as math;

import 'package:flutter/material.dart';

class LiquidOrb extends StatefulWidget {
  const LiquidOrb({super.key, this.size = 220});

  final double size;

  @override
  State<LiquidOrb> createState() => _LiquidOrbState();
}

class _LiquidOrbState extends State<LiquidOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
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
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _OrbPainter(phase: _c.value),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final t = phase * math.pi * 2;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFFB9A4F0).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final rect = Rect.fromCircle(center: c, radius: r * 0.92);
    canvas.drawCircle(
      c,
      r * 0.92,
      Paint()
        ..shader = SweepGradient(
          startAngle: t,
          endAngle: t + math.pi * 2,
          colors: const [
            Color(0xFFD7B4F8),
            Color(0xFF8EC5FF),
            Color(0xFFF2B6D8),
            Color(0xFFC7B8FF),
            Color(0xFFD7B4F8),
          ],
        ).createShader(rect),
    );

    canvas.drawCircle(
      c + Offset(math.cos(t) * 10, math.sin(t * 1.3) * 8),
      r * 0.46,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
