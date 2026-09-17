import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

enum Glyph {
  home,
  homeFilled,
  calendar,
  care,
  settings,
  bell,
  flash,
  grid,
  back,
  more,
  mic,
  link,
  send,
  check,
  bowl,
  close,
  sparkle,
  clock,
  stop,
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(
    this.glyph, {
    super.key,
    this.size = 22,
    this.color = const Color(0xFF17191A),
    this.stroke = 1.6,
    this.progress = 1,
  });

  final Glyph glyph;
  final double size;
  final Color color;
  final double stroke;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: GlyphPainter(glyph, color: color, stroke: stroke, progress: progress),
      ),
    );
  }
}

class GlyphPainter extends CustomPainter {
  GlyphPainter(this.glyph, {required this.color, this.stroke = 1.6, this.progress = 1});

  final Glyph glyph;
  final Color color;
  final double stroke;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    canvas.save();
    canvas.scale(unit);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    switch (glyph) {
      case Glyph.home:
        canvas.drawPath(_house(), line);
        canvas.drawLine(const Offset(12, 15.2), const Offset(12, 18), line);
      case Glyph.homeFilled:
        final door = Path()
          ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(11.1, 14.4, 1.8, 4.4), const Radius.circular(0.9)));
        final solid = Path.combine(PathOperation.difference, _house(), door);
        canvas.drawPath(solid, fill);
        canvas.drawPath(solid, line..strokeWidth = stroke * 0.9);
      case Glyph.calendar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(3.5, 5, 17, 15.5), const Radius.circular(4)),
          line,
        );
        canvas.drawLine(const Offset(8, 3), const Offset(8, 6.6), line);
        canvas.drawLine(const Offset(16, 3), const Offset(16, 6.6), line);
        canvas.drawLine(const Offset(3.8, 9.6), const Offset(20.2, 9.6), line);
        for (final dot in const [
          Offset(8.2, 13.3),
          Offset(12, 13.3),
          Offset(15.8, 13.3),
          Offset(8.2, 16.8),
          Offset(12, 16.8),
          Offset(15.8, 16.8),
        ]) {
          canvas.drawCircle(dot, 0.95, fill);
        }
      case Glyph.care:
        final heart = Path()
          ..moveTo(12, 11.4)
          ..cubicTo(8.1, 9, 7.8, 6.2, 9.4, 5)
          ..cubicTo(10.5, 4.2, 11.6, 4.7, 12, 5.6)
          ..cubicTo(12.4, 4.7, 13.5, 4.2, 14.6, 5)
          ..cubicTo(16.2, 6.2, 15.9, 9, 12, 11.4)
          ..close();
        canvas.drawPath(heart, line);
        final hand = Path()
          ..moveTo(3.2, 14.6)
          ..lineTo(5.6, 14.6)
          ..cubicTo(7.4, 13.4, 9.4, 13.3, 11, 14.2)
          ..lineTo(13.4, 14.2)
          ..cubicTo(14.6, 14.2, 14.6, 16.4, 13.4, 16.4)
          ..lineTo(10.2, 16.4)
          ..moveTo(13.6, 16.3)
          ..lineTo(17.6, 14)
          ..cubicTo(19, 13.2, 20.4, 14.8, 19.3, 15.9)
          ..lineTo(15.3, 19.6)
          ..cubicTo(14.3, 20.5, 13.1, 20.9, 11.8, 20.9)
          ..lineTo(5.6, 20.9)
          ..lineTo(3.2, 20.9);
        canvas.drawPath(hand, line);
      case Glyph.settings:
        final gear = Path();
        for (var i = 0; i < 6; i++) {
          final a = math.pi / 6 + i * math.pi / 3;
          final b = a + math.pi / 3;
          final pa = Offset(12 + 9 * math.cos(a), 12 + 9 * math.sin(a));
          final pb = Offset(12 + 9 * math.cos(b), 12 + 9 * math.sin(b));
          final start = Offset.lerp(pa, pb, 0.18)!;
          final end = Offset.lerp(pa, pb, 0.82)!;
          if (i == 0) {
            gear.moveTo(start.dx, start.dy);
          } else {
            gear.lineTo(start.dx, start.dy);
          }
          gear.lineTo(end.dx, end.dy);
          final next = b + math.pi / 3;
          final pc = Offset(12 + 9 * math.cos(next), 12 + 9 * math.sin(next));
          final after = Offset.lerp(pb, pc, 0.18)!;
          gear.quadraticBezierTo(pb.dx, pb.dy, after.dx, after.dy);
        }
        gear.close();
        canvas.drawPath(gear, line);
        canvas.drawCircle(const Offset(12, 12), 3, line);
      case Glyph.bell:
        final bell = Path()
          ..moveTo(6.4, 16.8)
          ..lineTo(6.4, 11)
          ..cubicTo(6.4, 7.6, 8.9, 5.2, 12, 5.2)
          ..cubicTo(15.1, 5.2, 17.6, 7.6, 17.6, 11)
          ..lineTo(17.6, 16.8)
          ..lineTo(19, 18.2)
          ..lineTo(5, 18.2)
          ..close();
        canvas.drawPath(bell, line);
        canvas.drawLine(const Offset(12, 3.2), const Offset(12, 5.1), line);
        canvas.drawArc(Rect.fromCircle(center: const Offset(12, 19.2), radius: 2.2), 0.2, math.pi - 0.4, false, line);
      case Glyph.flash:
        final bolt = Path()
          ..moveTo(13.4, 2.8)
          ..lineTo(5.8, 13.4)
          ..lineTo(11.2, 13.4)
          ..lineTo(10.4, 21.2)
          ..lineTo(18.2, 10.6)
          ..lineTo(12.8, 10.6)
          ..close();
        canvas.drawPath(bolt, line);
      case Glyph.grid:
        for (final origin in const [Offset(3.5, 3.5), Offset(13.5, 3.5), Offset(3.5, 13.5), Offset(13.5, 13.5)]) {
          canvas.drawRRect(RRect.fromRectAndRadius(origin & const Size(7, 7), const Radius.circular(3.3)), line);
        }
      case Glyph.back:
        canvas.drawLine(const Offset(19.5, 12), const Offset(4.8, 12), line);
        canvas.drawPath(
          Path()
            ..moveTo(10.6, 6)
            ..lineTo(4.6, 12)
            ..lineTo(10.6, 18),
          line,
        );
      case Glyph.more:
        for (final y in const [5.0, 12.0, 19.0]) {
          canvas.drawCircle(Offset(12, y), 1.75, fill);
        }
      case Glyph.mic:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(8.8, 2.8, 6.4, 11.6), const Radius.circular(3.2)),
          line,
        );
        canvas.drawArc(const Rect.fromLTWH(5.2, 4.6, 13.6, 13.6), 0.15, math.pi - 0.3, false, line);
        canvas.drawLine(const Offset(12, 18.2), const Offset(12, 21.2), line);
        canvas.drawLine(const Offset(10.6, 7.6), const Offset(12, 7.6), line);
        canvas.drawLine(const Offset(10.6, 10.2), const Offset(12, 10.2), line);
      case Glyph.link:
        canvas.save();
        canvas.translate(12, 12);
        canvas.rotate(-math.pi / 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-9.6, -3.1, 11, 6.2), const Radius.circular(3.1)),
          line,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-1.4, -3.1, 11, 6.2), const Radius.circular(3.1)),
          line,
        );
        canvas.restore();
      case Glyph.send:
        final plane = Path()
          ..moveTo(20.4, 3.6)
          ..lineTo(3.8, 10.2)
          ..lineTo(10.6, 13.4)
          ..lineTo(13.8, 20.2)
          ..close();
        canvas.drawPath(plane, line);
        canvas.drawLine(const Offset(10.8, 13.2), const Offset(15.6, 8.4), line);
      case Glyph.check:
        final tick = Path()
          ..moveTo(6.6, 12.4)
          ..lineTo(10.2, 16)
          ..lineTo(17.4, 8.4);
        _drawPartial(canvas, tick, line, progress);
      case Glyph.bowl:
        final bowl = Path()
          ..moveTo(3.6, 12.2)
          ..lineTo(20.4, 12.2)
          ..cubicTo(20.4, 16.6, 16.6, 19.8, 12, 19.8)
          ..cubicTo(7.4, 19.8, 3.6, 16.6, 3.6, 12.2)
          ..close();
        canvas.drawPath(bowl, fill);
        canvas.drawArc(const Rect.fromLTWH(7.4, 5.8, 9.2, 9.2), math.pi + 0.2, math.pi - 0.4, false, line);
        canvas.drawCircle(const Offset(12, 5.2), 1, fill);
      case Glyph.close:
        canvas.drawLine(const Offset(6.5, 6.5), const Offset(17.5, 17.5), line);
        canvas.drawLine(const Offset(17.5, 6.5), const Offset(6.5, 17.5), line);
      case Glyph.sparkle:
        final star = Path()
          ..moveTo(12, 3)
          ..cubicTo(12.6, 8.6, 15.4, 11.4, 21, 12)
          ..cubicTo(15.4, 12.6, 12.6, 15.4, 12, 21)
          ..cubicTo(11.4, 15.4, 8.6, 12.6, 3, 12)
          ..cubicTo(8.6, 11.4, 11.4, 8.6, 12, 3)
          ..close();
        canvas.drawPath(star, fill);
      case Glyph.clock:
        canvas.drawCircle(const Offset(12, 12), 8.6, line);
        canvas.drawPath(
          Path()
            ..moveTo(12, 7.6)
            ..lineTo(12, 12.2)
            ..lineTo(14.8, 14),
          line,
        );
      case Glyph.stop:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(7, 7, 10, 10), const Radius.circular(2.6)), fill);
    }
    canvas.restore();
  }

  Path _house() {
    return Path()
      ..moveTo(3.6, 10.6)
      ..cubicTo(3.6, 9.9, 3.9, 9.3, 4.4, 8.9)
      ..lineTo(10.6, 3.9)
      ..cubicTo(11.4, 3.3, 12.6, 3.3, 13.4, 3.9)
      ..lineTo(19.6, 8.9)
      ..cubicTo(20.1, 9.3, 20.4, 9.9, 20.4, 10.6)
      ..lineTo(20.4, 18.2)
      ..cubicTo(20.4, 19.7, 19.2, 20.9, 17.7, 20.9)
      ..lineTo(6.3, 20.9)
      ..cubicTo(4.8, 20.9, 3.6, 19.7, 3.6, 18.2)
      ..close();
  }

  void _drawPartial(Canvas canvas, Path path, Paint paint, double amount) {
    if (amount <= 0) return;
    if (amount >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * amount;
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
        oldDelegate.progress != progress;
  }
}

