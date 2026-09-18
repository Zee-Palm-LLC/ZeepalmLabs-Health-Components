import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'theme.dart';

enum Glyph {
  cart,
  bell,
  back,
  more,
  sun,
  moon,
  plus,
  minus,
  camera,
  upload,
  home,
  homeFilled,
  analytic,
  analyticFilled,
  bag,
  bagFilled,
  profile,
  profileFilled,
  check,
  close,
  heart,
  heartFilled,
  star,
  arrowRight,
  chevronRight,
  drop,
  clock,
  share,
  gallery,
  shield,
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(
    this.glyph, {
    super.key,
    this.size = 22,
    this.color = Palette.ink,
    this.stroke = 1.6,
    this.progress = 1,
    this.gradient,
  });

  final Glyph glyph;
  final double size;
  final Color color;
  final double stroke;
  final double progress;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: GlyphPainter(glyph, color: color, stroke: stroke, progress: progress, gradient: gradient),
      ),
    );
  }
}

class GlyphPainter extends CustomPainter {
  GlyphPainter(this.glyph, {required this.color, this.stroke = 1.6, this.progress = 1, this.gradient});

  final Glyph glyph;
  final Color color;
  final double stroke;
  final double progress;
  final Gradient? gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    canvas.save();
    canvas.scale(unit);
    final shader = gradient?.createShader(const Rect.fromLTWH(0, 0, 24, 24));
    final line = Paint()
      ..color = color
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..shader = shader;

