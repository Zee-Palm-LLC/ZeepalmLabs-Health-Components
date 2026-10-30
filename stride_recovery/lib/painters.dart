import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Streak flame (24 × 30 design box): warm gradient when the day's goal was
/// hit, cool grey otherwise. [flicker] is the time used for the live wobble.
class FlamePainter extends CustomPainter {
  FlamePainter({required this.lit, required this.flicker, this.selected = false});

  final double lit; // 0 grey … 1 orange (animated)
  final double flicker;
  final bool selected;

  static final _outer = Path()
    ..moveTo(12, 1)
    ..cubicTo(14, 7, 21, 10, 21, 18.5)
    ..cubicTo(21, 24.5, 17, 29, 12, 29)
    ..cubicTo(7, 29, 3, 25, 3, 19.5)
    ..cubicTo(3, 14.5, 6, 11.5, 8.2, 8.2)
    ..cubicTo(8.4, 11.5, 9.6, 13, 11, 13.2)
    ..cubicTo(10, 8.5, 10.8, 4.2, 12, 1)
    ..close();

  static final _inner = Path()
    ..moveTo(12.4, 14)
    ..cubicTo(14.6, 17, 16.4, 19.2, 16.4, 22.4)
    ..cubicTo(16.4, 25.3, 14.4, 27.2, 12, 27.2)
    ..cubicTo(9.6, 27.2, 7.6, 25.3, 7.6, 22.6)
    ..cubicTo(7.6, 20.2, 9.8, 18.6, 10.6, 16.6)
    ..cubicTo(11.6, 18, 12.2, 18.6, 12.8, 18.8)
    ..cubicTo(12.6, 17.2, 12.4, 15.6, 12.4, 14)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 30);
    // Lit flames sway a little from the base.
    final sway = lit * 0.035 * math.sin(flicker * 7.3);
    final stretch = 1 + lit * 0.04 * math.sin(flicker * 9.1 + 1);
    canvas.translate(12, 29);
    canvas.transform(
      (Matrix4.identity()
            ..setEntry(0, 1, sway)
            ..scaleByDouble(1, stretch, 1, 1))
          .storage,
    );
    canvas.translate(-12, -29);

    if (lit > 0.05) {
      canvas.drawPath(
        _outer,
        Paint()
          ..color = C.orange.withValues(alpha: 0.35 * lit)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    final hot = [const Color(0xFFFFC94D), const Color(0xFFFF7A00)];
    final cold = [const Color(0xFFD9DEE5), const Color(0xFFBFC6D0)];
    canvas.drawPath(
      _outer,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(cold[0], hot[0], lit)!, Color.lerp(cold[1], hot[1], lit)!],
        ).createShader(const Rect.fromLTWH(0, 0, 24, 30)),
    );
    canvas.drawPath(_inner, Paint()..color = Color.lerp(const Color(0xFFEFF2F6), const Color(0xFFFFF0B8), lit)!);
    canvas.restore();
  }

  @override
  bool shouldRepaint(FlamePainter old) => true;
}

/// The step gauge: a fat 220° arc with a pale track, a sky-to-blue fill up
/// to [value] (0..1), a soft highlight and a dark goal tick at the fill end.
class GaugePainter extends CustomPainter {
  GaugePainter({required this.value, required this.shine});

  final double value;
  final double shine; // 0..1 sweep of a light glint along the fill

  static const start = math.pi * 0.97; // just below the left horizontal
  static const sweep = math.pi * 1.06; // to just below the right horizontal

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 30.0;
    final c = Offset(size.width / 2, size.height - stroke / 2 - 30);
    final r = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep, false, base..color = C.track);

    final v = clamp01(value);
    if (v > 0.002) {
      final fill = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        // Angles relative to the arc start (rotated into place) so the
        // gradient never wraps across 0°.
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: sweep,
          colors: [Color(0xFF9EDCFF), Color(0xFF5CB8FF), Color(0xFF2F8CF0), Color(0xFF9FD4FF)],
          stops: [0, 0.35, 0.82, 1],
          transform: GradientRotation(start),
        ).createShader(rect);
      // Soft glow under the fill.
      canvas.drawArc(
        rect,
        start,
        sweep * v,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = C.blue.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawArc(rect, start, sweep * v, false, fill);
      // Inner highlight band.
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - stroke * 0.22),
        start + 0.04,
        math.max(0, sweep * v - 0.08),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.35),
      );
      // Travelling glint.
      if (shine > 0 && shine < 1) {
        final a = start + sweep * v * shine;
        canvas.drawArc(
          rect,
          a - 0.12,
          0.24,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = Colors.white.withValues(alpha: 0.35 * math.sin(shine * math.pi))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      // Goal tick at the end of the fill.
      final a = start + sweep * v;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + dir * (r - stroke * 0.42),
        c + dir * (r + stroke * 0.42),
        Paint()
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..color = C.ink,
      );
    }
  }

  @override
  bool shouldRepaint(GaugePainter old) => true;
}
