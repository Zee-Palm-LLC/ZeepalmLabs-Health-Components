import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.diameter,
    required this.value,
    required this.color,
    required this.strokeWidth,
    this.trackColor = AppColors.track,
    this.animate = true,
    this.delay = Duration.zero,
    this.child,
  });

  final double diameter;
  final double value;
  final Color color;
  final double strokeWidth;
  final Color trackColor;
  final bool animate;
  final Duration delay;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: diameter,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: animate ? 0 : value, end: value),
        duration: animate ? const Duration(milliseconds: 1150) : Duration.zero,
        curve: AppMotion.enterCurve,
        builder: (context, progress, child) => CustomPaint(
          painter: _RingPainter(
            value: progress,
            color: color,
            trackColor: trackColor,
            strokeWidth: strokeWidth,
          ),
          child: Center(child: child),
        ),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  static const _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final sweep = math.pi * 2 * value.clamp(0.0, 1.0);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    if (sweep <= 0) return;

    canvas.drawArc(
      rect,
      _start,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          transform: const GradientRotation(_start),
          colors: [color.withValues(alpha: 0.45), color, color],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(rect)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final head = _start + sweep;
    final radius = (size.shortestSide - strokeWidth) / 2;
    final position = size.center(Offset.zero) + Offset(math.cos(head), math.sin(head)) * radius;

    canvas
      ..drawCircle(position, strokeWidth * 1.6, Paint()..color = color.withValues(alpha: 0.22))
      ..drawCircle(position, strokeWidth * 0.42, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
