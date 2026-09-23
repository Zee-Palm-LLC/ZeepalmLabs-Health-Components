import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'motion.dart';
import 'theme.dart';

class Aurora extends StatefulWidget {
  const Aurora({
    super.key,
    this.horizon = 1,
    this.fade = 1,
    this.night = 1,
    this.moon = 0,
    this.moonAt,
    this.moonRadius = 0,
    this.floor = 1,
  });

  final double horizon;
  final double fade;
  final double night;
  final double moon;
  final Offset? moonAt;
  final double moonRadius;
  final double floor;

  @override
  State<Aurora> createState() => _AuroraState();
}

class _AuroraState extends State<Aurora> with SingleTickerProviderStateMixin, ClockMixin {
  @override
  void initState() {
    super.initState();
    startClock();
  }

  @override
  void dispose() {
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: AuroraPainter(
          clock: clock,
          horizon: widget.horizon,
          fade: widget.fade,
          night: widget.night,
          moon: widget.moon,
          moonAt: widget.moonAt,
          moonRadius: widget.moonRadius,
          floor: widget.floor,
        ),
        isComplex: true,
      ),
    );
  }
}

class AuroraPainter extends CustomPainter {
  AuroraPainter({
    required this.clock,
    required this.horizon,
    required this.fade,
    required this.night,
    required this.moon,
    required this.moonAt,
    required this.moonRadius,
    required this.floor,
  }) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final double horizon;
  final double fade;
  final double night;
  final double moon;
  final Offset? moonAt;
  final double moonRadius;
  final double floor;

  static final _stars = List.generate(64, (i) {
    final rand = math.Random(i * 613 + 7);
    return (
      Offset(rand.nextDouble(), rand.nextDouble()),
      rand.nextDouble() * 1.2 + 0.5,
      rand.nextDouble(),
      rand.nextDouble() < 0.16,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = clock.value;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          [
            Color.lerp(Hue.deepCard, Hue.night, night)!,
            Color.lerp(Hue.lift, Hue.deep, night)!,
            Color.lerp(Hue.veil, Hue.deepCard, night)!,
            Color.lerp(Hue.deepCard, Hue.canvas, 0.75)!,
          ],
          const [0, 0.38, 0.66, 1],
        ),
    );

    void blob(Offset centre, double radius, Color colour, double alpha) {
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            centre,
            radius,
            [
              colour.withValues(alpha: alpha * fade),
              colour.withValues(alpha: alpha * 0.42 * fade),
              colour.withValues(alpha: 0),
            ],
            const [0, 0.55, 1],
          ),
      );
    }

    blob(
      Offset(w * (0.22 + 0.05 * wave(s, 17)), h * (0.20 + 0.03 * wave(s, 13, 0.3))),
      w * 0.68,
      const Color(0xFF6B3F8F),
      0.62,
    );
    blob(
      Offset(w * (0.92 + 0.04 * wave(s, 15, 0.4)), h * (0.12 + 0.03 * wave(s, 19))),
      w * 0.58,
      const Color(0xFFFF6F8B),
      0.30,
    );
    blob(
      Offset(w * (0.78 + 0.05 * wave(s, 21, 0.6)), h * (0.52 + 0.04 * wave(s, 16, 0.2))),
      w * 0.62,
      const Color(0xFF8E5BC8),
      0.42,
    );
    blob(
      Offset(w * (0.12 + 0.06 * wave(s, 23, 0.15)), h * (0.66 + 0.03 * wave(s, 12))),
      w * 0.52,
      const Color(0xFFFFA36C),
      0.20,
    );

    if (night > 0.02) {
      for (final (at, radius, phase, big) in _stars) {
        final twinkle = 0.45 + 0.55 * math.sin((s / 3.4 + phase) * math.pi * 2);
        final alpha = (big ? 1.0 : 0.7) * twinkle * night * fade;
        if (alpha <= 0.02) continue;
        final centre = Offset(at.dx * w, at.dy * h * 0.72);
        if (big) {
          _sparkle(canvas, centre, radius * 6, alpha);
        } else {
          canvas.drawCircle(centre, radius, Paint()..color = Hue.moonlight.withValues(alpha: alpha));
        }
      }
    }

    if (moon > 0.01) {
      final centre = moonAt ?? Offset(w * 0.26, h * 0.32);
      final radius = moonRadius > 0 ? moonRadius : w * 0.3;
      paintCrescent(canvas, centre, radius * (1 + 0.012 * wave(s, 6)), moon * fade);
    }

    if (floor > 0.01) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, h * (0.30 + 0.06 * (1 - horizon))),
            Offset(0, h * (0.52 + 0.1 * (1 - horizon))),
            [
              Hue.canvas.withValues(alpha: 0),
              Hue.canvas.withValues(alpha: 0.5 * floor),
              Hue.canvas.withValues(alpha: 0.88 * floor),
            ],
            const [0, 0.74, 1],
          ),
      );
    }
  }

  void _sparkle(Canvas canvas, Offset at, double r, double alpha) {
    canvas.drawCircle(
      at,
      r * 0.6,
      Paint()
        ..shader = ui.Gradient.radial(at, r * 1.4, [
          Hue.moonlight.withValues(alpha: alpha * 0.45),
          Hue.moonlight.withValues(alpha: 0),
        ]),
    );
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final tip = at + Offset(math.cos(a), math.sin(a)) * r;
      final left = at + Offset(math.cos(a + math.pi / 4), math.sin(a + math.pi / 4)) * (r * 0.2);
      final right = at + Offset(math.cos(a - math.pi / 4), math.sin(a - math.pi / 4)) * (r * 0.2);
      path.moveTo(at.dx, at.dy);
      path.quadraticBezierTo(left.dx, left.dy, tip.dx, tip.dy);
      path.quadraticBezierTo(right.dx, right.dy, at.dx, at.dy);
    }
    canvas.drawPath(path, Paint()..color = Hue.moonlight.withValues(alpha: alpha));
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) {
    return oldDelegate.fade != fade ||
        oldDelegate.night != night ||
        oldDelegate.moon != moon ||
        oldDelegate.moonAt != moonAt ||
        oldDelegate.moonRadius != moonRadius ||
        oldDelegate.floor != floor ||
        oldDelegate.horizon != horizon;
  }
}