    switch (glyph) {
      case Glyph.cart:
        final cart = Path()
          ..moveTo(2.8, 3.6)
          ..lineTo(4.6, 3.6)
          ..cubicTo(5.4, 3.6, 5.9, 4.1, 6, 4.9)
          ..lineTo(7.1, 14.2)
          ..cubicTo(7.2, 15, 7.8, 15.5, 8.6, 15.5)
          ..lineTo(18, 15.5)
          ..moveTo(6.3, 7)
          ..lineTo(20.2, 7)
          ..cubicTo(20.8, 7, 21.2, 7.6, 21, 8.2)
          ..lineTo(19.6, 12.4)
          ..cubicTo(19.4, 13, 18.9, 13.4, 18.2, 13.4)
          ..lineTo(7, 13.4);
        canvas.drawPath(cart, line);
        canvas.drawCircle(const Offset(9, 19.2), 1.4, line);
        canvas.drawCircle(const Offset(17.2, 19.2), 1.4, line);
      case Glyph.bell:
        final bell = Path()
          ..moveTo(6.2, 16.6)
          ..lineTo(6.2, 10.8)
          ..cubicTo(6.2, 7.4, 8.8, 4.8, 12, 4.8)
          ..cubicTo(15.2, 4.8, 17.8, 7.4, 17.8, 10.8)
          ..lineTo(17.8, 16.6)
          ..lineTo(19.2, 18)
          ..lineTo(4.8, 18)
          ..close();
        canvas.drawPath(bell, line);
        canvas.drawArc(Rect.fromCircle(center: const Offset(12, 19.3), radius: 2.1), 0.25, math.pi - 0.5, false, line);
        canvas.drawLine(const Offset(12, 3), const Offset(12, 4.7), line);
      case Glyph.back:
        canvas.drawPath(
          Path()
            ..moveTo(14.8, 5.5)
            ..lineTo(8.3, 12)
            ..lineTo(14.8, 18.5),
          line,
        );
      case Glyph.chevronRight:
        canvas.drawPath(
          Path()
            ..moveTo(9.2, 5.5)
            ..lineTo(15.7, 12)
            ..lineTo(9.2, 18.5),
          line,
        );
      case Glyph.more:
        for (final y in const [5.2, 12.0, 18.8]) {
          canvas.drawCircle(Offset(12, y), 1.8, fill);
        }
      case Glyph.sun:
        canvas.drawCircle(const Offset(12, 12), 3.6, line);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final dir = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(const Offset(12, 12) + dir * 6.4, const Offset(12, 12) + dir * 8.6, line);
        }
      case Glyph.moon:
        final moon = Path()
          ..moveTo(20.2, 14.3)
          ..cubicTo(18.9, 18.1, 15.2, 20.6, 11.2, 20.2)
          ..cubicTo(6.8, 19.8, 3.6, 16.2, 3.8, 11.8)
          ..cubicTo(4, 7.9, 6.9, 4.6, 10.6, 3.9)
          ..cubicTo(8.2, 7.4, 8.9, 12.2, 12.1, 14.8)
          ..cubicTo(14.5, 16.7, 17.6, 16.6, 20.2, 14.3)
          ..close();
        canvas.drawPath(moon, line);
      case Glyph.plus:
        canvas.drawLine(const Offset(12, 5.5), const Offset(12, 18.5), line);
        canvas.drawLine(const Offset(5.5, 12), const Offset(18.5, 12), line);
      case Glyph.minus:
        canvas.drawLine(const Offset(5.5, 12), const Offset(18.5, 12), line);
      case Glyph.camera:
        final body = Path()
          ..moveTo(4.8, 7.6)
          ..lineTo(7.6, 7.6)
          ..lineTo(9.1, 5.2)
          ..lineTo(14.9, 5.2)
          ..lineTo(16.4, 7.6)
          ..lineTo(19.2, 7.6)
          ..cubicTo(20.4, 7.6, 21.2, 8.4, 21.2, 9.6)
          ..lineTo(21.2, 17.2)
          ..cubicTo(21.2, 18.4, 20.4, 19.2, 19.2, 19.2)
          ..lineTo(4.8, 19.2)
          ..cubicTo(3.6, 19.2, 2.8, 18.4, 2.8, 17.2)
          ..lineTo(2.8, 9.6)
          ..cubicTo(2.8, 8.4, 3.6, 7.6, 4.8, 7.6)
          ..close();
        canvas.drawPath(body, line);
        canvas.drawCircle(const Offset(12, 13), 3.4, line);
      case Glyph.upload:
        canvas.drawLine(const Offset(12, 4), const Offset(12, 14.5), line);
        canvas.drawPath(
          Path()
            ..moveTo(8, 8)
            ..lineTo(12, 4)
            ..lineTo(16, 8),
          line,
        );
        canvas.drawPath(
          Path()
            ..moveTo(4, 14)
            ..lineTo(4, 17.6)
            ..cubicTo(4, 19, 5, 20, 6.4, 20)
            ..lineTo(17.6, 20)
            ..cubicTo(19, 20, 20, 19, 20, 17.6)
            ..lineTo(20, 14),
          line,
        );
      case Glyph.home:
      case Glyph.homeFilled:
        final house = Path()
          ..moveTo(3.8, 10.4)
          ..cubicTo(3.8, 9.7, 4.1, 9.1, 4.7, 8.7)
          ..lineTo(10.7, 4.1)
          ..cubicTo(11.5, 3.5, 12.5, 3.5, 13.3, 4.1)
          ..lineTo(19.3, 8.7)
          ..cubicTo(19.9, 9.1, 20.2, 9.7, 20.2, 10.4)
          ..lineTo(20.2, 18.4)
          ..cubicTo(20.2, 19.8, 19.1, 20.8, 17.8, 20.8)
          ..lineTo(6.2, 20.8)
          ..cubicTo(4.9, 20.8, 3.8, 19.8, 3.8, 18.4)
          ..close();
        if (glyph == Glyph.homeFilled) {
          canvas.drawPath(house, fill);
          canvas.drawPath(house, line);
        } else {
          canvas.drawPath(house, line);
          canvas.drawLine(const Offset(9.5, 16.4), const Offset(14.5, 16.4), line);
        }
      case Glyph.analytic:
      case Glyph.analyticFilled:
        final frame = RRect.fromRectAndRadius(const Rect.fromLTWH(3.4, 3.4, 17.2, 17.2), const Radius.circular(4.4));
        final bars = Paint()
          ..color = glyph == Glyph.analyticFilled ? const Color(0xFFFFFFFF) : color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;
        if (glyph == Glyph.analyticFilled) {
          canvas.drawRRect(frame, fill);
          canvas.drawRRect(frame, line);
        } else {
          canvas.drawRRect(frame, line);
        }
        canvas.drawLine(const Offset(3.6, 8.2), const Offset(20.4, 8.2), bars);
        canvas.drawLine(const Offset(8.4, 17), const Offset(8.4, 14), bars);
        canvas.drawLine(const Offset(12, 17), const Offset(12, 11.8), bars);
        canvas.drawLine(const Offset(15.6, 17), const Offset(15.6, 13.2), bars);
      case Glyph.bag:
      case Glyph.bagFilled:
        final bag = Path()
          ..moveTo(5.2, 8.2)
          ..lineTo(18.8, 8.2)
          ..lineTo(19.6, 18.2)
          ..cubicTo(19.7, 19.7, 18.6, 20.8, 17.2, 20.8)
          ..lineTo(6.8, 20.8)
          ..cubicTo(5.4, 20.8, 4.3, 19.7, 4.4, 18.2)
          ..close();
        if (glyph == Glyph.bagFilled) canvas.drawPath(bag, fill);
        canvas.drawPath(bag, line);
        final handle = Path()
          ..moveTo(8.6, 10.4)
          ..lineTo(8.6, 6.6)
          ..cubicTo(8.6, 4.7, 10.1, 3.2, 12, 3.2)
          ..cubicTo(13.9, 3.2, 15.4, 4.7, 15.4, 6.6)
          ..lineTo(15.4, 10.4);
        canvas.drawPath(handle, line);
        if (glyph == Glyph.bagFilled) {
          canvas.drawCircle(const Offset(8.6, 11.2), 0.9, Paint()..color = const Color(0xFFFFFFFF));
          canvas.drawCircle(const Offset(15.4, 11.2), 0.9, Paint()..color = const Color(0xFFFFFFFF));
        }
      case Glyph.profile:
      case Glyph.profileFilled:
        final head = Rect.fromCircle(center: const Offset(12, 7.8), radius: 4);
        final shoulders = Path()
          ..moveTo(4.4, 20.6)
          ..cubicTo(4.4, 16.8, 7.8, 14.4, 12, 14.4)
          ..cubicTo(16.2, 14.4, 19.6, 16.8, 19.6, 20.6)
          ..close();
        if (glyph == Glyph.profileFilled) {
          canvas.drawOval(head, fill);
          canvas.drawPath(shoulders, fill);
        }
        canvas.drawOval(head, line);
        canvas.drawPath(shoulders, line);
      case Glyph.check:
        _partial(
          canvas,
          Path()
            ..moveTo(6.4, 12.4)
            ..lineTo(10.2, 16.2)
            ..lineTo(17.8, 8.2),
          line,
        );
      case Glyph.close:
        canvas.drawLine(const Offset(6.5, 6.5), const Offset(17.5, 17.5), line);
        canvas.drawLine(const Offset(17.5, 6.5), const Offset(6.5, 17.5), line);
      case Glyph.heart:
      case Glyph.heartFilled:
        final heart = Path()
          ..moveTo(12, 20.2)
          ..cubicTo(5.2, 15.8, 3, 12.4, 3, 9.2)
          ..cubicTo(3, 6.2, 5.3, 4, 8.1, 4)
          ..cubicTo(9.8, 4, 11.2, 4.9, 12, 6.2)
          ..cubicTo(12.8, 4.9, 14.2, 4, 15.9, 4)
          ..cubicTo(18.7, 4, 21, 6.2, 21, 9.2)
          ..cubicTo(21, 12.4, 18.8, 15.8, 12, 20.2)
          ..close();
        if (glyph == Glyph.heartFilled) canvas.drawPath(heart, fill);
        canvas.drawPath(heart, line);
      case Glyph.star:
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final r = i.isEven ? 9.0 : 4.1;
          final a = -math.pi / 2 + i * math.pi / 5;
          final p = Offset(12 + r * math.cos(a), 12.6 + r * math.sin(a));
          i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
        }
        star.close();
        canvas.drawPath(star, fill);
      case Glyph.arrowRight:
        canvas.drawLine(const Offset(4.5, 12), const Offset(19, 12), line);
        canvas.drawPath(
          Path()
            ..moveTo(13.2, 6.2)
            ..lineTo(19, 12)
            ..lineTo(13.2, 17.8),
          line,
        );
      case Glyph.drop:
        final drop = Path()
          ..moveTo(12, 3.4)
          ..cubicTo(15.4, 7.6, 18.4, 11, 18.4, 14.4)
          ..cubicTo(18.4, 18, 15.5, 20.8, 12, 20.8)
          ..cubicTo(8.5, 20.8, 5.6, 18, 5.6, 14.4)
          ..cubicTo(5.6, 11, 8.6, 7.6, 12, 3.4)
          ..close();
        canvas.drawPath(drop, line);
      case Glyph.clock:
        canvas.drawCircle(const Offset(12, 12), 8.6, line);
        canvas.drawPath(
          Path()
            ..moveTo(12, 7.6)
            ..lineTo(12, 12.2)
            ..lineTo(14.8, 14),
          line,
        );
      case Glyph.share:
        canvas.drawCircle(const Offset(17.5, 5.8), 2.4, line);
        canvas.drawCircle(const Offset(6.5, 12), 2.4, line);
        canvas.drawCircle(const Offset(17.5, 18.2), 2.4, line);
        canvas.drawLine(const Offset(8.6, 10.8), const Offset(15.4, 7), line);
        canvas.drawLine(const Offset(8.6, 13.2), const Offset(15.4, 17), line);
      case Glyph.gallery:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(3.2, 4, 17.6, 16), const Radius.circular(4)),
          line,
        );
        canvas.drawCircle(const Offset(9, 9.6), 1.8, line);
        canvas.drawPath(
          Path()
            ..moveTo(3.6, 17.4)
            ..lineTo(8.6, 13.2)
            ..lineTo(12, 16)
            ..lineTo(15.6, 12)
            ..lineTo(20.4, 16.6),
          line,
        );
      case Glyph.shield:
        final shield = Path()
          ..moveTo(12, 3.2)
          ..lineTo(19, 6)
          ..lineTo(19, 11.4)
          ..cubicTo(19, 15.8, 16, 19.2, 12, 20.8)
          ..cubicTo(8, 19.2, 5, 15.8, 5, 11.4)
          ..lineTo(5, 6)
          ..close();
        canvas.drawPath(shield, line);
    }
    canvas.restore();
  }

  void _partial(Canvas canvas, Path path, Paint paint) {
    if (progress <= 0) return;
    if (progress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * progress;
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final take = math.min(remaining, metric.length);
      canvas.drawPath(metric.extractPath(0, take), paint);
      remaining -= take;
    }
  }

  @override
  bool shouldRepaint(GlyphPainter oldDelegate) {
    return oldDelegate.glyph != glyph ||
        oldDelegate.color != color ||
        oldDelegate.stroke != stroke ||
        oldDelegate.progress != progress ||
        oldDelegate.gradient != gradient;
  }
}

