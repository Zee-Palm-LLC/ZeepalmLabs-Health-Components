import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';

class CometBorder extends StatelessWidget {
  const CometBorder({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.edge = const [Color(0xFF6A55B8), Color(0xFF5D4796), Color(0xFF6E5DAE)],
    this.comet = const Color(0xFFD9B8FF),
    this.period = 4.8,
  });

  final double width;
  final double height;
  final Widget child;
  final List<Color> edge;
  final Color comet;
  final double period;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, inner) => CustomPaint(
        painter: _Comet(phase: (s % period) / period, edge: edge, comet: comet),
        child: inner,
      ),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class _Comet extends CustomPainter {
  _Comet({required this.phase, required this.edge, required this.comet});

  final double phase;
  final List<Color> edge;
  final Color comet;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect.deflate(0.65), Radius.circular(size.height / 2));
    canvas.drawRRect(rr, Paint()..color = const Color(0x2A060420));
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..shader = LinearGradient(colors: edge).createShader(rect);
    canvas.drawRRect(rr, base);

    final path = Path()..addRRect(rr);
    final metric = path.computeMetrics().first;
    final total = metric.length;
    final head = phase * total;
    const tail = 110.0;
    for (var i = 0; i < 22; i++) {
      final f = i / 22;
      final a = (head - f * tail) % total;
      final b = (a + tail / 22 + 0.6) % total;
      if (b < a) continue;
      final seg = metric.extractPath(a, b);
      final k = math.pow(1 - f, 2).toDouble();
      canvas.drawPath(
        seg,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.6 + 1.2 * k
          ..color = comet.withValues(alpha: 0.75 * k),
      );
      if (i < 4) {
        canvas.drawPath(
          seg,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..color = comet.withValues(alpha: 0.22 * k)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_Comet old) => old.phase != phase;
}
