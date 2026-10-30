import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Everything the lens needs for one frame.
class LensSpec {
  LensSpec({
    required this.center,
    required this.radius,
    required this.sample,
    required this.mag,
    required this.disp,
    required this.wrap,
    this.shadow = 1,
  });

  final Offset center, sample;
  final Size radius; // ellipse radii
  final double mag, disp, wrap, shadow;
}

/// Paints the liquid-glass lens with the fragment shader, refracting a
/// snapshot of the scene. Falls back to a frosted disc until the first
/// snapshot exists.
class LensPainter extends CustomPainter {
  LensPainter({
    required this.spec,
    required this.program,
    required this.snapshot,
    required this.origin,
    required this.scale,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final LensSpec Function() spec;
  final ui.FragmentProgram? program;
  final ui.Image? Function() snapshot;
  final Offset Function() origin; // where the captured region sits on screen
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final s = spec();
    final rx = s.radius.width, ry = s.radius.height;
    final oval = Rect.fromCenter(center: s.center, width: rx * 2, height: ry * 2);

    // Soft contact shadow under the glass.
    if (s.shadow > 0) {
      canvas.drawOval(
        oval.shift(Offset(0, ry * 0.16)).deflate(rx * 0.06),
        Paint()
          ..color = Color.fromRGBO(70, 30, 20, 0.16 * s.shadow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(4, rx * 0.12)),
      );
    }

    final img = snapshot();
    final prog = program;
    if (img == null || prog == null) {
      canvas.drawOval(oval, Paint()..color = Colors.white.withValues(alpha: 0.35));
      return;
    }
    final sh = prog.fragmentShader()
      ..setFloat(0, s.center.dx)
      ..setFloat(1, s.center.dy)
      ..setFloat(2, rx)
      ..setFloat(3, ry)
      ..setFloat(4, s.sample.dx)
      ..setFloat(5, s.sample.dy)
      ..setFloat(6, s.mag)
      ..setFloat(7, s.disp)
      ..setFloat(8, s.wrap)
      ..setFloat(9, scale)
      ..setFloat(10, img.width.toDouble())
      ..setFloat(11, img.height.toDouble())
      ..setFloat(12, W.bg.r)
      ..setFloat(13, W.bg.g)
      ..setFloat(14, W.bg.b)
      ..setFloat(15, 1)
      ..setFloat(16, origin().dx)
      ..setFloat(17, origin().dy)
      ..setImageSampler(0, img);
    canvas.drawRect(oval.inflate(2), Paint()..shader = sh);
  }

  @override
  bool shouldRepaint(LensPainter old) => true;
}

/// The electric-blue "smile" that lights up inside the dome while it is held:
/// layered blurred strokes along the lower arc, violet halo to white-hot core.
class NeonPainter extends CustomPainter {
  NeonPainter({required this.center, required this.radius, required this.amount, required this.t});

  final Offset center;
  final double radius, amount, t;

  @override
  void paint(Canvas canvas, Size size) {
    if (amount < 0.01) return;
    final r = radius;
    // A "U" hugging the inner rim of the dome's visible cap: its sides start
    // just under the top of the glass and it bottoms out low inside it.
    final top = center.dy - r;
    final c = Offset(center.dx, top + r * 0.3);
    final oval = Rect.fromCenter(center: c, width: math.min(r * 1.6, 350), height: r * 0.95);
    const start = -0.2;
    const sweep = math.pi + 0.4;
    final breathe = 1 + 0.05 * math.sin(t * 4);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r * 0.99)));
    void band(Color col, double width, double blur, double alpha) {
      canvas.drawArc(
        oval,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width * breathe
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
          ..shader = SweepGradient(
            center: Alignment.center,
            startAngle: start,
            endAngle: start + sweep,
            colors: [
              col.withValues(alpha: 0),
              col.withValues(alpha: alpha * amount),
              col.withValues(alpha: alpha * amount),
              col.withValues(alpha: 0),
            ],
            stops: const [0, 0.2, 0.8, 1],
          ).createShader(oval),
      );
    }

    // As it fades the glow cools from violet toward pink, as in the video.
    final halo = Color.lerp(const Color(0xFFF0A2D8), const Color(0xFFB98CFF), amount)!;
    band(halo, r * 0.26, r * 0.08, 0.5); // soft halo
    band(const Color(0xFF7FD3FF), r * 0.17, r * 0.05, 0.35); // cyan inner glow
    band(const Color(0xFF2440FF), r * 0.11, r * 0.03, 0.95); // electric blue band
    band(const Color(0xFF5A86FF), r * 0.04, r * 0.012, 0.8); // bright core
    canvas.restore();
  }

  @override
  bool shouldRepaint(NeonPainter old) => true;
}
