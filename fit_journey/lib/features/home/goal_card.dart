import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/phosphor.dart';
import '../../core/type.dart';
import '../../widgets/odometer.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.fill, required this.seconds, this.onTap});

  final double fill;
  final double seconds;
  final VoidCallback? onTap;

  static const rect = Rect.fromLTWH(21.5, 129.5, 349.5, 122);
  static const goal = 0.68;

  static final _stepsWidth = (TextPainter(
    text: TextSpan(text: '5,200', style: font(21.3, 700)),
    textDirection: TextDirection.ltr,
  )..layout()).width;

  @override
  Widget build(BuildContext context) {
    final sweep = spring(fill, bounce: 0.18, freq: 1.6);
    final count = span(fill, 0.0, 0.85, Curves.easeOutCubic);
    final percent = (goal * 100 * count).round();
    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: SizedBox(
        width: rect.width,
        height: rect.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Palette.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Palette.shadow.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 5)),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 65 - 48,
                top: 60.5 - 48,
                width: 96,
                height: 96,
                child: CustomPaint(painter: _RingPainter(progress: goal * sweep, glow: fill < 1 ? math.sin(fill * math.pi) : 0)),
              ),
              Label.centered(
                '$percent%',
                cx: 64.5,
                base: 68.7,
                span: 90,
                style: font(20.6, 700, color: const Color(0xFF10A881)),
              ),
              Label("Today's Goal", x: 132.8, base: 38.3, style: font(15.85, 600, color: const Color(0xFF53616F))),
              Positioned(
                left: 133.0,
                top: 70.0 - baselineOffset(font(21.3, 700, height: 1.25)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Odometer(value: '5,200', style: font(21.3, 700, color: const Color(0xFF10263F)), progress: count),
                  ],
                ),
              ),
              Label('/ 7,500', x: 133.0 + _stepsWidth + 5.6, base: 69.8, style: font(20.1, 500, color: const Color(0xFF2B465A))),
              Label('steps', x: 133.0, base: 94.9, style: font(15.45, 500, color: const Color(0xFF7B8593))),
              Positioned(
                left: 316.5,
                top: 48,
                width: 26,
                height: 26,
                child: Transform.translate(
                  offset: Offset(wave(seconds, 1.6) * 1.2 * (fill >= 1 ? 1 : 0), 0),
                  child: const Center(child: Icon(PhosphorBold.caretRight, size: 19, color: Color(0xFF6C7886))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.glow});

  final double progress;
  final double glow;

  static const radius = 42.0;
  static const stroke = 11.0;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final track = Paint()
      ..color = Palette.track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(c, radius, track);
    if (progress <= 0.001) return;
    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress.clamp(0.0, 0.999);
    final rect = Rect.fromCircle(center: c, radius: radius);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(start);
    canvas.translate(-c.dx, -c.dy);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.sweep(
        c,
        const [Color(0xFF14C39B), Color(0xFF04A981), Color(0xFF0BAE86)],
        const [0.0, 0.55, 1.0],
      );
    canvas.drawArc(rect, 0, sweep, false, arc);
    canvas.restore();
    final head = c + Offset(math.cos(start + sweep), math.sin(start + sweep)) * radius;
    if (glow > 0) {
      canvas.drawCircle(
        head,
        stroke * 0.9,
        Paint()
          ..color = const Color(0xFF3FE0B4).withValues(alpha: 0.45 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    final knob = c + Offset(math.cos(start + 0.13), math.sin(start + 0.13)) * radius;
    canvas.drawCircle(
      knob,
      stroke * 0.46,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.72)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.glow != glow;
}
