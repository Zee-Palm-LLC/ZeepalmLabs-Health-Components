import 'dart:math' as math;

import 'package:flutter/material.dart';

enum Glyph { home, map, progress, cart, profile, arrow, play, back, heart, share, plus, star, crown, check, bolt, lock }

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.stroke = 2.0,
    this.progress = 1.0,
  });

  final Glyph glyph;
  final double size;
  final Color color;
  final double stroke;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: GlyphPainter(glyph, color: color, stroke: stroke, progress: progress),
    );
  }
}

class GlyphPainter extends CustomPainter {
  GlyphPainter(this.glyph, {required this.color, this.stroke = 2.0, this.progress = 1.0});

  final Glyph glyph;
  final Color color;
  final double stroke;
  final double progress;

  static bool filled(Glyph g) => const {Glyph.home, Glyph.play, Glyph.star, Glyph.crown, Glyph.bolt}.contains(g);

  static Path pathOf(Glyph g) {
    final p = Path();
    switch (g) {
      case Glyph.home:
        p
          ..moveTo(12, 2.6)
          ..lineTo(22.4, 11.4)
          ..quadraticBezierTo(23.2, 12.2, 22.4, 12.9)
          ..lineTo(20.2, 12.9)
          ..lineTo(20.2, 21.2)
          ..quadraticBezierTo(20.2, 22, 19.4, 22)
          ..lineTo(14.6, 22)
          ..lineTo(14.6, 16.2)
          ..lineTo(9.4, 16.2)
          ..lineTo(9.4, 22)
          ..lineTo(4.6, 22)
          ..quadraticBezierTo(3.8, 22, 3.8, 21.2)
          ..lineTo(3.8, 12.9)
          ..lineTo(1.6, 12.9)
          ..quadraticBezierTo(0.8, 12.2, 1.6, 11.4)
          ..close();
      case Glyph.map:
        p
          ..moveTo(2.5, 5.2)
          ..lineTo(8.6, 3)
          ..lineTo(15.4, 5.4)
          ..lineTo(21.5, 3.2)
          ..lineTo(21.5, 18.8)
          ..lineTo(15.4, 21)
          ..lineTo(8.6, 18.6)
          ..lineTo(2.5, 20.8)
          ..close()
          ..moveTo(8.6, 3)
          ..lineTo(8.6, 18.6)
          ..moveTo(15.4, 5.4)
          ..lineTo(15.4, 21);
      case Glyph.progress:
        p
          ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(2.6, 14, 4, 7.6), const Radius.circular(1)))
          ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 10.2, 4, 11.4), const Radius.circular(1)))
          ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(17.4, 6.4, 4, 15.2), const Radius.circular(1)))
          ..moveTo(2.8, 10.4)
          ..lineTo(8.4, 5.6)
          ..lineTo(12.6, 7.8)
          ..lineTo(19.6, 2.4)
          ..moveTo(16.4, 2.4)
          ..lineTo(19.6, 2.4)
          ..lineTo(19.6, 5.4);
      case Glyph.cart:
        p
          ..moveTo(1.2, 2.8)
          ..lineTo(4.2, 2.8)
          ..lineTo(6.8, 15.2)
          ..lineTo(19.2, 15.2)
          ..lineTo(21.8, 6.4)
          ..lineTo(5.2, 6.4)
          ..moveTo(9.2, 10.8)
          ..lineTo(19, 10.8)
          ..addOval(Rect.fromCircle(center: const Offset(8.4, 19.6), radius: 1.7))
          ..addOval(Rect.fromCircle(center: const Offset(17.6, 19.6), radius: 1.7));
      case Glyph.profile:
        p
          ..addOval(Rect.fromCircle(center: const Offset(12, 7.4), radius: 4.6))
          ..moveTo(3.2, 21.6)
          ..lineTo(3.2, 19.6)
          ..quadraticBezierTo(3.2, 14.6, 8.4, 14.6)
          ..lineTo(15.6, 14.6)
          ..quadraticBezierTo(20.8, 14.6, 20.8, 19.6)
          ..lineTo(20.8, 21.6)
          ..close();
      case Glyph.arrow:
        p
          ..moveTo(3, 12)
          ..lineTo(21, 12)
          ..moveTo(13.4, 4.4)
          ..lineTo(21, 12)
          ..lineTo(13.4, 19.6);
      case Glyph.play:
        p
          ..moveTo(6, 3.4)
          ..quadraticBezierTo(6, 2, 7.3, 2.8)
          ..lineTo(20.6, 11)
          ..quadraticBezierTo(21.8, 12, 20.6, 13)
          ..lineTo(7.3, 21.2)
          ..quadraticBezierTo(6, 22, 6, 20.6)
          ..close();
      case Glyph.back:
        p
          ..moveTo(15.6, 3.6)
          ..lineTo(7.2, 12)
          ..lineTo(15.6, 20.4);
      case Glyph.heart:
        p
          ..moveTo(12, 20.4)
          ..cubicTo(4.4, 15.4, 2, 11.6, 2, 8.2)
          ..cubicTo(2, 5.2, 4.4, 3, 7.2, 3)
          ..cubicTo(9.2, 3, 10.9, 4.1, 12, 5.8)
          ..cubicTo(13.1, 4.1, 14.8, 3, 16.8, 3)
          ..cubicTo(19.6, 3, 22, 5.2, 22, 8.2)
          ..cubicTo(22, 11.6, 19.6, 15.4, 12, 20.4)
          ..close();
      case Glyph.share:
        p
          ..moveTo(12, 14.6)
          ..lineTo(12, 2.6)
          ..moveTo(7.4, 7)
          ..lineTo(12, 2.4)
          ..lineTo(16.6, 7)
          ..moveTo(8.6, 10)
          ..lineTo(5.6, 10)
          ..lineTo(5.6, 21.4)
          ..lineTo(18.4, 21.4)
          ..lineTo(18.4, 10)
          ..lineTo(15.4, 10);
      case Glyph.plus:
        p
          ..moveTo(12, 4)
          ..lineTo(12, 20)
          ..moveTo(4, 12)
          ..lineTo(20, 12);
      case Glyph.star:
        const c = Offset(12, 12.8);
        for (var i = 0; i < 10; i++) {
          final r = i.isEven ? 11.2 : 5.0;
          final a = -math.pi / 2 + i * math.pi / 5;
          final pt = c + Offset(math.cos(a) * r, math.sin(a) * r);
          i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        p.close();
      case Glyph.crown:
        p
          ..moveTo(2.6, 7.6)
          ..lineTo(7.4, 12)
          ..lineTo(12, 4.6)
          ..lineTo(16.6, 12)
          ..lineTo(21.4, 7.6)
          ..lineTo(19.4, 17.6)
          ..lineTo(4.6, 17.6)
          ..close()
          ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4.6, 18.8, 14.8, 2.4), const Radius.circular(1)));
      case Glyph.check:
        p
          ..moveTo(4.4, 12.6)
          ..lineTo(9.6, 17.6)
          ..lineTo(19.6, 6.6);
      case Glyph.bolt:
        p
          ..moveTo(13.6, 1.8)
          ..lineTo(4.4, 13.6)
          ..lineTo(11.2, 13.6)
          ..lineTo(10.2, 22.2)
          ..lineTo(19.6, 10.2)
          ..lineTo(12.8, 10.2)
          ..close();
      case Glyph.lock:
        p
          ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4.4, 10.4, 15.2, 11.2), const Radius.circular(2.4)))
          ..moveTo(8, 10.4)
          ..lineTo(8, 7.4)
          ..arcToPoint(const Offset(16, 7.4), radius: const Radius.circular(4))
          ..lineTo(16, 10.4);
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    var path = pathOf(glyph);
    if (progress < 1) {
      final cut = Path();
      for (final metric in path.computeMetrics()) {
        cut.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
      }
      path = cut;
    }
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    if (filled(glyph) && progress >= 1) {
      paint.style = PaintingStyle.fill;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke / s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(GlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.stroke != stroke || old.progress != progress;
}
