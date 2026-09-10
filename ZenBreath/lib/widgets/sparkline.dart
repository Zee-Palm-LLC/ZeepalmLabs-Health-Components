import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.points,
    required this.color,
    this.strokeWidth = 1.8,
    this.filled = false,
    this.showHead = true,
    this.duration = const Duration(milliseconds: 1200),
  });

  final List<double> points;
  final Color color;
  final double strokeWidth;
  final bool filled;
  final bool showHead;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: AppMotion.enterCurve,
      builder: (context, progress, _) => CustomPaint(
        painter: _SparklinePainter(
          points: points,
          color: color,
          strokeWidth: strokeWidth,
          filled: filled,
          showHead: showHead,
          progress: progress,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.filled,
    required this.showHead,
    required this.progress,
  });

  final List<double> points;
  final Color color;
  final double strokeWidth;
  final bool filled;
  final bool showHead;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || progress <= 0) return;

    final min = points.reduce((a, b) => a < b ? a : b);
    final max = points.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < 0.001 ? 1.0 : max - min;
    final inset = strokeWidth + 1;

    final coords = <Offset>[
      for (var i = 0; i < points.length; i++)
        Offset(
          size.width * i / (points.length - 1),
          inset + (size.height - inset * 2) * (1 - (points[i] - min) / span),
        ),
    ];

    final path = Path()..moveTo(coords.first.dx, coords.first.dy);
    for (var i = 0; i < coords.length - 1; i++) {
      final current = coords[i];
      final next = coords[i + 1];
      final control = (current.dx + next.dx) / 2;
      path.cubicTo(control, current.dy, control, next.dy, next.dx, next.dy);
    }

    final metric = path.computeMetrics().first;
    final drawnLength = metric.length * progress;
    final drawn = metric.extractPath(0, drawnLength);

    if (filled) {
      final head = metric.getTangentForOffset(drawnLength)?.position ?? coords.last;
      final area = Path.from(drawn)
        ..lineTo(head.dx, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.24), color.withValues(alpha: 0.0)],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(
      drawn,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    if (showHead) {
      final head = metric.getTangentForOffset(drawnLength)?.position;
      if (head != null) {
        canvas
          ..drawCircle(head, strokeWidth * 2.6, Paint()..color = color.withValues(alpha: 0.20))
          ..drawCircle(head, strokeWidth * 1.1, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.points != points ||
      oldDelegate.color != color;
}
