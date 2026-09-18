import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.value, required this.sweep, required this.glint, this.size = 114});

  final int value;
  final double sweep;
  final double glint;
  final double size;

  @override
  Widget build(BuildContext context) {
    final shown = (value * sweep).round();
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(fraction: value / 100 * sweep, glint: glint),
        child: Center(child: Text('$shown%', style: inter(size * 0.195, 600, spacing: -0.6))),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.glint});

  final double fraction;
  final double glint;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.088;
    final c = size.center(Offset.zero);
    final r = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xCCF6E9F6),
    );
    canvas.drawCircle(c, r - stroke / 2 - 1, Paint()..color = Colors.white.withValues(alpha: 0.35));
    if (fraction <= 0) return;
    final sweep = math.pi * 2 * fraction;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-c.dx, -c.dy);
    final shader = ui.Gradient.sweep(
      c,
      const [Color(0xFFC981E7), Color(0xFFD886D6), Color(0xFFEE8DB6), Color(0xFFF694A6)],
      const [0, 0.35, 0.7, 1],
      TileMode.clamp,
      0,
      math.max(sweep, 0.01),
    );
    canvas.drawArc(
      rect,
      0,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x55E68BCB)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawArc(
      rect,
      0,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
    canvas.drawCircle(Offset(c.dx + r, c.dy), stroke / 2, Paint()..color = const Color(0xFFC981E7));
    final g = c + Offset(math.cos(sweep * glint), math.sin(sweep * glint)) * r;
    canvas.drawCircle(
      g,
      stroke * 0.9,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55 * math.sin(glint * math.pi))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    final tip = c + Offset(math.cos(sweep), math.sin(sweep)) * r;
    canvas.drawCircle(tip, stroke * 0.26, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.fraction != fraction || oldDelegate.glint != glint;
}

class MetricBar extends StatelessWidget {
  const MetricBar({super.key, required this.label, required this.value, required this.fill});

  final String label;
  final int value;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: inter(11.5, 500, color: Palette.muted)),
            ),
            Text('${(value * fill).round()}', style: inter(11.5, 700)),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 6,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth * value / 100 * fill,
                    decoration: BoxDecoration(gradient: Palette.brand, borderRadius: BorderRadius.circular(3)),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
