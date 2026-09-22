import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'clock.dart';

class Crescent extends StatelessWidget {
  const Crescent({
    super.key,
    required this.radius,
    this.cut = const Offset(0.38, -0.28),
    this.cutScale = 0.9,
    this.glow = 1,
  });

  final double radius;
  final Offset cut;
  final double cutScale;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(radius * 2),
      painter: CrescentPainter(cut: cut, cutScale: cutScale, glow: glow),
    );
  }
}

class CrescentPainter extends CustomPainter {
  CrescentPainter({
    required this.cut,
    required this.cutScale,
    required this.glow,
  }) : super(repaint: SceneClock.instance);

  final Offset cut;
  final double cutScale;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    final t = SceneClock.instance.value;
    final breathe = 0.92 + 0.08 * math.sin(t * 0.6);

    canvas.drawCircle(
      c + Offset(-r * 0.18, r * 0.16),
      r * 2.6,
      Paint()
        ..shader = ui.Gradient.radial(
          c + Offset(-r * 0.18, r * 0.16),
          r * 2.6,
          [
            const Color(0xFFB7A8FF).withValues(alpha: 0.2 * glow * breathe),
            const Color(0xFF8C7BE8).withValues(alpha: 0.07 * glow * breathe),
            const Color(0x008C7BE8),
          ],
          [0.25, 0.55, 1],
        ),
    );

    final disc = Path()..addOval(Rect.fromCircle(center: c, radius: r));
    final shadow = Path()
      ..addOval(Rect.fromCircle(center: c + cut * r, radius: r * cutScale));
    final moon = Path.combine(PathOperation.difference, disc, shadow);

    canvas.drawPath(
      moon,
      Paint()
        ..color = const Color(0xFFCFC4FF).withValues(alpha: 0.55 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.16),
    );
    canvas.drawPath(
      moon,
      Paint()
        ..shader = ui.Gradient.linear(
          c + Offset(-r, r * 0.6),
          c + Offset(r * 0.4, -r),
          [
            const Color(0xFFFFFFFF),
            const Color(0xFFEDE8FF),
            const Color(0xFFBDB1F2),
          ],
          [0, 0.45, 1],
        ),
    );
    canvas.save();
    canvas.clipPath(moon);
    final spots = [
      (const Offset(-0.62, 0.1), 0.16),
      (const Offset(-0.4, 0.5), 0.12),
      (const Offset(-0.1, 0.72), 0.1),
      (const Offset(-0.7, -0.3), 0.09),
    ];
    for (final (o, s) in spots) {
      canvas.drawCircle(
        c + o * r,
        r * s,
        Paint()
          ..color = const Color(0xFF9D92D6).withValues(alpha: 0.28)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
      );
    }
    canvas.drawPath(
      Path()..addOval(
        Rect.fromCircle(center: c + cut * r, radius: r * cutScale + r * 0.05),
      ),
      Paint()
        ..color = const Color(0xFF8E80D8).withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(CrescentPainter old) =>
      old.cut != cut || old.cutScale != cutScale || old.glow != glow;
}

class Twinkle {
  const Twinkle(this.at, this.size, this.phase, this.speed);

  final Offset at;
  final double size;
  final double phase;
  final double speed;
}

List<Twinkle> scatterStars({
  required int count,
  required int seed,
  required bool Function(Offset unit) accept,
}) {
  final rnd = math.Random(seed);
  final out = <Twinkle>[];
  var guard = 0;
  while (out.length < count && guard < count * 40) {
    guard++;
    final u = Offset(rnd.nextDouble(), rnd.nextDouble());
    if (!accept(u)) continue;
    final big = rnd.nextDouble() < 0.14;
    out.add(
      Twinkle(
        u,
        big ? 1.1 + rnd.nextDouble() * 0.5 : 0.45 + rnd.nextDouble() * 0.45,
        rnd.nextDouble() * 6.28,
        0.6 + rnd.nextDouble() * 1.6,
      ),
    );
  }
  return out;
}

class StarsPainter extends CustomPainter {
  StarsPainter(this.stars, {this.opacity = 1})
    : super(repaint: SceneClock.instance);

  final List<Twinkle> stars;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final t = SceneClock.instance.value;
    final core = Paint();
    final halo = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
    for (final s in stars) {
      final tw = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * s.speed + s.phase));
      final p = Offset(s.at.dx * size.width, s.at.dy * size.height);
      final a = (tw * opacity).clamp(0.0, 1.0);
      if (s.size > 1) {
        halo.color = const Color(0xFFCFC8FF).withValues(alpha: 0.35 * a);
        canvas.drawCircle(p, s.size * 2.4, halo);
      }
      core.color = const Color(0xFFF4F1FF).withValues(alpha: 0.85 * a);
      canvas.drawCircle(p, s.size, core);
    }
  }

  @override
  bool shouldRepaint(StarsPainter old) =>
      old.stars != stars || old.opacity != opacity;
}

class LanternGlowPainter extends CustomPainter {
  LanternGlowPainter(this.at) : super(repaint: SceneClock.instance);

  final Offset at;

  @override
  void paint(Canvas canvas, Size size) {
    final t = SceneClock.instance.value;
    final flicker =
        0.82 +
        0.1 * math.sin(t * 7.3) * math.sin(t * 3.1 + 1) +
        0.06 * math.sin(t * 13.7 + 2) +
        0.04 * math.sin(t * 23.0);
    final c = Offset(at.dx * size.width, at.dy * size.height);
    final r = size.width * 0.2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.radial(
          c,
          r,
          [
            const Color(0xFFFFB36B).withValues(alpha: 0.22 * flicker),
            const Color(0xFFFF8A3D).withValues(alpha: 0.06 * flicker),
            const Color(0x00FF8A3D),
          ],
          [0, 0.4, 1],
        ),
    );
    canvas.drawCircle(
      c,
      size.width * 0.018,
      Paint()
        ..blendMode = BlendMode.plus
        ..color = const Color(0xFFFFE0A8).withValues(alpha: 0.35 * flicker)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(LanternGlowPainter old) => old.at != at;
}

class ShimmerPainter extends CustomPainter {
  ShimmerPainter(this.center, this.spread)
    : super(repaint: SceneClock.instance);

  final Offset center;
  final Size spread;

  @override
  void paint(Canvas canvas, Size size) {
    final t = SceneClock.instance.value;
    final rnd = math.Random(11);
    final paint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
    for (var i = 0; i < 26; i++) {
      final v = rnd.nextDouble();
      final y = center.dy * size.height + v * spread.height * size.height;
      final w =
          (0.25 + rnd.nextDouble() * 0.75) *
          spread.width *
          size.width *
          (1 - v * 0.4);
      final drift = math.sin(t * (0.5 + rnd.nextDouble()) + i) * 3;
      final x =
          center.dx * size.width +
          (rnd.nextDouble() - 0.5) * spread.width * size.width * 0.5 +
          drift;
      final a =
          (0.5 + 0.5 * math.sin(t * (1.2 + rnd.nextDouble() * 1.5) + i * 1.7)) *
          (1 - v) *
          0.3;
      paint
        ..color = const Color(0xFFD8D0FF).withValues(alpha: a)
        ..strokeWidth = 1.1;
      canvas.drawLine(Offset(x - w / 2, y), Offset(x + w / 2, y), paint);
    }
  }

  @override
  bool shouldRepaint(ShimmerPainter old) => false;
}
