import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive semicircular dial. Drag anywhere on the arc to scrub the
/// weight value; the needle and highlighted tick follow the finger.
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
  Offset? _center;

  void _handleDrag(Offset globalPosition, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalPosition);
    _center ??= Offset(box.size.width / 2, 0);
    final dx = local.dx - _center!.dx;
    final dy = local.dy - _center!.dy;
    // angle measured from positive x-axis, range -180..0 across the top arc
    double angle = math.atan2(dy, dx) * 180 / math.pi;
    // Clamp to top semicircle (-180 to 0)
    if (angle > 0) angle = dy.abs() < 1 ? angle : (dx < 0 ? -180 : 0);
    angle = angle.clamp(-180.0, 0.0);
    final t = (angle + 180) / 180; // 0..1
    final newValue = widget.minValue + t * (widget.maxValue - widget.minValue);
    HapticFeedback.selectionClick();
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 0.62;
        return GestureDetector(
          onPanStart: (details) => _handleDrag(details.globalPosition, context),
          onPanUpdate: (details) => _handleDrag(details.globalPosition, context),
          child: SizedBox(
            width: width,
            height: height,
            child: CustomPaint(
              painter: _DialPainter(
                minValue: widget.minValue,
                maxValue: widget.maxValue,
                value: widget.value,
              ),
              size: Size(width, height),
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

  _DialPainter({
    required this.minValue,
    required this.maxValue,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 0);
    final outerRadius = size.width / 2;

    // Dial background (white semicircle disc)
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, outerRadius, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFE7ECE9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, outerRadius, borderPaint);

    // Ticks
    final majorTickPaint = Paint()
      ..color = const Color(0xFFB7C0BA)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final minorTickPaint = Paint()
      ..color = const Color(0xFFD9DFDB)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    const minorStep = 2.0;
    final majorStep = 10.0;

    for (double v = minValue; v <= maxValue + 0.001; v += minorStep) {
      final t = (v - minValue) / (maxValue - minValue);
      final angleDeg = -180 + t * 180; // -180 (left) .. 0 (right), apex at -90 (top)
      final angleRad = angleDeg * math.pi / 180;
      final isMajor = (v - minValue) % majorStep < 0.001 ||
          (majorStep - (v - minValue) % majorStep) < 0.001;

      final innerRadius = isMajor ? outerRadius - 27 : outerRadius - 17;
      final p1 =
          center + Offset(math.cos(angleRad), math.sin(angleRad)) * outerRadius;
      final p2 =
          center + Offset(math.cos(angleRad), math.sin(angleRad)) * innerRadius;
      canvas.drawLine(p1, p2, isMajor ? majorTickPaint : minorTickPaint);

      if (isMajor) {
        final labelRadius = outerRadius - 49;
        final lp = center +
            Offset(math.cos(angleRad), math.sin(angleRad)) * labelRadius;
        final tp = TextPainter(
          text: TextSpan(
            text: v.round().toString(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A938D),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, lp - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Needle
    final t = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final needleAngleDeg = -180 + t * 180;
    final needleAngleRad = needleAngleDeg * math.pi / 180;
    final needleEnd = center +
        Offset(math.cos(needleAngleRad), math.sin(needleAngleRad)) *
            (outerRadius - 92);
    final needlePaint = Paint()
      ..color = const Color(0xFF2FBF6D)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue;
  }
}
