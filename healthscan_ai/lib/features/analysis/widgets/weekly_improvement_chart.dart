import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';

class WeeklyImprovementChart extends StatelessWidget {
  const WeeklyImprovementChart({super.key});

  /// Weekly score trend — normalized in painter for a smooth upward curve.
  static const _values = [62.0, 65.0, 68.0, 71.0, 75.0, 79.0, 88.0];
  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Improvement',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, height: 1.3),
            children: [
              TextSpan(
                text: '+8% improvement ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successText,
                ),
              ),
              TextSpan(
                text: 'this week',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _LineChartPainter(values: _values),
              );
            },
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _labels.length; i++)
              Text(
                _labels[i],
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10.sp,
                  color: i == _labels.length - 1
                      ? AppColors.successText
                      : AppColors.textMuted,
                  fontWeight:
                      i == _labels.length - 1 ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final points = _buildPoints(size);

    _drawGrid(canvas, size, points);
    _drawAreaFill(canvas, bounds, points);
    _drawLine(canvas, bounds, points);
    _drawDots(canvas, points);
    _drawEndBadge(canvas, points.last);
  }

  List<Offset> _buildPoints(Size size) {
    final max = values.reduce(math.max);
    final min = values.reduce(math.min);
    final range = (max - min).clamp(0.001, double.infinity);
    const topPad = 10.0;
    const bottomPad = 6.0;
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

  void _drawGrid(Canvas canvas, Size size, List<Offset> points) {
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.55)
      ..strokeWidth = 0.8;

    for (var i = 1; i <= 2; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final point in points) {
      canvas.drawLine(
        Offset(point.dx, point.dy),
        Offset(point.dx, size.height),
        Paint()
          ..color = AppColors.border.withValues(alpha: 0.35)
          ..strokeWidth = 0.6,
      );
    }
  }

  void _drawAreaFill(Canvas canvas, Rect bounds, List<Offset> points) {
    final curve = _smoothPath(points);
    final fillPath = Path.from(curve)
      ..lineTo(points.last.dx, bounds.height)
      ..lineTo(points.first.dx, bounds.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.blueLight.withValues(alpha: 0.28),
            AppColors.blue.withValues(alpha: 0.08),
            AppColors.success.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bounds),
    );
  }

  void _drawLine(Canvas canvas, Rect bounds, List<Offset> points) {
    final curve = _smoothPath(points);

    canvas.drawPath(
      curve,
      Paint()
        ..color = AppColors.blueLight.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawPath(
      curve,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.blue.withValues(alpha: 0.65),
            AppColors.blueLight,
            AppColors.success,
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(bounds),
    );
  }

  void _drawDots(Canvas canvas, List<Offset> points) {
    for (var i = 0; i < points.length - 1; i++) {
      final point = points[i];
      final t = i / (points.length - 1);
      final dotColor = Color.lerp(AppColors.blueLight, AppColors.blue, t)!;

      canvas.drawCircle(
        point,
        5,
        Paint()..color = dotColor.withValues(alpha: 0.18),
      );
      canvas.drawCircle(point, 3.2, Paint()..color = dotColor);
      canvas.drawCircle(
        point,
        1.2,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  void _drawEndBadge(Canvas canvas, Offset last) {
    canvas.drawCircle(
      last,
      12,
      Paint()..color = AppColors.success.withValues(alpha: 0.22),
    );
    canvas.drawCircle(last, 9, Paint()..color = AppColors.success);
    canvas.drawCircle(
      last,
      9,
      Paint()
        ..color = AppColors.success.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final check = Path()
      ..moveTo(last.dx - 3.5, last.dy + 0.5)
      ..lineTo(last.dx - 0.5, last.dy + 3.5)
      ..lineTo(last.dx + 4.2, last.dy - 3.2);
    canvas.drawPath(
      check,
      Paint()
        ..color = AppColors.white
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => false;
}