class CapsuleArt extends StatelessWidget {
  const CapsuleArt({super.key, this.size = 24, this.angle = -0.72});

  final double size;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _CapsulePainter(angle)),
    );
  }
}

class _CapsulePainter extends CustomPainter {
  _CapsulePainter(this.angle);

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.rotate(angle);
    final length = s * 0.98;
    final girth = s * 0.42;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: length, height: girth),
      Radius.circular(girth / 2),
    );
    canvas.drawRRect(
      body.shift(Offset(0, s * 0.05)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, s * 0.04),
    );
    canvas.save();
    canvas.clipRRect(body);
    final left = Rect.fromLTRB(-length / 2, -girth / 2, 0, girth / 2);
    final right = Rect.fromLTRB(0, -girth / 2, length / 2, girth / 2);
    canvas.drawRect(
      left,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, -girth / 2),
          Offset(0, girth / 2),
          const [Color(0xFFD6ECFA), Color(0xFFA9D3F0), Color(0xFF6FA6D6)],
          const [0, 0.45, 1],
        ),
    );
    canvas.drawRect(
      right,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, -girth / 2),
          Offset(0, girth / 2),
          const [Color(0xFFFF8A8F), Color(0xFFEF4F58), Color(0xFFC0303B)],
          const [0, 0.45, 1],
        ),
    );
    canvas.drawRect(
      Rect.fromLTRB(-s * 0.012, -girth / 2, s * 0.012, girth / 2),
      Paint()..color = const Color(0x40000000),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-length / 2 + girth * 0.35, -girth * 0.3, length - girth * 0.7, girth * 0.18),
        Radius.circular(girth * 0.1),
      ),
      Paint()..color = const Color(0x8CFFFFFF),
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CapsulePainter oldDelegate) => oldDelegate.angle != angle;
}

class TabletArt extends StatelessWidget {
  const TabletArt({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _TabletPainter()),
    );
  }
}

class _TabletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.rotate(-0.35);
    final rim = Rect.fromCenter(center: Offset(0, s * 0.06), width: s * 0.92, height: s * 0.5);
    final top = Rect.fromCenter(center: Offset.zero, width: s * 0.92, height: s * 0.5);
    canvas.drawOval(rim, Paint()..color = const Color(0xFFC94C88));
    canvas.drawOval(
      top,
      Paint()
        ..shader = ui.Gradient.linear(
          top.topLeft,
          top.bottomRight,
          const [Color(0xFFFFB3D2), Color(0xFFF28AB6), Color(0xFFE06AA2)],
          const [0, 0.5, 1],
        ),
    );
    canvas.drawLine(
      Offset(-s * 0.3, 0),
      Offset(s * 0.3, 0),
      Paint()
        ..color = const Color(0x55A8336B)
        ..strokeWidth = s * 0.04
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-s * 0.16, -s * 0.12), width: s * 0.3, height: s * 0.08),
      Paint()..color = const Color(0x99FFFFFF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TabletPainter oldDelegate) => false;
}
