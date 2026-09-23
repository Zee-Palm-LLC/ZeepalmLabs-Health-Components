import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/theme.dart';
import '../data/cycle.dart';

class CycleRing extends StatelessWidget {
  const CycleRing({
    super.key,
    required this.cycle,
    required this.enter,
    required this.pulse,
    this.radius = 122,
    this.stroke = 19,
  });

  final Cycle cycle;
  final Animation<double> enter;
  final Animation<double> pulse;
  final double radius;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _RingPainter(cycle: cycle, enter: enter, pulse: pulse, radius: radius, stroke: stroke),
        isComplex: true,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.cycle,
    required this.enter,
    required this.pulse,
    required this.radius,
    required this.stroke,
  }) : super(repaint: Listenable.merge([enter, pulse, cycle]));

  final Cycle cycle;
  final Animation<double> enter;
  final Animation<double> pulse;
  final double radius;
  final double stroke;

  static const _gap = 0.05;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final t = enter.value;
    final beat = pulse.value;
    if (t <= 0.001) return;

    canvas.drawCircle(
      centre,
      radius * 0.92,
      Paint()
        ..shader = ui.Gradient.radial(
          centre,
          radius * 0.92,
          [
            Colors.white.withValues(alpha: 0.10 * t),
            Colors.white.withValues(alpha: 0.02 * t),
            Colors.white.withValues(alpha: 0),
          ],
          const [0, 0.6, 1],
        ),
    );

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white.withValues(alpha: 0.09 * t),
    );

    final current = cycle.phase;
    for (var i = 0; i < cycle.phases.length; i++) {
      final phase = cycle.phases[i];
      final begin = 0.05 + i * 0.1;
      final grow = span(t, begin, begin + 0.5, swift);
      if (grow <= 0) continue;
      final from = phase.startAngle + _gap / 2;
      final sweep = (phase.sweep - _gap) * grow;
      if (sweep <= 0.001) continue;
      final active = phase.name == current.name;
      final band = _band(centre, radius, stroke, from, sweep);
      canvas.drawPath(
        band,
        Paint()
          ..color = phase.colour.withValues(alpha: (active ? 0.55 : 0.28) * grow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, active ? 14 : 8),
      );
      canvas.drawPath(
        band,
        Paint()
          ..shader = ui.Gradient.sweep(
            centre,
            [phase.colour.withValues(alpha: active ? 1 : 0.52), phase.tail.withValues(alpha: active ? 1 : 0.52)],
            const [0, 1],
            TileMode.clamp,
            from,
            from + math.max(sweep, 0.0001),
          ),
      );
    }

    _progress(canvas, centre, t, beat);
    _ticks(canvas, centre, t, beat);
  }

  void _progress(Canvas canvas, Offset centre, double t, double beat) {
    final trackRadius = radius + stroke / 2 + 11;
    canvas.drawCircle(
      centre,
      trackRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = Colors.white.withValues(alpha: 0.10 * t),
    );
    final grow = span(t, 0.35, 1.0, gentle);
    if (grow <= 0.01) return;
    final start = -math.pi / 2;
    final sweep = (cycle.angleOfDay(cycle.day + 0.5) - start) * grow;
    final rect = Rect.fromCircle(center: centre, radius: trackRadius);
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = Hue.rose.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.sweep(
          centre,
          [Hue.rose, Hue.peach, Hue.amber],
          const [0, 0.6, 1],
          TileMode.clamp,
          start,
          start + math.max(sweep, 0.0001),
        ),
    );

    final head = centre + Offset(math.cos(start + sweep), math.sin(start + sweep)) * trackRadius;
    final wave = beat % 1.0;
    canvas.drawCircle(
      head,
      (6 + wave * 16) * grow,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Hue.amber.withValues(alpha: 0.5 * (1 - wave) * grow),
    );
    canvas.drawCircle(
      head,
      12 * grow,
      Paint()
        ..shader = ui.Gradient.radial(head, 12, [Hue.amber.withValues(alpha: 0.6), Hue.amber.withValues(alpha: 0)]),
    );
    canvas.drawCircle(head, 5.4 * grow, Paint()..color = Colors.white);
    canvas.drawCircle(head, 3 * grow, Paint()..color = Hue.amber);
  }

  void _ticks(Canvas canvas, Offset centre, double t, double beat) {
    final r = radius - stroke / 2 - 9;
    for (var day = 1; day <= cycle.length; day++) {
      final show = span(t, 0.25 + day / cycle.length * 0.4, 0.6 + day / cycle.length * 0.4, swift);
      if (show <= 0.01) continue;
      final angle = cycle.angleOfDay(day + 0.5);
      final at = centre + Offset(math.cos(angle), math.sin(angle)) * r;
      final isToday = day == cycle.day;
      final past = day < cycle.day;
      canvas.drawCircle(
        at,
        (isToday ? 3 : 1.6) * show,
        Paint()
          ..color = isToday
              ? Colors.white.withValues(alpha: 0.9 * show)
              : Colors.white.withValues(alpha: (past ? 0.42 : 0.16) * show),
      );
    }
  }

  static Path _band(Offset centre, double radius, double stroke, double from, double sweep) {
    final outer = radius + stroke / 2;
    final inner = radius - stroke / 2;
    final cap = stroke / 2;
    final capSweep = math.min(cap / radius, sweep / 2);
    final a0 = from + capSweep;
    final a1 = from + sweep - capSweep;
    return Path()
      ..addArc(Rect.fromCircle(center: centre, radius: outer), a0, a1 - a0)
      ..arcToPoint(
        centre + Offset(math.cos(a1) * inner, math.sin(a1) * inner),
        radius: Radius.circular(cap),
        clockwise: true,
      )
      ..arcTo(Rect.fromCircle(center: centre, radius: inner), a1, a0 - a1, false)
      ..arcToPoint(
        centre + Offset(math.cos(a0) * outer, math.sin(a0) * outer),
        radius: Radius.circular(cap),
        clockwise: true,
      )
      ..close();
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.radius != radius || oldDelegate.stroke != stroke;
}
