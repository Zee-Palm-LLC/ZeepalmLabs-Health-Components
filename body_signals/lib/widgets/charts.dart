import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_motion.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.size,
    this.strokeWidth = 2,
    this.animate = true,
    this.delay = Duration.zero,
  });

  final List<double> values;
  final Color color;
  final Size? size;
  final double strokeWidth;
  final bool animate;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final resolved = size ?? Size(96.w, 38.h);

    if (!animate) {
      return CustomPaint(
        size: resolved,
        painter: _SparklinePainter(
          values: values,
          color: color,
          strokeWidth: strokeWidth,
          progress: 1,
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1250),
      curve: AppMotion.emphasized,
      builder: (_, progress, _) => CustomPaint(
        size: resolved,
        painter: _SparklinePainter(
          values: values,
          color: color,
          strokeWidth: strokeWidth,
          progress: progress,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final double progress;

  static const _pad = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || progress <= 0) return;

    final lowest = values.reduce((a, b) => a < b ? a : b);
    final highest = values.reduce((a, b) => a > b ? a : b);
    final range = (highest - lowest).abs() < 0.001 ? 1.0 : highest - lowest;
    final stepX = size.width / (values.length - 1);

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          i * stepX,
          _pad + (1 - (values[i] - lowest) / range) * (size.height - _pad * 2),
        ),
    ];

    final full = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];
      final midX = (from.dx + to.dx) / 2;
      full.cubicTo(midX, from.dy, midX, to.dy, to.dx, to.dy);
    }

    final metric = full.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    final head = metric.getTangentForOffset(metric.length * progress)?.position;

    if (head != null) {
      final fill = Path.from(drawn)
        ..lineTo(head.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();

      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.32),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(
      drawn,
      _stroke(strokeWidth + 3)
        ..color = color.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(drawn, _stroke(strokeWidth)..color = color);

    if (head != null) {
      canvas.drawCircle(
        head,
        strokeWidth + 3.4,
        Paint()..color = color.withValues(alpha: 0.22),
      );
      canvas.drawCircle(head, strokeWidth + 0.4, Paint()..color = Colors.white);
      canvas.drawCircle(head, strokeWidth - 0.4, Paint()..color = color);
    }
  }

  Paint _stroke(double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.progress != progress || old.values != values || old.color != color;
}

class RingProgress extends StatelessWidget {
  const RingProgress({
    super.key,
    required this.progress,
    required this.color,
    this.size = 54,
    this.thickness = 4.5,
    this.child,
  });

  final double progress;
  final Color color;
  final double size;
  final double thickness;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: AppMotion.emphasized,
      builder: (_, value, inner) => CustomPaint(
        size: Size.square(size.w),
        painter: _RingPainter(
          progress: value,
          color: color,
          thickness: thickness,
        ),
        child: SizedBox.square(
          dimension: size.w,
          child: Center(child: inner),
        ),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.thickness,
  });

  final double progress;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = Colors.white.withValues(alpha: 0.07),
    );

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness + 3
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + 2 * math.pi,
          colors: [
            color.withValues(alpha: 0.35),
            color,
            color.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

class SegmentedMeter extends StatelessWidget {
  const SegmentedMeter({
    super.key,
    required this.progress,
    this.segments = 9,
    this.color = AppColors.cyan,
  });

  final double progress;
  final int segments;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1100),
      curve: AppMotion.emphasized,
      builder: (_, value, _) {
        final filled = (segments * value).round();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(segments, (i) {
            final lit = i < filled;
            return AnimatedContainer(
              duration: AppMotion.fast,
              width: 5.w,
              height: lit ? 18.h : 10.h,
              margin: EdgeInsets.symmetric(horizontal: 1.9.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.r),
                color: lit ? color : color.withValues(alpha: 0.14),
                boxShadow: lit
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.55),
                          blurRadius: 7,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }
}

class TrendBarChart extends StatefulWidget {
  const TrendBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.unit,
    this.initialIndex = -1,
    this.height = 96,
  });

  final List<double> values;
  final List<String> labels;
  final String unit;
  final int initialIndex;
  final double height;

  @override
  State<TrendBarChart> createState() => _TrendBarChartState();
}

