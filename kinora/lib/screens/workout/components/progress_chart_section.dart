import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';

class ProgressChartSection extends StatefulWidget {
  const ProgressChartSection({super.key});

  @override
  State<ProgressChartSection> createState() => _ProgressChartSectionState();
}

class _ProgressChartSectionState extends State<ProgressChartSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  /// kg values Mon→Sun
  static const _values = <double>[28, 32, 36, 47.5, 41, 38, 34];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _activeIndex = 3;
  static const _maxKg = 50.0;
  static const _minKg = 20.0;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 12, 12),
        decoration: BoxDecoration(
          color: KinoraColors.cardSoft.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: KinoraColors.lime.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'My Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KinoraColors.text,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => HapticFeedback.selectionClick(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: KinoraColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'This Week',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: KinoraColors.text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          LucideIcons.chevron_down,
                          size: 14,
                          color: KinoraColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _enter,
              builder: (context, _) {
                final t = MathMotion.settle(_enter.value, alpha: 5.5, omega: 10);
                final shown = 47.5 * t;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      shown.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: KinoraColors.lime,
                        height: 1,
                        letterSpacing: -0.6,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 4),
                      child: Text(
                        'kg',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: KinoraColors.lime.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Peak · Thu',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: KinoraColors.mutedSoft,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 198,
              child: AnimatedBuilder(
                animation: _enter,
                builder: (context, _) {
                  final t = MathMotion.smootherstep(_enter.value);
                  return CustomPaint(
                    painter: _ProgressChartPainter(
                      values: _values,
                      days: _days,
                      progress: t,
                      activeIndex: _activeIndex,
                      minKg: _minKg,
                      maxKg: _maxKg,
                    ),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  _ProgressChartPainter({
    required this.values,
    required this.days,
    required this.progress,
    required this.activeIndex,
    required this.minKg,
    required this.maxKg,
  });

  final List<double> values;
  final List<String> days;
  final double progress;
  final int activeIndex;
  final double minKg;
  final double maxKg;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 36.0;
    const rightPad = 8.0;
    const topPad = 28.0;
    const bottomPad = 28.0;

    final chart = Rect.fromLTRB(
      leftPad,
      topPad,
      size.width - rightPad,
      size.height - bottomPad,
    );

    final labelStyle = TextStyle(
      color: KinoraColors.muted.withValues(alpha: 0.85),
      fontSize: 10,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );

    // Y labels
    for (final kg in [50, 40, 30, 20]) {
      final y = _yFor(kg.toDouble(), chart);
      _drawText(canvas, '${kg}kg', Offset(0, y - 6), labelStyle);
      // faint grid
      canvas.drawLine(
        Offset(chart.left, y),
        Offset(chart.right, y),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.04)
          ..strokeWidth = 1,
      );
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = chart.left + chart.width * (i / (values.length - 1));
      final y = _yFor(values[i], chart);
      points.add(Offset(x, y));
    }

    // Animate line reveal by clipping horizontally
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(
        0,
        0,
        chart.left + chart.width * progress,
        size.height,
      ),
    );

    final path = _smoothPath(points);
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();

    final fill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, chart.top),
        Offset(0, chart.bottom),
        [
          KinoraColors.lime.withValues(alpha: 0.28),
          KinoraColors.lime.withValues(alpha: 0.02),
        ],
      );
    canvas.drawPath(fillPath, fill);

    final line = Paint()
      ..color = KinoraColors.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas.drawPath(path, line);

    // Nodes
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final isActive = i == activeIndex;
      if (isActive) {
        canvas.drawCircle(
          p,
          10,
          Paint()
            ..color = KinoraColors.lime.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      canvas.drawCircle(
        p,
        isActive ? 5.8 : 4,
        Paint()..color = KinoraColors.bg,
      );
      canvas.drawCircle(
        p,
        isActive ? 4.4 : 3,
        Paint()..color = KinoraColors.lime,
      );
    }
    canvas.restore();

    // Tooltip on active point (fades in late)
    final tipT = MathMotion.softBounce(((progress - 0.55) / 0.45).clamp(0.0, 1.0));
    if (tipT > 0) {
      final ap = points[activeIndex];
      final label = '${values[activeIndex]} kg';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final bubbleW = tp.width + 16;
      final bubbleH = tp.height + 10;
      final bubble = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(ap.dx, ap.dy - 22),
          width: bubbleW,
          height: bubbleH,
        ),
        const Radius.circular(8),
      );

      canvas.save();
      canvas.translate(ap.dx, ap.dy - 22);
      canvas.scale(tipT, tipT);
      canvas.translate(-ap.dx, -(ap.dy - 22));

      canvas.drawRRect(bubble, Paint()..color = KinoraColors.lime);
      // tiny pointer
      final tip = Path()
        ..moveTo(ap.dx - 5, ap.dy - 22 + bubbleH / 2 - 1)
        ..lineTo(ap.dx + 5, ap.dy - 22 + bubbleH / 2 - 1)
        ..lineTo(ap.dx, ap.dy - 10)
        ..close();
      canvas.drawPath(tip, Paint()..color = KinoraColors.lime);

      tp.paint(
        canvas,
        Offset(ap.dx - tp.width / 2, ap.dy - 22 - tp.height / 2),
      );
      canvas.restore();
    }

    // X labels
    for (var i = 0; i < days.length; i++) {
      final x = chart.left + chart.width * (i / (days.length - 1));
      final active = i == activeIndex;
      _drawText(
        canvas,
        days[i],
        Offset(x - 12, chart.bottom + 8),
        labelStyle.copyWith(
          color: active ? KinoraColors.lime : KinoraColors.muted,
          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        ),
      );
    }
  }

  double _yFor(double kg, Rect chart) {
    final n = ((kg - minKg) / (maxKg - minKg)).clamp(0.0, 1.0);
    return chart.bottom - n * chart.height;
  }

  Path _smoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }
    return path;
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
