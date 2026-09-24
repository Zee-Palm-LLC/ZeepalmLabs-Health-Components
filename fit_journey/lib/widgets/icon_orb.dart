import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/palette.dart';

class IconOrb extends StatelessWidget {
  const IconOrb({
    super.key,
    required this.swatch,
    required this.icon,
    this.core = 19,
    this.halo = 24.5,
    this.iconSize = 23,
    this.fill = 1,
    this.pop = 1,
    this.pulse = 0,
    this.seconds = 0,
  });

  final Swatch swatch;
  final IconData icon;
  final double core;
  final double halo;
  final double iconSize;
  final double fill;
  final double pop;
  final double pulse;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final side = halo * 2;
    final glyph = span(fill, 0.55, 1.0, Curves.linear);
    final bounce = spring(glyph, bounce: 0.5, freq: 2.6);
    return SizedBox(
      width: side,
      height: side,
      child: Transform.scale(
        scale: pop,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OrbPainter(swatch: swatch, core: core, halo: halo, fill: fill, pulse: pulse, seconds: seconds),
              ),
            ),
            Opacity(
              opacity: glyph.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.4 + 0.6 * bounce,
                child: Icon(icon, size: iconSize, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.swatch,
    required this.core,
    required this.halo,
    required this.fill,
    required this.pulse,
    required this.seconds,
  });

  final Swatch swatch;
  final double core;
  final double halo;
  final double fill;
  final double pulse;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final haloGrow = span(fill, 0.0, 0.5, Curves.easeOut);
    if (haloGrow > 0) {
      canvas.drawCircle(c, lerp(core * 0.8, halo, haloGrow), Paint()..color = swatch.halo.withValues(alpha: 0.92 * haloGrow));
    }
    final disc = Rect.fromCircle(center: c, radius: core);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(swatch.core, Colors.white, 0.07)!, Color.lerp(swatch.core, Colors.black, 0.08)!],
      ).createShader(disc);
    if (fill >= 1) {
      canvas.drawCircle(c, core, paint);
    } else if (fill > 0) {
      canvas.save();
      canvas.clipPath(Path()..addOval(disc));
      final level = c.dy + core - 2 * core * Curves.easeOut.transform(fill);
      final amp = 2.2 * (1 - fill);
      final surface = Path()..moveTo(disc.left - 2, disc.bottom + 2);
      for (var x = disc.left - 2; x <= disc.right + 2; x += 2) {
        final y = level + math.sin((x - disc.left) / 7 + seconds * 9) * amp;
        surface.lineTo(x, y);
      }
      surface
        ..lineTo(disc.right + 2, disc.bottom + 2)
        ..close();
      canvas.drawPath(surface, paint);
      canvas.restore();
    }
    if (pulse > 0 && pulse < 1) {
      final r = lerp(core, halo + 10, Curves.easeOut.transform(pulse));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * (1 - pulse) + 0.4
          ..color = swatch.core.withValues(alpha: 0.5 * (1 - pulse)),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.fill != fill || old.pulse != pulse || old.seconds != seconds || old.swatch != swatch;
}
