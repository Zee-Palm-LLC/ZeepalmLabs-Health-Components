import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum Glyph { bell, menu, clip, chevron, mic, pause, play, send, close, sparkle, arrowUp, check }

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(this.glyph, {super.key, this.size = 20, this.color = const Color(0xFFFFFFFF), this.stroke = 1.6});

  final Glyph glyph;
  final double size;
  final Color color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: GlyphPainter(glyph, color, stroke)),
    );
  }
}

class GlyphPainter extends CustomPainter {
  const GlyphPainter(this.glyph, this.color, this.stroke);

  final Glyph glyph;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.save();
    canvas.scale(k);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke / k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    switch (glyph) {
      case Glyph.bell:
        final body = Path()
          ..moveTo(6.2, 16.6)
          ..lineTo(6.2, 10.8)
          ..cubicTo(6.2, 7.4, 8.8, 4.8, 12, 4.8)
          ..cubicTo(15.2, 4.8, 17.8, 7.4, 17.8, 10.8)
          ..lineTo(17.8, 16.6)
          ..lineTo(19.3, 18.2)
          ..lineTo(4.7, 18.2)
          ..close();
        canvas.drawPath(body, line);
        canvas.drawPath(
          Path()
            ..moveTo(10.2, 20.6)
            ..quadraticBezierTo(12, 22.2, 13.8, 20.6),
          line,
        );
        canvas.drawLine(const Offset(12, 3), const Offset(12, 4.8), line);
      case Glyph.menu:
        for (final y in [7.0, 12.0, 17.0]) {
          canvas.drawRect(Rect.fromCenter(center: Offset(5.2, y), width: 2.2, height: 2.2), fill);
          canvas.drawLine(Offset(9, y), Offset(19.5, y), line..strokeCap = StrokeCap.butt);
        }
      case Glyph.clip:
        final path = Path()
          ..moveTo(21.44, 11.05)
          ..relativeLineTo(-9.19, 9.19)
          ..relativeArcToPoint(const Offset(-8.49, -8.49), radius: const Radius.circular(6))
          ..relativeLineTo(8.57, -8.57)
          ..arcToPoint(const Offset(18, 8.84), radius: const Radius.circular(4), largeArc: true)
          ..relativeLineTo(-8.59, 8.57)
          ..relativeArcToPoint(const Offset(-2.83, -2.83), radius: const Radius.circular(2))
          ..relativeLineTo(8.49, -8.48);
        canvas.drawPath(path, line);
      case Glyph.chevron:
        canvas.drawPath(
          Path()
            ..moveTo(7, 9.5)
            ..lineTo(12, 14.5)
            ..lineTo(17, 9.5),
          line,
        );
      case Glyph.mic:
        canvas.drawRRect(RRect.fromLTRBR(8.6, 2.6, 15.4, 14.2, const Radius.circular(3.4)), fill);
        canvas.drawArc(Rect.fromCircle(center: const Offset(12, 10.6), radius: 6.6), 0, math.pi, false, line);
        canvas.drawLine(const Offset(12, 17.2), const Offset(12, 21), line);
      case Glyph.pause:
        canvas.drawCircle(const Offset(12, 12), 9.5, line);
        canvas.drawLine(const Offset(10.2, 9.4), const Offset(10.2, 14.6), line);
        canvas.drawLine(const Offset(13.8, 9.4), const Offset(13.8, 14.6), line);
      case Glyph.play:
        canvas.drawCircle(const Offset(12, 12), 9.5, line);
        canvas.drawPath(
          Path()
            ..moveTo(10.2, 8.9)
            ..lineTo(15.4, 12)
            ..lineTo(10.2, 15.1)
            ..close(),
          line,
        );
      case Glyph.send:
        canvas.drawPath(
          Path()
            ..moveTo(21.5, 2.5)
            ..lineTo(14.8, 21.2)
            ..lineTo(11, 13)
            ..lineTo(2.8, 9.2)
            ..close(),
          line,
        );
        canvas.drawLine(const Offset(21.5, 2.5), const Offset(11, 13), line);
      case Glyph.close:
        canvas.drawLine(const Offset(6.5, 6.5), const Offset(17.5, 17.5), line);
        canvas.drawLine(const Offset(17.5, 6.5), const Offset(6.5, 17.5), line);
      case Glyph.sparkle:
        canvas.drawPath(sparklePath(const Offset(9.6, 13.4), 8.2), fill);
        canvas.drawPath(sparklePath(const Offset(18.2, 5.6), 3.4), fill);
      case Glyph.arrowUp:
        canvas.drawLine(const Offset(12, 19), const Offset(12, 5.5), line);
        canvas.drawPath(
          Path()
            ..moveTo(6.5, 11)
            ..lineTo(12, 5.5)
            ..lineTo(17.5, 11),
          line,
        );
      case Glyph.check:
        canvas.drawPath(
          Path()
            ..moveTo(5.5, 12.5)
            ..lineTo(10, 17)
            ..lineTo(18.5, 7.5),
          line,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(GlyphPainter oldDelegate) {
    return oldDelegate.glyph != glyph || oldDelegate.color != color || oldDelegate.stroke != stroke;
  }
}

Path sparklePath(Offset c, double r) {
  final w = r * 0.2;
  return Path()
    ..moveTo(c.dx, c.dy - r)
    ..quadraticBezierTo(c.dx + w, c.dy - w, c.dx + r, c.dy)
    ..quadraticBezierTo(c.dx + w, c.dy + w, c.dx, c.dy + r)
    ..quadraticBezierTo(c.dx - w, c.dy + w, c.dx - r, c.dy)
    ..quadraticBezierTo(c.dx - w, c.dy - w, c.dx, c.dy - r)
    ..close();
}

class AiraLogo extends StatelessWidget {
  const AiraLogo({super.key, this.size = 40, this.draw = 1});

  final double size;
  final double draw;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LogoPainter(draw)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter(this.draw);

  final double draw;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 40;
    canvas.scale(k);
    const c = Offset(20, 20);
    canvas.drawCircle(c, 20, Paint()..color = const Color(0xFF050505));
    final line = Paint()
      ..color = const Color(0xFFEDEDED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const r = 15.6;

    final tip = c.dy + r * math.sin(_rad(328));
    final outer = Path()
      ..addArc(Rect.fromCircle(center: c, radius: r), _rad(118), _rad(210))
      ..lineTo(19.6, tip)
      ..quadraticBezierTo(14.2, tip, 14.2, tip + 5.4)
      ..lineTo(14.2, 33.6);
    final inner = Path()
      ..moveTo(18.2, 34.4)
      ..lineTo(18.2, 18.6)
      ..quadraticBezierTo(18.2, 15.8, 21, 15.8)
      ..lineTo(35.3, 15.8);
    final innerArc = Path()..addArc(Rect.fromCircle(center: c, radius: r), _rad(-15.5), _rad(108));

    for (final path in [outer, inner, innerArc]) {
      if (draw >= 1) {
        canvas.drawPath(path, line);
      } else {
        for (final metric in path.computeMetrics()) {
          canvas.drawPath(metric.extractPath(0, metric.length * draw), line);
        }
      }
    }
  }

  double _rad(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => oldDelegate.draw != draw;
}
