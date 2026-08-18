import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightDial extends StatefulWidget {
  static const double heightFactor = 0.72;
  static const double gaugeCenterYFactor = 0.56;

  final double minValue;
  final double maxValue;
  final double value;
  final String unitLabel;
  final ValueChanged<double> onChanged;

  const WeightDial({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.unitLabel,
    required this.onChanged,
  });

  @override
  State<WeightDial> createState() => _WeightDialState();
}

class _WeightDialState extends State<WeightDial>
    with SingleTickerProviderStateMixin {
  static const double _bottomInset = 14;
  int _lastHapticValue = -1;
  late final AnimationController _liquidController;

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  void _handleDrag(DragUpdateDetails details, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = width * WeightDial.heightFactor;
    final center = Offset(width / 2, height * WeightDial.gaugeCenterYFactor);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;

    double angleDeg = math.atan2(dy, dx) * 180 / math.pi;
    if (angleDeg < 0) angleDeg += 360;

    if (angleDeg < 180) {
      angleDeg = angleDeg <= 270 ? 180 : 360;
    }

    final t = ((angleDeg - 180) / 180).clamp(0.0, 1.0);
    final raw = widget.minValue + t * (widget.maxValue - widget.minValue);
    final snapped = (raw * 2).round() / 2;
    final clamped = snapped.clamp(widget.minValue, widget.maxValue).toDouble();

    final intValue = clamped.round();
    if (intValue != _lastHapticValue) {
      HapticFeedback.selectionClick();
      _lastHapticValue = intValue;
    }
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * WeightDial.heightFactor + _bottomInset;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            _lastHapticValue = -1;
            _handleDrag(
              DragUpdateDetails(
                globalPosition: details.globalPosition,
                localPosition: details.localPosition,
              ),
              constraints,
            );
          },
          onPanUpdate: (details) => _handleDrag(details, constraints),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFE9F4FF).withValues(alpha: 0.72),
                  Colors.white.withValues(alpha: 0.96),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(34),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF101522).withValues(alpha: 0.14),
                  blurRadius: 36,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(34),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: _bottomInset),
                child: AnimatedBuilder(
                  animation: _liquidController,
                  builder: (context, _) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: widget.value),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedValue, _) {
                        return CustomPaint(
                          painter: _DialPainter(
                            minValue: widget.minValue,
                            maxValue: widget.maxValue,
                            value: animatedValue,
                            unitLabel: widget.unitLabel,
                            liquidPhase: _liquidController.value,
                          ),
                          size: Size(width, height - _bottomInset),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  static const double _readoutTopOffset = 24;
  final double minValue;
  final double maxValue;
  final double value;
  final String unitLabel;
  final double liquidPhase;

  _DialPainter({
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.unitLabel,
    required this.liquidPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height * WeightDial.gaugeCenterYFactor);
    final radius =
        math.min(width / 2, height * WeightDial.gaugeCenterYFactor) - 18;
    final t = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final progressColor = Color.lerp(
      const Color(0xFF22C55E),
      const Color(0xFF3B82F6),
      t,
    )!;

    final trackRadius = radius - 26;
    final trackRect = Rect.fromCircle(center: center, radius: trackRadius);
    canvas.drawArc(
      trackRect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFAAB6C8).withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: trackRadius + 13),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFA2B3C8).withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );

    final progressRect = Rect.fromCircle(center: center, radius: trackRadius);
    if (t > 0) {
      canvas.drawArc(
        progressRect,
        math.pi,
        math.pi * t,
        false,
        Paint()
          ..color = progressColor.withValues(alpha: 0.34)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    if (t > 0) {
      canvas.drawArc(
        progressRect,
        math.pi,
        math.pi * t,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: math.pi,
            endAngle: 2 * math.pi,
            colors: const [
              Color(0xFF22C55E),
              Color(0xFF14B8A6),
              Color(0xFF3B82F6),
            ],
            stops: const [0.0, 0.52, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      );
    }

    final majorTickPaint = Paint()
      ..color = const Color(0xFF6A7687).withValues(alpha: 0.55)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final minorTickPaint = Paint()
      ..color = const Color(0xFFC5CEDA).withValues(alpha: 0.42)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const minorStep = 2.0;
    const majorStep = 10.0;
    final tickOuter = trackRadius + 8;
    final tickInner = trackRadius - 4;

    for (double v = minValue; v <= maxValue + 0.001; v += minorStep) {
      final vt = ((v - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
      final angle = math.pi + vt * math.pi;
      final isMajor =
          (v - minValue) % majorStep < 0.001 ||
          (majorStep - (v - minValue) % majorStep) < 0.001;
      final r1 = isMajor ? tickOuter : trackRadius - 6;
      final r2 = isMajor ? tickInner : trackRadius + 2;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * r1,
        center + Offset(math.cos(angle), math.sin(angle)) * r2,
        isMajor ? majorTickPaint : minorTickPaint,
      );

      if (isMajor) {
        final lp =
            center +
            Offset(math.cos(angle), math.sin(angle)) * (trackRadius - 20);
        final tp = TextPainter(
          text: TextSpan(
            text: v.round().toString(),
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5C6675).withValues(alpha: 0.68),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, lp - Offset(tp.width / 2, tp.height / 2));
      }
    }

    final needleAngle = math.pi + t * math.pi;
    final axis = Offset(math.cos(needleAngle), math.sin(needleAngle));
    final perpendicular = Offset(-axis.dy, axis.dx);
    final shaftStart = center + axis * 8;
    final shaftEnd = center + axis * (trackRadius - 18);
    final arrowTip = center + axis * (trackRadius - 2);
    final headBaseCenter = center + axis * (trackRadius - 18);
    final arrowHead = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(
        headBaseCenter.dx + perpendicular.dx * 8,
        headBaseCenter.dy + perpendicular.dy * 8,
      )
      ..lineTo(
        headBaseCenter.dx - perpendicular.dx * 8,
        headBaseCenter.dy - perpendicular.dy * 8,
      )
      ..close();

    final arrowColor = const Color(0xFFE53935);

    canvas.drawLine(
      shaftStart,
      shaftEnd,
      Paint()
        ..color = arrowColor
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      arrowHead,
      Paint()
        ..color = arrowColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      arrowHead,
      Paint()
        ..color = const Color(0xFFFFB4B0).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final liquidWave = (math.sin(liquidPhase * math.pi * 2) * 0.5 + 0.5);
    final liquidWave2 = (math.sin(liquidPhase * math.pi * 2 + 1.8) * 0.5 + 0.5);
    final liquidCoreColor = Color.lerp(
      progressColor,
      const Color(0xFF00C2FF),
      0.22 + (0.20 * liquidWave),
    )!;

    canvas.drawCircle(
      center + Offset(0, (liquidWave - 0.5) * 1.6),
      17.8 + liquidWave2 * 1.8,
      Paint()
        ..color = liquidCoreColor.withValues(alpha: 0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..color = liquidCoreColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      center + Offset((liquidWave - 0.5) * 1.2, 0),
      13.5,
      Paint()..color = liquidCoreColor,
    );
    canvas.drawCircle(
      center + Offset((liquidWave2 - 0.5) * -1.4, (liquidWave - 0.5) * 1.0),
      10.8,
      Paint()..color = progressColor.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      center + Offset((liquidWave - 0.5) * 1.5, (liquidWave2 - 0.5) * 1.3),
      4.2,
      Paint()..color = Colors.white,
    );

    if (t > 0.02) {
      final orbitAngle = math.pi + t * math.pi;
      final orbit =
          center +
          Offset(math.cos(orbitAngle), math.sin(orbitAngle)) * trackRadius;
      canvas.drawCircle(
        orbit,
        10,
        Paint()
          ..color = progressColor.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(orbit, 5, Paint()..color = Colors.white);
      canvas.drawCircle(orbit, 3, Paint()..color = progressColor);
    }

    final valueText = TextPainter(
      text: TextSpan(
        text: value.round().toString(),
        style: GoogleFonts.poppins(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF111827),
          letterSpacing: -1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final unitText = TextPainter(
      text: TextSpan(
        text: unitLabel,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF667085),
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final readoutY = center.dy + _readoutTopOffset;
    valueText.paint(canvas, Offset(center.dx - valueText.width / 2, readoutY));
    unitText.paint(
      canvas,
      Offset(center.dx - unitText.width / 2, readoutY + valueText.height + 2),
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.unitLabel != unitLabel ||
        oldDelegate.liquidPhase != liquidPhase;
  }
}
