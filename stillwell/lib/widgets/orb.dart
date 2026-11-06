import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// A glossy glass sphere: coloured body, soft rim light, a crisp specular
/// highlight and a tinted glow pooled underneath.
class Orb extends StatelessWidget {
  const Orb({super.key, required this.size, required this.mood, this.glow = 1, this.child});

  final double size;
  final Mood mood;
  final double glow;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: OrbPainter(base: mood.base, light: mood.light, deep: mood.deep, glow: glow),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class OrbPainter extends CustomPainter {
  const OrbPainter({required this.base, required this.light, required this.deep, this.glow = 1, this.opacity = 1});

  final Color base;
  final Color light;
  final Color deep;
  final double glow;
  final double opacity;

  Color _a(Color c, [double k = 1]) => c.withValues(alpha: c.a * opacity * k);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = size.center(Offset.zero);
    final body = Rect.fromCircle(center: c, radius: r);

    // Coloured glow pooled below the sphere.
    if (glow > 0) {
      canvas.drawCircle(
        c + Offset(0, r * 0.42),
        r * 0.92,
        Paint()
          ..color = _a(base, 0.55 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
      );
    }

    // Body: light top-left falling to the deep tone at the lower right.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.45),
          radius: 1.05,
          colors: [_a(Color.lerp(light, Colors.white, 0.5)!), _a(light), _a(base), _a(Color.lerp(deep, base, 0.2)!)],
          stops: const [0, 0.3, 0.76, 1],
        ).createShader(body),
    );

    // Bounce light along the bottom rim.
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    canvas.drawCircle(
      c + Offset(r * 0.18, r * 0.95),
      r * 0.62,
      Paint()
        ..color = _a(Colors.white, 0.42)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.32),
    );
    canvas.restore();

    // Thin bright rim.
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, r * 0.04)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_a(Colors.white, 0.75), _a(Colors.white, 0.05), _a(Colors.white, 0.5)],
        ).createShader(body),
    );

    // Specular highlight.
    final spec = Rect.fromCenter(center: c + Offset(-r * 0.3, -r * 0.42), width: r * 0.78, height: r * 0.46);
    canvas.drawOval(spec, Paint()..shader = RadialGradient(colors: [_a(Colors.white, 0.95), _a(Colors.white, 0)]).createShader(spec));
    canvas.drawCircle(c + Offset(r * 0.5, r * 0.45), r * 0.07, Paint()..color = _a(Colors.white, 0.85));
  }

  @override
  bool shouldRepaint(OrbPainter old) =>
      old.base != base || old.light != light || old.deep != deep || old.glow != glow || old.opacity != opacity;
}

/// The empty day: a dashed ring.
class DashedRing extends StatelessWidget {
  const DashedRing({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: const CustomPaint(painter: _DashPainter()),
  );
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2 - 0.75;
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..color = const Color(0xFFBDB8B2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    const n = 26;
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a, math.pi * 2 / n * 0.5, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => false;
}
