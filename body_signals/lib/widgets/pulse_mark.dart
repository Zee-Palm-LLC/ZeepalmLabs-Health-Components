import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class PulseMark extends StatelessWidget {
  const PulseMark({super.key, this.width = 26, this.color});

  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.60),
      painter: _PulsePainter(color: color ?? AppColors.cyan),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.55)
      ..lineTo(w * 0.20, h * 0.55)
      ..lineTo(w * 0.31, h * 0.12)
      ..lineTo(w * 0.45, h * 0.94)
      ..lineTo(w * 0.58, h * 0.30)
      ..lineTo(w * 0.70, h * 0.55)
      ..lineTo(w, h * 0.55);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) => old.color != color;
}
