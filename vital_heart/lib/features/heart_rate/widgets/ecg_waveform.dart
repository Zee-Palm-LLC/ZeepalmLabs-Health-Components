import 'dart:math' as math;
import 'dart:ui' show PathMetric, MaskFilter, BlurStyle;

import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EcgWaveform extends StatefulWidget {
  const EcgWaveform({super.key});

  @override
  State<EcgWaveform> createState() => _EcgWaveformState();
}

class _EcgWaveformState extends State<EcgWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84.h,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _EcgPainter(progress: _controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  _EcgPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final metrics = path.computeMetrics().first;
    final total = metrics.length;
    final sweep = total * 0.42;
    final head = (progress * total) % total;

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          AppColors.accent.withValues(alpha: 0.2),
          AppColors.accent,
          AppColors.heartGlow,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.ecgDim;

    _drawSegment(canvas, metrics, 0, head, activePaint);
    _drawSegment(canvas, metrics, head, head + sweep, activePaint);
    _drawSegment(canvas, metrics, head + sweep, total, dimPaint);

    final tip = metrics.getTangentForOffset(head + sweep);
    if (tip != null) {
      canvas.drawCircle(
        tip.position,
        5,
        Paint()
          ..color = AppColors.heartGlow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(tip.position, 3.2, Paint()..color = AppColors.white);
    }
  }

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final mid = h * 0.55;
    final unit = w / 8;

    final path = Path()..moveTo(0, mid);
    for (var i = 0; i < 8; i++) {
      final x = i * unit;
      path
        ..lineTo(x + unit * 0.18, mid)
        ..lineTo(x + unit * 0.28, mid - h * 0.34)
        ..lineTo(x + unit * 0.36, mid + h * 0.42)
        ..lineTo(x + unit * 0.46, mid - h * 0.12)
        ..lineTo(x + unit * 0.58, mid)
        ..lineTo(x + unit, mid);
    }
    return path;
  }

  void _drawSegment(
    Canvas canvas,
    PathMetric metrics,
    double start,
    double end,
    Paint paint,
  ) {
    if (end <= start) return;
    final extract = metrics.extractPath(start, math.min(end, metrics.length));
    canvas.drawPath(extract, paint);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
