import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../layout.dart';
import '../mood.dart';

typedef _Star = ({double x, double y, double size, double phase, double speed, bool sparkle});

/// Background gradient, rotating sun rays and twinkling stars.
class SkyPainter extends CustomPainter {
  SkyPainter({required this.v, required this.time, required this.geo}) : super(repaint: time);

  final MoodVisual v;
  final ValueListenable<double> time;
  final Geo geo;

  static final List<_Star> _stars = () {
    final r = Random(42);
    return List<_Star>.generate(
      52,
      (_) => (
        x: r.nextDouble(),
        y: r.nextDouble(),
        size: 0.6 + r.nextDouble() * 1.1,
        phase: r.nextDouble() * pi * 2,
        speed: 0.6 + r.nextDouble() * 1.8,
        sparkle: r.nextDouble() < 0.16,
      ),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [v.skyTop, v.skyBottom],
        ).createShader(rect),
    );
    final a = v.ambient;
    if (a.rays > 0.01) _rays(canvas, size, t, a.rays);
    if (a.stars > 0.01) _paintStars(canvas, size, t, a.stars);
  }

  void _rays(Canvas canvas, Size size, double t, double k) {
    final c = geo.orbCenter;
    final len = size.longestSide * 1.25;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          v.rays.withValues(alpha: 0.58 * k),
          v.rays.withValues(alpha: 0.18 * k),
          v.rays.withValues(alpha: 0),
        ],
        stops: const [0.3, 0.62, 1],
      ).createShader(Rect.fromCircle(center: c, radius: len));
    const n = 16;
    final spin = t * 0.035;
    // Stressed rays throb a little.
    final pulse = 1 + 0.3 * sin(t * 2.2) * v.ambient.sparks;
    for (var i = 0; i < n; i++) {
      final ang = spin + i * 2 * pi / n;
      final hw = (i.isEven ? 0.085 : 0.05) * pulse;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + cos(ang - hw) * len, c.dy + sin(ang - hw) * len)
        ..lineTo(c.dx + cos(ang + hw) * len, c.dy + sin(ang + hw) * len)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintStars(Canvas canvas, Size size, double t, double k) {
    final s = geo.s;
    final top = geo.y(52);
    final bottom = geo.orbCenter.dy - geo.orbR * 1.15;
    final paint = Paint();
    for (final st in _stars) {
      final p = Offset(st.x * size.width, top + st.y * (bottom - top));
      final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * sin(t * st.speed + st.phase));
      paint.color = const Color(0xFFFFFFFF).withValues(alpha: (k * twinkle * 0.9).clamp(0.0, 1.0));
      if (st.sparkle) {
        final r = 3.4 * s * st.size;
        final q = r * 0.22;
        final path = Path()
          ..moveTo(p.dx, p.dy - r)
          ..quadraticBezierTo(p.dx + q, p.dy - q, p.dx + r, p.dy)
          ..quadraticBezierTo(p.dx + q, p.dy + q, p.dx, p.dy + r)
          ..quadraticBezierTo(p.dx - q, p.dy + q, p.dx - r, p.dy)
          ..quadraticBezierTo(p.dx - q, p.dy - q, p.dx, p.dy - r)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(p, 0.85 * s * st.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SkyPainter old) => old.v != v || old.geo != geo;
}
