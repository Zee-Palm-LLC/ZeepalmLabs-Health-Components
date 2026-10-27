import 'dart:math';

import 'package:flutter/rendering.dart';

import '../layout.dart';
import '../mood.dart';

/// The shallow arc gauge: a circle of radius 233pt centred at (195, 463)
/// showing ±44° around the top.
class GaugePainter extends CustomPainter {
  GaugePainter({required this.v, required this.geo, required this.value});

  final MoodVisual v;
  final Geo geo;
  final double value;

  static const _half = 0.768;
  static const _start = -pi / 2 - _half;
  static const _sweep = _half * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final s = geo.s;
    final c = Offset(size.width / 2, geo.y(463));
    final r = 233 * s;
    final rect = Rect.fromCircle(center: c, radius: r);
    final pv = value.clamp(0.0, 1.0);

    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * s
        ..strokeCap = StrokeCap.round
        ..color = v.ink.withValues(alpha: 0.22),
    );
    canvas.drawArc(
      rect,
      _start,
      _sweep * pv,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * s
        ..color = v.ink.withValues(alpha: 0.12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * s),
    );
    canvas.drawArc(
      rect,
      _start,
      _sweep * pv,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * s
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          endAngle: _sweep,
          colors: [v.ink.withValues(alpha: 0.55), v.ink],
          transform: const GradientRotation(_start),
        ).createShader(rect),
    );

    // Progress head.
    final e = _start + _sweep * pv;
    final head = c + Offset(cos(e), sin(e)) * r;
    canvas.drawCircle(head, 7.5 * s, Paint()..color = v.ink.withValues(alpha: 0.16));
    canvas.drawCircle(head, 4 * s, Paint()..color = v.ink);

    // Dots riding just outside the arc.
    final dot = Paint();
    for (final (f, rad, alpha) in const [
      (0.2, 1.7, 0.55),
      (0.35, 1.1, 0.35),
      (0.5, 1.7, 0.55),
      (0.65, 1.1, 0.35),
      (0.8, 1.7, 0.55),
    ]) {
      final a = _start + _sweep * f;
      dot.color = v.ink.withValues(alpha: alpha);
      canvas.drawCircle(c + Offset(cos(a), sin(a)) * (r + 16 * s), rad * s, dot);
    }

    _label(canvas, '0', c, r, _start, s);
    _label(canvas, '100', c, r, _start + _sweep, s);
  }

  void _label(Canvas canvas, String text, Offset c, double r, double angle, double s) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: inter(8 * s, FontWeight.w600, v.ink.withValues(alpha: 0.75))),
      textDirection: TextDirection.ltr,
    )..layout();
    final p = c + Offset(cos(angle), sin(angle)) * (r - 13 * s);
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(angle + pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
    tp.dispose();
  }

  @override
  bool shouldRepaint(GaugePainter old) => old.v != v || old.value != value || old.geo != geo;
}
