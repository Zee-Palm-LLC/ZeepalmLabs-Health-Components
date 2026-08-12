import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive semicircular gauge inside a glass panel. Drag anywhere to scrub
/// the value; the needle, glowing progress arc and center readout follow
/// smoothly with haptics.
class WeightDial extends StatefulWidget {
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

class _WeightDialState extends State<WeightDial> {
  int _lastHapticValue = -1;

  double get _gaugeCenterY => 0.62;

  void _handleDrag(DragUpdateDetails details, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = width * 0.70;
    final center = Offset(width / 2, height * _gaugeCenterY);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;

    // Angle in screen coords (y down): 180 = left, 270 = top, 360 = right.
    double angleDeg = math.atan2(dy, dx) * 180 / math.pi;
    if (angleDeg < 0) angleDeg += 360;

    // Clamp to the dome arc [180, 360].
    if (angleDeg < 180) {
      angleDeg = angleDeg <= 270 ? 180 : 360;
    }

    final t = ((angleDeg - 180) / 180).clamp(0.0, 1.0);
    final raw = widget.minValue + t * (widget.maxValue - widget.minValue);
    // Snap to 0.5 increments for a satisfying, stable feel.
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
        final height = width * 0.70;
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
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0.92),
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
                  color: const Color(0xFF1C1F1E).withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(34),
              ),
              child: TweenAnimationBuilder<double>(
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
                    ),
                    size: Size(width, height),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  final double minValue;
  final double maxValue;
  final double value;
  final String unitLabel;

  _DialPainter({
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.unitLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height * 0.62);
    final radius = math.min(width / 2, height * 0.62) - 18;
    final t = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);

    // ---- Dome disc (soft white radial) ----
    final discPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.white,
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      true,
      discPaint,
    );

    // ---- Track arc (inactive, light grey) ----
    final trackRadius = radius - 26;
    final trackRect = Rect.fromCircle(center: center, radius: trackRadius);
    canvas.drawArc(
      trackRect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFEDF1EE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );

    // ---- Progress arc glow ----
    final progressRect = Rect.fromCircle(center: center, radius: trackRadius);
    if (t > 0) {
      canvas.drawArc(
        progressRect,
        math.pi,
        math.pi * t,
        false,
        Paint()
          ..color = const Color(0xFF25B95C).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
    }

    // ---- Progress arc (active, green gradient) ----
    if (t > 0) {
      canvas.drawArc(
        progressRect,
        math.pi,
        math.pi * t,
        false,
        Paint()
          ..shader = const SweepGradient(
            startAngle: math.pi,
            endAngle: 2 * math.pi,
            colors: [Color(0xFF2FBF6D), Color(0xFF8EF0BC)],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round,
      );
    }

    // ---- Ticks ----
    final majorTickPaint = Paint()
      ..color = const Color(0xFF9AA39C)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final minorTickPaint = Paint()
      ..color = const Color(0xFFD5DBD7)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const minorStep = 2.0;
    const majorStep = 10.0;
    final tickOuter = trackRadius + 8;
    final tickInner = trackRadius - 4;

    for (double v = minValue; v <= maxValue + 0.001; v += minorStep) {
      final vt = ((v - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
      final angle = math.pi + vt * math.pi; // 180..360
      final isMajor = (v - minValue) % majorStep < 0.001 ||
          (majorStep - (v - minValue) % majorStep) < 0.001;
      final r1 = isMajor ? tickOuter : trackRadius - 6;
      final r2 = isMajor ? tickInner : trackRadius + 2;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * r1,
        center + Offset(math.cos(angle), math.sin(angle)) * r2,
        isMajor ? majorTickPaint : minorTickPaint,
      );

      if (isMajor) {
        final lp = center +
            Offset(math.cos(angle), math.sin(angle)) * (trackRadius - 20);
        final tp = TextPainter(
          text: TextSpan(
            text: v.round().toString(),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6E7770),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, lp - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // ---- Needle (tapered) ----
    final needleAngle = math.pi + t * math.pi;
    final needleLength = trackRadius - 6;
    final needleTip = center +
        Offset(math.cos(needleAngle), math.sin(needleAngle)) * needleLength;
    final perpendicular = Offset(
      -math.sin(needleAngle),
      math.cos(needleAngle),
    );
    final base = center + perpendicular * 5.5;

    final needlePath = Path()
      ..moveTo(
        needleTip.dx + perpendicular.dx * 0,
        needleTip.dy + perpendicular.dy * 0,
      )
      ..lineTo(base.dx + perpendicular.dx * 5.5, base.dy + perpendicular.dy * 5.5)
      ..lineTo(base.dx - perpendicular.dx * 5.5, base.dy - perpendicular.dy * 5.5)
      ..close();
    canvas.drawPath(
      needlePath,
      Paint()
        ..color = const Color(0xFF1C1F1E)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      needlePath,
      Paint()
        ..color = const Color(0xFF2FBF6D).withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ---- Center hub ----
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..color = const Color(0xFF2FBF6D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(center, 13, Paint()..color = const Color(0xFF2FBF6D));
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);

    // ---- Center readout ----
    final valueText = TextPainter(
      text: TextSpan(
        text: value.round().toString(),
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1C1F1E),
          letterSpacing: -1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final unitText = TextPainter(
      text: TextSpan(
        text: unitLabel,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8A938D),
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final readoutY = center.dy + 40;
    valueText.paint(
      canvas,
      Offset(center.dx - valueText.width / 2, readoutY),
    );
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
        oldDelegate.unitLabel != unitLabel;
  }
}