class _TrendBarChartState extends State<TrendBarChart>
    with SingleTickerProviderStateMixin {
  late int _selected = widget.initialIndex;
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peak = widget.values.reduce((a, b) => a > b ? a : b);
    final labelSlot = 18.h;
    final barSpace = widget.height.h - labelSlot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.values.length, (i) {
              final active = i == _selected;
              final target = (widget.values[i] / peak) * barSpace;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = i);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: labelSlot,
                          child: AnimatedOpacity(
                            opacity: active ? 1 : 0,
                            duration: AppMotion.fast,
                            child: Text(
                              widget.values[i].toStringAsFixed(0),
                              style: GoogleFonts.poppins(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cyan,
                              ),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _grow,
                          builder: (_, _) {
                            final delayed = Interval(
                              (i / widget.values.length) * 0.5,
                              1.0,
                              curve: AppMotion.emphasized,
                            ).transform(_grow.value);

                            return AnimatedContainer(
                              duration: AppMotion.medium,
                              curve: AppMotion.enter,
                              height: target * delayed,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.r),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: active
                                      ? [
                                          AppColors.blue
                                              .withValues(alpha: 0.60),
                                          AppColors.cyan,
                                        ]
                                      : [
                                          AppColors.blue
                                              .withValues(alpha: 0.16),
                                          AppColors.cyan
                                              .withValues(alpha: 0.42),
                                        ],
                                ),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: AppColors.cyan
                                              .withValues(alpha: 0.45),
                                          blurRadius: 16,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: List.generate(widget.labels.length, (i) {
            final active = i == _selected;
            return Expanded(
              child: AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                style: GoogleFonts.poppins(
                  fontSize: 8.sp,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
                child: Text(widget.labels[i], textAlign: TextAlign.center),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class EcgLine extends StatefulWidget {
  const EcgLine({
    super.key,
    this.width = 160,
    this.height = 34,
    this.color = AppColors.rose,
  });

  final double width;
  final double height;
  final Color color;

  @override
  State<EcgLine> createState() => _EcgLineState();
}

class _EcgLineState extends State<EcgLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          size: Size(widget.width.w, widget.height.h),
          painter: _EcgPainter(phase: _controller.value, color: widget.color),
          isComplex: true,
          willChange: true,
        ),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  _EcgPainter({required this.phase, required this.color});

  final double phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final path = Path()..moveTo(0, mid);

    const beats = 2;
    final span = size.width / beats;
    for (var b = 0; b < beats; b++) {
      final x = b * span;
      path
        ..lineTo(x + span * 0.24, mid)
        ..lineTo(x + span * 0.32, mid - size.height * 0.16)
        ..lineTo(x + span * 0.40, mid + size.height * 0.10)
        ..lineTo(x + span * 0.47, mid - size.height * 0.46)
        ..lineTo(x + span * 0.55, mid + size.height * 0.34)
        ..lineTo(x + span * 0.63, mid)
        ..lineTo(x + span, mid);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: 0.30),
    );

    final metric = path.computeMetrics().first;
    final headLength = metric.length * 0.26;
    final end = metric.length * phase;
    final begin = math.max(0.0, end - headLength);
    final trail = metric.extractPath(begin, end);

    canvas.drawPath(
      trail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(
          Offset(begin / metric.length * size.width, 0),
          Offset(end / metric.length * size.width, 0),
          [color.withValues(alpha: 0.0), color],
        ),
    );

    final head = metric.getTangentForOffset(end)?.position;
    if (head != null) {
      canvas.drawCircle(
        head,
        3.2,
        Paint()..color = color.withValues(alpha: 0.30),
      );
      canvas.drawCircle(head, 1.8, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _EcgPainter old) => old.phase != phase;
}
