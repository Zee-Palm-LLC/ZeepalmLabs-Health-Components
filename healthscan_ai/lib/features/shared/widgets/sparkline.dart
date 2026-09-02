import 'dart:math' as math;

import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 28,
    this.filled = true,
    this.progress = 1,
  });

  final List<double> values;
  final Color color;
  final double height;
  final bool filled;

  /// 0→1 reveal along the x-axis.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        child: CustomPaint(
          size: Size.infinite,
          painter: _SparklinePainter(
            values: values,
            color: color,
            filled: filled,
            progress: progress.clamp(0.0, 1.0),
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.filled,
    required this.progress,
  });

  final List<double> values;
  final Color color;
  final bool filled;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || progress <= 0) return;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    final points = _buildPoints(size);
    final path = _smoothPath(points);
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);

    if (filled) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height + 1)
        ..lineTo(0, size.height + 1)
        ..close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.32),
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
      );
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0.9),
          color,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(bounds);
    canvas.drawPath(path, linePaint);

    if (progress > 0.85) {
      final last = points.last;
      final dotGlow = Paint()
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(last, 4.5, dotGlow);
      canvas.drawCircle(last, 2.2, Paint()..color = color);
      canvas.drawCircle(
        last,
        1.1,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    canvas.restore();
  }

  List<Offset> _buildPoints(Size size) {
    final max = values.reduce(math.max);
    final min = values.reduce(math.min);
    final range = (max - min).clamp(0.001, double.infinity);
    const topPad = 4.0;
    const bottomPad = 3.0;
    final chartH = size.height - topPad - bottomPad;

    return List.generate(values.length, (i) {
      final x = i / (values.length - 1) * size.width;
      final normalized = (values[i] - min) / range;
      final y = size.height - bottomPad - normalized * chartH;
      return Offset(x, y);
    });
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i > 0 ? i - 1 : i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = points[i + 2 < points.length ? i + 2 : i + 1];

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
