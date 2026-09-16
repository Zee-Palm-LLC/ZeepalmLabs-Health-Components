import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

typedef PathBuilder = Path Function(Size size);

/// Strokes a dashed path that draws itself in as [animation] advances.
class DashedPathPainter extends CustomPainter {
  DashedPathPainter({
    required this.buildPath,
    required this.animation,
    required this.color,
    this.curve = Curves.linear,
    this.strokeWidth = 1,
    this.dashLength = 4,
    this.gapLength = 5,
  }) : super(repaint: animation);

  final PathBuilder buildPath;
  final Animation<double> animation;
  final Curve curve;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final visible = curve.transform(animation.value);
    if (visible <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final metric in buildPath(size).computeMetrics()) {
      final end = metric.length * visible;
      for (var start = 0.0; start < end; start += dashLength + gapLength) {
        canvas.drawPath(metric.extractPath(start, math.min(start + dashLength, end)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedPathPainter oldDelegate) {
    return oldDelegate.buildPath != buildPath ||
        oldDelegate.animation != animation ||
        oldDelegate.curve != curve ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