class SparkleMark extends StatelessWidget {
  const SparkleMark({super.key, this.size = 26, this.twinkle = 0});

  final double size;
  final double twinkle;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SparklePainter(twinkle)),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.twinkle);

  final double twinkle;

  Path _star(Offset c, double r, double pinch) {
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..cubicTo(c.dx + r * pinch, c.dy - r * pinch, c.dx + r * pinch, c.dy - r * pinch, c.dx + r, c.dy)
      ..cubicTo(c.dx + r * pinch, c.dy + r * pinch, c.dx + r * pinch, c.dy + r * pinch, c.dx, c.dy + r)
      ..cubicTo(c.dx - r * pinch, c.dy + r * pinch, c.dx - r * pinch, c.dy + r * pinch, c.dx - r, c.dy)
      ..cubicTo(c.dx - r * pinch, c.dy - r * pinch, c.dx - r * pinch, c.dy - r * pinch, c.dx, c.dy - r)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        const [Color(0xFFB36BF0), Color(0xFFE77FC5), Color(0xFFF78C9F)],
        const [0, 0.55, 1],
      );
    final pulse = 1 + 0.08 * math.sin(twinkle * math.pi * 2);
    canvas.drawPath(_star(Offset(s * 0.42, s * 0.58), s * 0.36 * pulse, 0.16), paint);
    final small = 1 + 0.25 * math.sin(twinkle * math.pi * 2 + 1.8);
    canvas.drawPath(_star(Offset(s * 0.8, s * 0.2), s * 0.15 * small, 0.2), paint);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.twinkle != twinkle;
}