void paintCrescent(Canvas canvas, Offset centre, double radius, double fade, {double tilt = 0.08}) {
  if (fade <= 0.01) return;
  canvas.drawCircle(
    centre,
    radius * 2,
    Paint()
      ..shader = ui.Gradient.radial(
        centre,
        radius * 2,
        [
          Hue.moonlight.withValues(alpha: 0.34 * fade),
          Hue.moonlight.withValues(alpha: 0.12 * fade),
          Hue.moonlight.withValues(alpha: 0),
        ],
        const [0, 0.42, 1],
      ),
  );

  canvas.save();
  canvas.translate(centre.dx, centre.dy);
  canvas.rotate(tilt);
  canvas.translate(-centre.dx, -centre.dy);
  final body = Path.combine(
    PathOperation.difference,
    Path()..addOval(Rect.fromCircle(center: centre, radius: radius)),
    Path()..addOval(Rect.fromCircle(center: centre + Offset(radius * 0.25, -radius * 0.11), radius: radius * 0.985)),
  );
  canvas.drawPath(
    body,
    Paint()
      ..color = Hue.moonlight.withValues(alpha: fade * 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
  );
  canvas.drawPath(
    body,
    Paint()
      ..shader = ui.Gradient.linear(
        centre - Offset(radius, radius),
        centre + Offset(radius, radius),
        [
          const Color(0xFFFFF8E2).withValues(alpha: fade),
          const Color(0xFFFFEBC4).withValues(alpha: fade),
          const Color(0xFFF8D2A8).withValues(alpha: fade * 0.92),
        ],
        const [0, 0.55, 1],
      ),
  );
  canvas.restore();
}

class MoonOverlay extends StatelessWidget {
  const MoonOverlay({super.key, required this.centre, required this.radius, required this.fade, this.spin = 0});

  final Offset centre;
  final double radius;
  final double fade;
  final double spin;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _MoonPainter(centre: centre, radius: radius, fade: fade, spin: spin),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  const _MoonPainter({required this.centre, required this.radius, required this.fade, required this.spin});

  final Offset centre;
  final double radius;
  final double fade;
  final double spin;

  @override
  void paint(Canvas canvas, Size size) {
    paintCrescent(canvas, centre, radius, fade, tilt: 0.08 + spin);
  }

  @override
  bool shouldRepaint(_MoonPainter oldDelegate) {
    return oldDelegate.centre != centre ||
        oldDelegate.radius != radius ||
        oldDelegate.fade != fade ||
        oldDelegate.spin != spin;
  }
}
