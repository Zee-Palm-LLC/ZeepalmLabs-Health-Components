import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion.dart';

class PanSparks extends StatelessWidget {
  const PanSparks({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(builder: (context, s, _) => CustomPaint(painter: _SparkPainter(s))),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.seconds);

  final double seconds;

  static final _seeds = List.generate(16, (i) {
    final r = math.Random(i * 31 + 5);
    return (r.nextDouble(), r.nextDouble(), r.nextDouble(), r.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final (i, (a, b, c, d)) in _seeds.indexed) {
      final period = 1.6 + c * 1.4;
      final u = (seconds / period + a) % 1.0;
      final y = size.height * (1 - u);
      final x = size.width / 2 + (b - 0.5) * size.width * 0.8 * u + math.sin((u * 2 + d) * math.pi * 2) * 4;
      final fade = math.sin(u * math.pi);
      if (i.isEven) {
        final r = 1.1 + d * 1.5;
        canvas.drawCircle(
          Offset(x, y),
          r * 2.4,
          Paint()
            ..color = const Color(0xFFFFE3B0).withValues(alpha: 0.22 * fade)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.6),
        );
        canvas.drawCircle(Offset(x, y), r, Paint()..color = const Color(0xFFFFF4DC).withValues(alpha: 0.85 * fade));
      } else {
        final path = Path()..moveTo(x, y + 10);
        path.cubicTo(x - 5, y + 5, x + 5, y - 2, x, y - 9);
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.32 * fade * (1 - u * 0.5))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.seconds != seconds;
}
