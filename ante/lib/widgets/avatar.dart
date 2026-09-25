import 'dart:math' as math;

import 'package:flutter/material.dart';

class RingAvatar extends StatelessWidget {
  const RingAvatar({
    super.key,
    required this.asset,
    required this.radius,
    required this.photo,
    this.ring = const [Color(0xFFE2E5EE), Color(0xFFB9BECB), Color(0xFF6F6C7A)],
    this.stroke = 2.2,
    this.sweep = 1,
    this.glow,
  });

  final String asset;
  final double radius;
  final double photo;
  final List<Color> ring;
  final double stroke;
  final double sweep;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return SizedBox.square(
      dimension: d,
      child: CustomPaint(
        foregroundPainter: _Ring(colors: ring, stroke: stroke, sweep: sweep, glow: glow),
        child: Center(
          child: ClipOval(
            child: Image.asset(
              asset,
              width: photo * 2,
              height: photo * 2,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends CustomPainter {
  _Ring({required this.colors, required this.stroke, required this.sweep, required this.glow});

  final List<Color> colors;
  final double stroke;
  final double sweep;
  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (sweep <= 0) return;
    final c = size.center(Offset.zero);
    final r = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    if (glow != null) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 3
          ..color = glow!
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = sweep < 1 ? StrokeCap.round : StrokeCap.butt
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * sweep, false, p);
  }

  @override
  bool shouldRepaint(_Ring old) => old.sweep != sweep || old.stroke != stroke || old.glow != glow;
}
