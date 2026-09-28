import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../core/motion.dart';

class Stroke {
  const Stroke(this.from, this.to, {this.width = 4.4, this.bend = 0});

  final Offset from;
  final Offset to;
  final double width;
  final double bend;
}

class Sparks extends StatelessWidget {
  const Sparks({
    super.key,
    required this.strokes,
    required this.colors,
    required this.entrance,
    required this.begin,
    required this.origin,
    this.period = 2.8,
  });

  final List<Stroke> strokes;
  final List<Color> colors;
  final Animation<double> entrance;
  final double begin;
  final Offset origin;
  final double period;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, _) => CustomPaint(
        painter: _SparkPainter(this, seconds),
        size: Size.infinite,
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.w, this.seconds) : super(repaint: w.entrance);

  final Sparks w;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final e = w.entrance.value;
    for (var i = 0; i < w.strokes.length; i++) {
      final s = w.strokes[i];
      final start = w.begin + i * 0.05;
      final draw = span(e, start, start + 0.22, gentle);
      if (draw <= 0) continue;
      final settled = e >= 1 ? 1.0 : span(e, start + 0.22, start + 0.3, Curves.linear);
      final phase = ((seconds / w.period) + i * 0.06) % 1.0;
      final pulse = settled * math.pow(math.sin(math.pi * ((phase - 0.6) / 0.35).clamp(0.0, 1.0)), 2).toDouble();
      final dir = (s.to - s.from);
      final len = dir.distance;
      final unit = dir / len;
      final away = ((s.from + s.to) / 2 - w.origin);
      final push = away / away.distance * 3.2 * pulse;
      final a = s.from + push;
      final b = s.from + push + unit * len * draw * (1 + 0.1 * pulse);
      final mid = (a + b) / 2 + Offset(-unit.dy, unit.dx) * s.bend;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.width * (1 + 0.12 * pulse)
        ..shader = ui.Gradient.linear(a, b, w.colors, [0, 1]);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.seconds != seconds;
}
