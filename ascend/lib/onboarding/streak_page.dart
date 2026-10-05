import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/parts.dart';

class StreakHero extends StatelessWidget {
  const StreakHero({super.key, required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final arrive = span(t, 0.0, 0.42, Curves.linear);
    final s = spring(arrive, bounce: 0.32, freq: 1.7);
    final count = (100 * Curves.easeOutCubic.transform(span(t, 0.1, 0.6, Curves.linear))).round();
    final wreath = span(t, 0.38, 0.62, Curves.linear);
    final pill = span(t, 0.52, 0.72, Curves.linear);
    final done = span(t, 0.6, 0.7, Curves.linear);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: Glow(center: const Offset(201, 330), color: Tone.violet.withValues(alpha: 0.5), radius: 250, strength: span(t, 0, 0.35))),
        Positioned.fill(child: Glow(center: const Offset(250, 390), color: Tone.mint.withValues(alpha: 0.18), radius: 170, strength: span(t, 0.2, 0.6))),
        Positioned(
          left: 201 - 175,
          top: 220,
          width: 350,
          height: 270,
          child: Opacity(
            opacity: wreath,
            child: Transform.scale(
              scale: lerp(0.86, 1, Curves.easeOutBack.transform(wreath)),
              child: Tick(builder: (context, sec, _) => CustomPaint(painter: LaurelPainter(grow: wreath, sway: sec))),
            ),
          ),
        ),
        Positioned.fill(child: Motes(area: const Rect.fromLTRB(30, 190, 380, 500), count: 14, seed: 11, opacity: span(t, 0.3, 0.6))),
        Positioned(
          left: 201 - 124,
          top: 206,
          width: 248,
          height: 252,
          child: Opacity(
            opacity: span(arrive, 0, 0.2, Curves.linear),
            child: Transform.translate(
              offset: Offset(150 * (1 - Curves.easeOutCubic.transform(arrive)), 20 * (1 - s)),
              child: Transform.rotate(
                angle: -0.9 * (1 - s),
                child: Transform.scale(
                  scale: lerp(0.32, 1, s) * (1 + 0.05 * math.sin(done * math.pi)),
                  child: Tick(
                    builder: (context, sec, _) => CustomPaint(
                      painter: HexBadgePainter(seconds: sec, shine: span(t, 0.62, 0.9, Curves.linear)),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 374 - 206 - 80 * interAscent,
                            child: Center(
                              child: Line(
                                '$count',
                                style: Typo.badge.copyWith(shadows: const [Shadow(color: Color(0x553A1C9A), blurRadius: 18, offset: Offset(0, 6))]),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 404 - 206 - 13 * interAscent,
                            child: Opacity(opacity: done, child: Center(child: Line('DAYS', style: Typo.badgeUnit))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 86,
          top: 425,
          child: Opacity(
            opacity: span(pill, 0, 0.4, Curves.linear),
            child: Transform.translate(
              offset: Offset(0, 22 * (1 - spring(pill, bounce: 0.3, freq: 2))),
              child: _StreakPill(flame: span(t, 0.6, 0.82, Curves.linear)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.flame});

  final double flame;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 231,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xD91C1C24),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: const Color(0x1FFFFFFF), width: 0.9),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 131 - 86 - 13,
                top: 23 - 13,
                child: Tick(
                  builder: (context, s, child) {
                    final flick = 1 + 0.06 * math.sin(s * 9) * flame;
                    return Transform.scale(
                      scale: spring(flame, bounce: 0.5, freq: 2.4) * flick,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    );
                  },
                  child: Image.asset(Art.fire, width: 26, height: 26, filterQuality: FilterQuality.medium),
                ),
              ),
              Positioned(left: 160 - 86, top: 459.5 - 425 - 19 * interAscent, child: Line('100-day streak', style: Typo.streak)),
            ],
          ),
        ),
      ),
    );
  }
}

class HexBadgePainter extends CustomPainter {
  HexBadgePainter({required this.seconds, required this.shine});

  final double seconds;
  final double shine;

  Path _hex(Rect r, double radius) {
    final pts = <Offset>[
      Offset(r.center.dx, r.top),
      Offset(r.right, r.top + r.height * 0.27),
      Offset(r.right - r.width * 0.06, r.top + r.height * 0.8),
      Offset(r.center.dx, r.bottom),
      Offset(r.left + r.width * 0.06, r.top + r.height * 0.8),
      Offset(r.left, r.top + r.height * 0.27),
    ];
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final p = pts[i];
      final prev = pts[(i - 1 + pts.length) % pts.length];
      final next = pts[(i + 1) % pts.length];
      final a = p + (prev - p) / (prev - p).distance * radius;
      final b = p + (next - p) / (next - p).distance * radius;
      if (i == 0) {
        path.moveTo(a.dx, a.dy);
      } else {
        path.lineTo(a.dx, a.dy);
      }
      path.quadraticBezierTo(p.dx, p.dy, b.dx, b.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final body = Rect.fromLTWH(8, 16, size.width - 16, size.height - 26);
    final outline = body.inflate(8);
    final shape = _hex(body, 26);
    canvas.drawPath(
      _hex(outline, 32),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      shape.shift(const Offset(0, 14)),
      Paint()
        ..color = Tone.violetDeep.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawPath(
      shape,
      Paint()
        ..shader = ui.Gradient.linear(
          body.topLeft,
          body.bottomRight,
          [Tone.mintHi, Tone.mint, const Color(0xFF7F8CFF), Tone.violet, Tone.violetDeep],
          [0, 0.22, 0.48, 0.72, 1],
        ),
    );
    canvas.save();
    canvas.clipPath(shape);
    final drift = 0.5 + 0.5 * math.sin(seconds * 0.7);
    final blob = Offset(body.left + body.width * (0.25 + 0.1 * drift), body.top + body.height * 0.3);
    canvas.drawCircle(
      blob,
      body.width * 0.55,
      Paint()..shader = ui.Gradient.radial(blob, body.width * 0.55, [Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0)], [0, 1]),
    );
    final band = body.left - body.width * 0.6 + shine * body.width * 2.2;
    if (shine > 0 && shine < 1) {
      canvas.drawRect(
        body,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(band - 40, body.top),
            Offset(band + 40, body.bottom),
            [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.45), Colors.white.withValues(alpha: 0)],
            [0, 0.5, 1],
          ),
      );
    }
    canvas.drawRect(
      Rect.fromLTRB(body.left, body.top + body.height * 0.62, body.right, body.bottom),
      Paint()..shader = ui.Gradient.linear(Offset(0, body.top + body.height * 0.62), body.bottomCenter, [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.22)], [0, 1]),
    );
    final rng = math.Random(5);
    for (var i = 0; i < 7; i++) {
      final p = Offset(body.left + rng.nextDouble() * body.width, body.top + rng.nextDouble() * body.height * 0.8);
      final tw = 0.5 + 0.5 * math.sin(seconds * 3 + i * 1.7);
      canvas.drawCircle(p, 1.2 + tw, Paint()..color = Colors.white.withValues(alpha: 0.5 * tw));
    }
    canvas.restore();
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = ui.Gradient.linear(body.topCenter, body.bottomCenter, [Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0.05)], [0, 1]),
    );
  }

  @override
  bool shouldRepaint(HexBadgePainter old) => old.seconds != seconds || old.shine != shine;
}

