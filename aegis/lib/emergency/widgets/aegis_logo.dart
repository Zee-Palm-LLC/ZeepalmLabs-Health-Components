import 'package:flutter/material.dart';

import '../../theme/aegis_theme.dart';

class AegisLogo extends StatelessWidget {
  const AegisLogo({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: height * 0.75,
        height: height,
        child: const CustomPaint(painter: _AegisMarkPainter()),
      ),
    );
  }
}

class _AegisMarkPainter extends CustomPainter {
  const _AegisMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = (Offset.zero & size).deflate(1);
    Offset at(double x, double y) =>
        Offset(bounds.left + x * bounds.width, bounds.top + y * bounds.height);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AegisColors.amberBright, AegisColors.amber],
      ).createShader(bounds);

    final outline = Path()
      ..addPolygon([
        at(0.5, 0),
        at(1, 0.26),
        at(1, 0.74),
        at(0.5, 1),
        at(0, 0.74),
        at(0, 0.26),
      ], true);
    final facet = Path()
      ..addPolygon([
        at(0.18, 0.52),
        at(0.5, 0.27),
        at(0.82, 0.52),
        at(0.5, 0.77),
      ], true);

    canvas
      ..drawPath(outline, stroke)
      ..drawPath(facet, stroke)
      ..drawLine(at(0.5, 0), at(0.5, 1), stroke);
  }

  @override
  bool shouldRepaint(_AegisMarkPainter oldDelegate) => false;
}
