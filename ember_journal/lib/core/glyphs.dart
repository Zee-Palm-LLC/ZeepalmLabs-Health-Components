import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum Glyph {
  arrowLeft,
  arrowRight,
  repeat,
  die,
  dots,
  calendar,
  search,
  home,
  book,
  sparkles,
  person,
  plus,
  chevron,
}

const _filled = {Glyph.die, Glyph.book, Glyph.sparkles};

Path _rounded(Rect rect, double radius) =>
    Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

Path glyphPath(Glyph glyph) {
  final p = Path();
  switch (glyph) {
    case Glyph.arrowLeft:
      p
        ..moveTo(20, 12)
        ..lineTo(4.6, 12)
        ..moveTo(11, 5.2)
        ..lineTo(4.2, 12)
        ..lineTo(11, 18.8);
    case Glyph.arrowRight:
      p
        ..moveTo(4, 12)
        ..lineTo(19.4, 12)
        ..moveTo(13, 5.2)
        ..lineTo(19.8, 12)
        ..lineTo(13, 18.8);
    case Glyph.repeat:
      p
        ..moveTo(3.4, 8.6)
        ..lineTo(17.6, 8.6)
        ..moveTo(14.2, 5.2)
        ..lineTo(17.8, 8.6)
        ..lineTo(14.2, 12.0)
        ..moveTo(20.6, 15.4)
        ..lineTo(6.4, 15.4)
        ..moveTo(9.8, 12.0)
        ..lineTo(6.2, 15.4)
        ..lineTo(9.8, 18.8);
    case Glyph.die:
      p
        ..addPath(_rounded(const Rect.fromLTWH(2.6, 2.6, 18.8, 18.8), 6.2), Offset.zero)
        ..addOval(Rect.fromCircle(center: const Offset(8.4, 8.4), radius: 1.9))
        ..addOval(Rect.fromCircle(center: const Offset(15.6, 15.6), radius: 1.9))
        ..addOval(Rect.fromCircle(center: const Offset(15.6, 8.4), radius: 1.5))
        ..fillType = PathFillType.evenOdd;
    case Glyph.dots:
      for (final dy in [4.6, 12.0, 19.4]) {
        p.addOval(Rect.fromCircle(center: Offset(12, dy), radius: 1.5));
      }
    case Glyph.calendar:
      p
        ..addPath(_rounded(const Rect.fromLTWH(3.2, 5.0, 17.6, 16.0), 4.4), Offset.zero)
        ..moveTo(3.4, 10.4)
        ..lineTo(20.6, 10.4)
        ..moveTo(8.2, 3.0)
        ..lineTo(8.2, 6.8)
        ..moveTo(15.8, 3.0)
        ..lineTo(15.8, 6.8);
    case Glyph.search:
      p
        ..addOval(Rect.fromCircle(center: const Offset(11, 11), radius: 6.6))
        ..moveTo(15.9, 15.9)
        ..lineTo(20.6, 20.6);
    case Glyph.home:
      p
        ..moveTo(3.4, 10.6)
        ..lineTo(10.6, 3.6)
        ..cubicTo(11.4, 2.9, 12.6, 2.9, 13.4, 3.6)
        ..lineTo(20.6, 10.6)
        ..lineTo(20.6, 17.6)
        ..cubicTo(20.6, 19.7, 19.3, 21.0, 17.2, 21.0)
        ..lineTo(6.8, 21.0)
        ..cubicTo(4.7, 21.0, 3.4, 19.7, 3.4, 17.6)
        ..close()
        ..moveTo(9.2, 21.0)
        ..lineTo(9.2, 16.2)
        ..cubicTo(9.2, 14.7, 10.3, 13.7, 12.0, 13.7)
        ..cubicTo(13.7, 13.7, 14.8, 14.7, 14.8, 16.2)
        ..lineTo(14.8, 21.0);
    case Glyph.book:
      p
        ..addPath(_rounded(const Rect.fromLTWH(3.0, 4.4, 8.2, 15.2), 1.8), Offset.zero)
        ..addPath(_rounded(const Rect.fromLTWH(12.8, 4.4, 8.2, 15.2), 1.8), Offset.zero);
    case Glyph.sparkles:
      p
        ..moveTo(13.2, 2.6)
        ..cubicTo(13.9, 6.6, 16.0, 8.7, 20.0, 9.4)
        ..cubicTo(16.0, 10.1, 13.9, 12.2, 13.2, 16.2)
        ..cubicTo(12.5, 12.2, 10.4, 10.1, 6.4, 9.4)
        ..cubicTo(10.4, 8.7, 12.5, 6.6, 13.2, 2.6)
        ..close()
        ..moveTo(5.9, 15.0)
        ..cubicTo(6.3, 17.1, 6.9, 17.7, 9.0, 18.1)
        ..cubicTo(6.9, 18.5, 6.3, 19.1, 5.9, 21.2)
        ..cubicTo(5.5, 19.1, 4.9, 18.5, 2.8, 18.1)
        ..cubicTo(4.9, 17.7, 5.5, 17.1, 5.9, 15.0)
        ..close()
        ..addOval(Rect.fromCircle(center: const Offset(19.2, 16.6), radius: 1.35));
    case Glyph.person:
      p
        ..addOval(Rect.fromCircle(center: const Offset(12, 7.4), radius: 4.0))
        ..addPath(_rounded(const Rect.fromLTWH(5.2, 14.0, 13.6, 7.6), 3.8), Offset.zero);
    case Glyph.plus:
      p
        ..moveTo(12, 4.4)
        ..lineTo(12, 19.6)
        ..moveTo(4.4, 12)
        ..lineTo(19.6, 12);
    case Glyph.chevron:
      p
        ..moveTo(9, 5)
        ..lineTo(16, 12)
        ..lineTo(9, 19);
  }
  return p;
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.stroke = 1.7,
    this.progress = 1.0,
    this.shadow,
  });

  final Glyph glyph;
  final double size;
  final Color color;
  final double stroke;
  final double progress;
  final Color? shadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GlyphPainter(glyph, color, stroke, progress, shadow)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color, this.stroke, this.progress, this.shadow);

  final Glyph glyph;
  final Color color;
  final double stroke;
  final double progress;
  final Color? shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.save();
    canvas.scale(k);
    var path = glyphPath(glyph);
    if (progress < 1) {
      final grown = Path();
      for (final metric in path.computeMetrics()) {
        grown.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
      }
      path = grown;
    }
    final paint = Paint()
      ..color = color
      ..style = _filled.contains(glyph) ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke / k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (shadow != null) {
      canvas.drawPath(
        path.shift(Offset(0, 1.6 / k)),
        Paint()
          ..color = shadow!
          ..style = paint.style
          ..strokeWidth = paint.strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, 2.4 / k),
      );
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.stroke != stroke || old.progress != progress;
}

Path starPath(Offset centre, double outer, double inner, int points, double phase) {
  final path = Path();
  for (var i = 0; i < points * 2; i++) {
    final r = i.isEven ? outer : inner;
    final a = phase + i * math.pi / points;
    final at = centre + Offset(math.cos(a), math.sin(a)) * r;
    i == 0 ? path.moveTo(at.dx, at.dy) : path.lineTo(at.dx, at.dy);
  }
  return path..close();
}
