import 'dart:math' as math;

import 'package:flutter/material.dart';

class Confetti extends StatelessWidget {
  const Confetti({super.key, required this.progress, required this.origin, this.count = 70, this.seed = 7});

  final double progress;
  final Offset origin;
  final int count;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _Burst(progress: progress, origin: origin, count: count, seed: seed)),
    );
  }
}

class _Burst extends CustomPainter {
  _Burst({required this.progress, required this.origin, required this.count, required this.seed});

  final double progress;
  final Offset origin;
  final int count;
  final int seed;

  static const colors = [
    Color(0xFF8B5CFF),
    Color(0xFFF77AA3),
    Color(0xFFFFC46B),
    Color(0xFF2CDAA2),
    Color(0xFF7FE9F2),
    Color(0xFFFFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final rnd = math.Random(seed);
    final p = Paint();
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (rnd.nextDouble() - 0.5) * math.pi * 1.5;
      final speed = 260 + rnd.nextDouble() * 360;
      final spin = (rnd.nextDouble() - 0.5) * 18;
      final t = progress * (0.8 + rnd.nextDouble() * 0.4);
      final drag = 1 - math.exp(-3.2 * t);
      final x = origin.dx + math.cos(angle) * speed * drag / 3.2;
      final y = origin.dy + math.sin(angle) * speed * drag / 3.2 + 420 * t * t;
      final fade = (1 - progress).clamp(0.0, 1.0);
      final w = 4.0 + rnd.nextDouble() * 5;
      final h = 2.5 + rnd.nextDouble() * 3;
      p.color = colors[i % colors.length].withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(spin * t);
      canvas.scale(1, math.cos(spin * t * 1.7).abs() * 0.8 + 0.2);
      if (i % 4 == 0) {
        canvas.drawCircle(Offset.zero, h * 0.8, p);
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), const Radius.circular(1)), p);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Burst old) => old.progress != progress;
}
