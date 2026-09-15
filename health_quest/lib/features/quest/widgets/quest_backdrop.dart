import 'dart:math' as math;

import 'package:flutter/widgets.dart';


/// The valley behind the quest detail: a night sky, two ridges of pines and a
/// far mountain line, all drawn.
///
/// The reference uses a painted landscape here. Shipping a bitmap for it would
/// mean one fixed composition at one resolution; generated from a seeded
/// random it costs nothing, parallaxes in layers, and the stars can twinkle.
class QuestBackdrop extends StatelessWidget {
  const QuestBackdrop({
    super.key,
    required this.idle,
    required this.tone,
    this.parallax = Offset.zero,
  });

  final double idle;
  final Color tone;
  final Offset parallax;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: _BackdropPainter(
            idle: idle,
            tone: tone,
            parallax: parallax,
          ),
          child: const SizedBox.expand(),
        ),
      );
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.idle,
    required this.tone,
    required this.parallax,
  });

  final double idle;
  final Color tone;
  final Offset parallax;

  static final List<_Star> _stars = List<_Star>.generate(90, (int i) {
    final r = math.Random(i * 2654435761 % 100003);
    return _Star(
      x: r.nextDouble(),
      y: r.nextDouble() * 0.62,
      radius: 0.5 + r.nextDouble() * 1.4,
      phase: r.nextDouble() * math.pi * 2,
      speed: 0.8 + r.nextDouble() * 2.2,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Sky.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF080B1A),
            Color(0xFF121A34),
            Color(0xFF0C1226),
            Color(0xFF05060C),
          ],
          stops: <double>[0, 0.34, 0.6, 1],
        ).createShader(rect),
    );

    // A wash of the quest's own colour, low on the horizon.
    canvas.drawCircle(
      Offset(size.width * 0.5 + parallax.dx * 10, size.height * 0.46),
      size.width * 0.75,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: <Color>[
            tone.withValues(alpha: 0.13),
            tone.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.5, size.height * 0.46),
            radius: size.width * 0.75,
          ),
        ),
    );

    for (final s in _stars) {
      final tw = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(idle * s.speed + s.phase));
      canvas.drawCircle(
        Offset(
          s.x * size.width + parallax.dx * 4,
          s.y * size.height + parallax.dy * 3,
        ),
        s.radius,
        Paint()..color = const Color(0xFFDCE6FF).withValues(alpha: 0.75 * tw),
      );
    }

    // Far mountains, then two ridges of pines. Each layer is lighter and
    // slower than the one in front of it, which is what makes it read as
    // distance rather than as three shapes.
    _mountains(canvas, size, 0.50, const Color(0xFF1B2140), parallax.dx * 3);
    _pines(canvas, size, 0.56, const Color(0xFF141A33), 22, 0.09, parallax.dx * 6);
    _pines(canvas, size, 0.66, const Color(0xFF0B1022), 15, 0.14, parallax.dx * 11);

    // Ground haze so the ridges sit in something.
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            tone.withValues(alpha: 0.05),
            const Color(0x0005060C),
          ],
        ).createShader(
          Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45),
        ),
    );
  }

  void _mountains(
      Canvas canvas, Size size, double baseline, Color color, double shift) {
    final y = size.height * baseline;
    final path = Path()..moveTo(-20 + shift, y);
    final r = math.Random(7);
    var x = -20.0 + shift;
    while (x < size.width + 40) {
      final w = 70.0 + r.nextDouble() * 90;
      final h = 40.0 + r.nextDouble() * 70;
      path.lineTo(x + w / 2, y - h);
      path.lineTo(x + w, y);
      x += w;
    }
    path
      ..lineTo(size.width + 40, size.height)
      ..lineTo(-20 + shift, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _pines(Canvas canvas, Size size, double baseline, Color color,
      double spacing, double heightFactor, double shift) {
    final y = size.height * baseline;
    final path = Path()..moveTo(-30 + shift, y);
    final r = math.Random(spacing.round() * 31);
    var x = -30.0 + shift;
    while (x < size.width + 60) {
      final h = size.height * heightFactor * (0.6 + r.nextDouble() * 0.8);
      final w = spacing * (0.7 + r.nextDouble() * 0.7);
      // A pine is three stacked triangles; two is enough at this size.
      path
        ..lineTo(x, y)
        ..lineTo(x + w / 2, y - h)
        ..lineTo(x + w, y);
      x += w * 0.78;
    }
    path
      ..lineTo(size.width + 60, size.height)
      ..lineTo(-30 + shift, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.idle != idle || old.tone != tone || old.parallax != parallax;
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
  });

  final double x;
  final double y;
  final double radius;
  final double phase;
  final double speed;
}