class LaurelPainter extends CustomPainter {
  LaurelPainter({required this.grow, required this.sway});

  final double grow;
  final double sway;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.42);
    const rx = 150.0;
    const ry = 135.0;
    const leaves = 9;
    for (final side in [-1.0, 1.0]) {
      for (var i = 0; i < leaves; i++) {
        final k = i / (leaves - 1);
        final appear = ((grow * (leaves + 2) - i) / 2).clamp(0.0, 1.0);
        if (appear <= 0) continue;
        final a = math.pi / 2 + side * (0.45 + k * 1.75);
        final p = c + Offset(math.cos(a) * rx, math.sin(a) * ry);
        final tangent = a + side * math.pi / 2;
        for (final outward in [1.0, -1.0]) {
          canvas.save();
          canvas.translate(p.dx, p.dy);
          canvas.rotate(tangent + outward * 0.55 * side + 0.03 * math.sin(sway * 1.3 + i));
          final len = (30 - k * 8) * appear;
          final leaf = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(len * 0.5, -len * 0.5 * outward, len, 0)
            ..quadraticBezierTo(len * 0.5, len * 0.18 * outward, 0, 0)
            ..close();
          canvas.drawPath(leaf, Paint()..color = const Color(0xFF8E80E0).withValues(alpha: 0.3 * appear));
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(LaurelPainter old) => old.grow != grow || old.sway != sway;
}
