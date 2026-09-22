import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum G {
  leaf,
  waveform,
  moonFill,
  moonStar,
  home,
  mix,
  library,
  search,
  user,
  back,
  arrow,
  heart,
  heartFill,
  timer,
  speaker,
  sliders,
  prev,
  next,
  pause,
  play,
  close,
  plus,
  check,
  chevronDown,
}

class Glyph extends StatelessWidget {
  const Glyph(
    this.g, {
    super.key,
    this.size = 24,
    this.color = const Color(0xFFFFFFFF),
    this.stroke = 1.6,
  });

  final G g;
  final double size;
  final Color color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: GlyphPainter(g, color, stroke),
    );
  }
}

class GlyphPainter extends CustomPainter {
  GlyphPainter(this.g, this.color, this.stroke);

  final G g;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke / s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    switch (g) {
      case G.leaf:
        _leaf(canvas, fill, line);
      case G.waveform:
        _bars(canvas, line, const [3.0, 7.0, 12.0, 7.0, 3.0], true);
      case G.mix:
        _mix(canvas, line);
      case G.moonFill:
        canvas.drawPath(
          _crescent(const Offset(12.4, 12), 8.2, const Offset(4.6, -3.4), 7.4),
          fill,
        );
      case G.moonStar:
        canvas.drawPath(
          _crescent(
            const Offset(11.4, 12.6),
            8.4,
            const Offset(4.8, -3.6),
            7.6,
          ),
          line,
        );
        _sparkle(canvas, fill, const Offset(18.6, 4.8), 1.5);
      case G.home:
        _home(canvas, fill);
      case G.library:
        _library(canvas, line, fill);
      case G.search:
        canvas.drawCircle(const Offset(10.6, 10.6), 6.6, line);
        canvas.drawLine(const Offset(15.6, 15.6), const Offset(20, 20), line);
      case G.user:
        canvas.drawCircle(const Offset(12, 8.4), 3.9, fill);
        final body = Path()
          ..moveTo(4.6, 20.2)
          ..cubicTo(4.8, 15.4, 8.2, 13.6, 12, 13.6)
          ..cubicTo(15.8, 13.6, 19.2, 15.4, 19.4, 20.2)
          ..close();
        canvas.drawPath(body, fill);
      case G.back:
        canvas.drawLine(const Offset(19, 12), const Offset(5.5, 12), line);
        canvas.drawPath(
          Path()
            ..moveTo(11, 6.2)
            ..lineTo(5.2, 12)
            ..lineTo(11, 17.8),
          line,
        );
      case G.arrow:
        canvas.drawLine(const Offset(4.5, 12), const Offset(19, 12), line);
        canvas.drawPath(
          Path()
            ..moveTo(13.4, 6.4)
            ..lineTo(19.2, 12)
            ..lineTo(13.4, 17.6),
          line,
        );
      case G.heart:
        canvas.drawPath(_heart(), line);
      case G.heartFill:
        canvas.drawPath(_heart(), fill);
        canvas.drawPath(_heart(), line);
      case G.timer:
        _timer(canvas, line);
      case G.speaker:
        _speaker(canvas, fill, line);
      case G.sliders:
        _sliders(canvas, line);
      case G.prev:
        _skip(canvas, fill, false);
      case G.next:
        _skip(canvas, fill, true);
      case G.pause:
        final r = const Radius.circular(1.6);
        canvas.drawRRect(RRect.fromLTRBR(6.4, 4.6, 9.9, 19.4, r), fill);
        canvas.drawRRect(RRect.fromLTRBR(14.1, 4.6, 17.6, 19.4, r), fill);
      case G.play:
        final p = Path()
          ..moveTo(8, 5.2)
          ..quadraticBezierTo(7.2, 4.8, 7.2, 5.8)
          ..lineTo(7.2, 18.2)
          ..quadraticBezierTo(7.2, 19.2, 8, 18.8)
          ..lineTo(18.4, 12.8)
          ..quadraticBezierTo(19.2, 12, 18.4, 11.2)
          ..close();
        canvas.drawPath(p, fill);
      case G.close:
        canvas.drawLine(const Offset(6.5, 6.5), const Offset(17.5, 17.5), line);
        canvas.drawLine(const Offset(17.5, 6.5), const Offset(6.5, 17.5), line);
      case G.plus:
        canvas.drawLine(const Offset(12, 5), const Offset(12, 19), line);
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), line);
      case G.check:
        canvas.drawPath(
          Path()
            ..moveTo(5.5, 12.5)
            ..lineTo(10, 17)
            ..lineTo(18.5, 7.5),
          line,
        );
      case G.chevronDown:
        canvas.drawPath(
          Path()
            ..moveTo(6, 9.5)
            ..lineTo(12, 15)
            ..lineTo(18, 9.5),
          line,
        );
    }
    canvas.restore();
  }

  void _leaf(Canvas canvas, Paint fill, Paint line) {
    final left = Path()
      ..moveTo(11.2, 19.4)
      ..cubicTo(6.2, 18.6, 4.2, 14.2, 5.2, 8.4)
      ..cubicTo(9.4, 9.2, 11.6, 12.6, 11.2, 19.4)
      ..close();
    final right = Path()
      ..moveTo(12.6, 19.2)
      ..cubicTo(12.2, 12.6, 14.4, 7.4, 19.8, 5.4)
      ..cubicTo(20.8, 12.4, 17.8, 17.6, 12.6, 19.2)
      ..close();
    canvas.drawPath(left, fill);
    canvas.drawPath(right, fill);
    final vein = Paint()
      ..color = const Color(0xFF1A1830).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(10.6, 18.2), const Offset(6.8, 10.4), vein);
    canvas.drawLine(const Offset(13.4, 17.8), const Offset(18.6, 7.2), vein);
    canvas.drawLine(const Offset(12, 21), const Offset(12, 18.6), line);
  }

  void _bars(Canvas canvas, Paint line, List<double> heights, bool dots) {
    final n = heights.length;
    final gap = 3.0;
    final x0 = 12 - (n - 1) * gap / 2;
    for (var i = 0; i < n; i++) {
      final h = heights[i] / 2;
      canvas.drawLine(
        Offset(x0 + i * gap, 12 - h),
        Offset(x0 + i * gap, 12 + h),
        line,
      );
    }
    if (dots) {
      final d = Paint()..color = line.color;
      canvas.drawCircle(Offset(x0 - gap, 12), 0.9, d);
      canvas.drawCircle(Offset(x0 + n * gap, 12), 0.9, d);
    }
  }

  void _mix(Canvas canvas, Paint line) {
    _bars(canvas, line, const [4.0, 13.0, 8.0, 15.0, 6.0], false);
    canvas.drawLine(const Offset(1.6, 12), const Offset(4.6, 12), line);
    canvas.drawLine(const Offset(3.1, 10.5), const Offset(3.1, 13.5), line);
  }

  Path _crescent(Offset c, double r, Offset cut, double cr) {
    final outer = Path()..addOval(Rect.fromCircle(center: c, radius: r));
    final inner = Path()..addOval(Rect.fromCircle(center: c + cut, radius: cr));
    return Path.combine(PathOperation.difference, outer, inner);
  }

  void _sparkle(Canvas canvas, Paint fill, Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final rr = i.isEven ? r : r * 0.32;
      final o = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      if (i == 0) {
        p.moveTo(o.dx, o.dy);
      } else {
        p.lineTo(o.dx, o.dy);
      }
    }
    p.close();
    canvas.drawPath(p, fill);
  }

  void _home(Canvas canvas, Paint fill) {
    final outer = Path()
      ..moveTo(12, 3.2)
      ..lineTo(20.2, 10.2)
      ..quadraticBezierTo(20.8, 10.7, 20.8, 11.6)
      ..lineTo(20.8, 19.2)
      ..quadraticBezierTo(20.8, 20.8, 19.2, 20.8)
      ..lineTo(4.8, 20.8)
      ..quadraticBezierTo(3.2, 20.8, 3.2, 19.2)
      ..lineTo(3.2, 11.6)
      ..quadraticBezierTo(3.2, 10.7, 3.8, 10.2)
      ..close();
    final door = Path()
      ..addRRect(
        RRect.fromLTRBAndCorners(
          9.4,
          14.2,
          14.6,
          21,
          topLeft: const Radius.circular(2.6),
          topRight: const Radius.circular(2.6),
        ),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, outer, door), fill);
  }

  void _library(Canvas canvas, Paint line, Paint fill) {
    canvas.drawRRect(
      RRect.fromLTRBR(5, 3.4, 19, 20.6, const Radius.circular(2.6)),
      line,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(9, 9.2, 15, 15.8, const Radius.circular(1)),
      line..strokeWidth = line.strokeWidth * 0.8,
    );
    canvas.drawLine(const Offset(10.6, 11.6), const Offset(13.4, 11.6), line);
    canvas.drawLine(const Offset(10.6, 13.5), const Offset(12.6, 13.5), line);
  }

  Path _heart() {
    return Path()
      ..moveTo(12, 20)
      ..cubicTo(8.4, 17.6, 3.2, 14, 3.2, 9.2)
      ..cubicTo(3.2, 6.4, 5.4, 4.4, 7.9, 4.4)
      ..cubicTo(9.7, 4.4, 11.2, 5.4, 12, 6.9)
      ..cubicTo(12.8, 5.4, 14.3, 4.4, 16.1, 4.4)
      ..cubicTo(18.6, 4.4, 20.8, 6.4, 20.8, 9.2)
      ..cubicTo(20.8, 14, 15.6, 17.6, 12, 20)
      ..close();
  }

  void _timer(Canvas canvas, Paint line) {
    canvas.drawCircle(const Offset(12, 13), 7.6, line);
    canvas.drawPath(
      Path()
        ..moveTo(12, 8.8)
        ..lineTo(12, 13.2)
        ..lineTo(14.8, 15),
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(5.4, 5.8), radius: 2.6),
      math.pi * 0.85,
      math.pi * 0.95,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(18.6, 5.8), radius: 2.6),
      math.pi * 1.2,
      math.pi * 0.95,
      false,
      line,
    );
    canvas.drawLine(const Offset(7.2, 19.6), const Offset(6, 21), line);
    canvas.drawLine(const Offset(16.8, 19.6), const Offset(18, 21), line);
  }

  void _speaker(Canvas canvas, Paint fill, Paint line) {
    final body = Path()
      ..moveTo(3.4, 9.2)
      ..quadraticBezierTo(3.4, 8.4, 4.2, 8.4)
      ..lineTo(7.2, 8.4)
      ..lineTo(11.6, 4.8)
      ..quadraticBezierTo(12.6, 4.2, 12.6, 5.4)
      ..lineTo(12.6, 18.6)
      ..quadraticBezierTo(12.6, 19.8, 11.6, 19.2)
      ..lineTo(7.2, 15.6)
      ..lineTo(4.2, 15.6)
      ..quadraticBezierTo(3.4, 15.6, 3.4, 14.8)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(13, 12), radius: 3.6),
      -math.pi * 0.32,
      math.pi * 0.64,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(13, 12), radius: 7.2),
      -math.pi * 0.3,
      math.pi * 0.6,
      false,
      line,
    );
  }

  void _sliders(Canvas canvas, Paint line) {
    const rows = [6.0, 12.0, 18.0];
    const knobs = [15.0, 8.0, 13.0];
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(Offset(3.5, rows[i]), Offset(20.5, rows[i]), line);
      final knob = Paint()..color = const Color(0xFF15142A);
      canvas.drawCircle(Offset(knobs[i], rows[i]), 2.2, knob);
      canvas.drawCircle(Offset(knobs[i], rows[i]), 2.2, line);
    }
  }

  void _skip(Canvas canvas, Paint fill, bool forward) {
    canvas.save();
    if (!forward) {
      canvas.translate(24, 0);
      canvas.scale(-1, 1);
    }
    final tri = Path()
      ..moveTo(5.6, 5.4)
      ..quadraticBezierTo(5, 5, 5, 5.8)
      ..lineTo(5, 18.2)
      ..quadraticBezierTo(5, 19, 5.6, 18.6)
      ..lineTo(15.6, 12.6)
      ..quadraticBezierTo(16.2, 12, 15.6, 11.4)
      ..close();
    canvas.drawPath(tri, fill);
    canvas.drawRRect(
      RRect.fromLTRBR(16.8, 5, 19.2, 19, const Radius.circular(1)),
      fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(GlyphPainter old) =>
      old.g != g || old.color != color || old.stroke != stroke;
}
