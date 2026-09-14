import 'package:flutter/widgets.dart';

import '../../../core/palette.dart';

/// A flame, drawn rather than pulled from an icon font so it keeps the same
/// silhouette everywhere it appears — the streak pill, the podium, a row.
class FlameMark extends StatelessWidget {
  const FlameMark({super.key, required this.size, this.color = Accent.flame});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size * 1.22),
        painter: FlamePainter(color: color),
      );
}

class FlamePainter extends CustomPainter {
  const FlamePainter({this.color = Accent.flame});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.52, 0)
        ..cubicTo(w * 0.86, h * 0.28, w * 0.98, h * 0.48, w * 0.90, h * 0.66)
        ..cubicTo(w * 0.80, h * 0.95, w * 0.18, h * 0.98, w * 0.10, h * 0.66)
        ..cubicTo(w * 0.04, h * 0.46, w * 0.24, h * 0.38, w * 0.33, h * 0.52)
        ..cubicTo(w * 0.33, h * 0.26, w * 0.42, h * 0.12, w * 0.52, 0)
        ..close(),
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(FlamePainter old) => old.color != color;
}
