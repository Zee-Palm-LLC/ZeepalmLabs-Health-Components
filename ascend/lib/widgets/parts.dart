import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';

class Glow extends StatelessWidget {
  const Glow({super.key, required this.center, required this.color, required this.radius, this.strength = 1});

  final Offset center;
  final Color color;
  final double radius;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _GlowPainter(center, color, radius, strength), size: Size.infinite),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.center, this.color, this.radius, this.strength);

  final Offset center;
  final Color color;
  final double radius;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    final a = color.a * strength.clamp(0.0, 1.0);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [color.withValues(alpha: a), color.withValues(alpha: a * 0.45), color.withValues(alpha: 0)],
          [0, 0.45, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.center != center || old.strength != strength || old.radius != radius || old.color != color;
}

class Motes extends StatelessWidget {
  const Motes({super.key, required this.area, this.count = 14, this.seed = 3, this.opacity = 1});

  final Rect area;
  final int count;
  final int seed;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(builder: (context, t, _) => CustomPaint(painter: _MotePainter(area, count, seed, t, opacity), size: Size.infinite)),
    );
  }
}

class _MotePainter extends CustomPainter {
  _MotePainter(this.area, this.count, this.seed, this.t, this.opacity);

  final Rect area;
  final int count;
  final int seed;
  final double t;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final rng = math.Random(seed);
    for (var i = 0; i < count; i++) {
      final x = area.left + rng.nextDouble() * area.width;
      final y = area.top + rng.nextDouble() * area.height;
      final r = 0.9 + rng.nextDouble() * 1.5;
      final speed = 3 + rng.nextDouble() * 6;
      final phase = rng.nextDouble() * math.pi * 2;
      final period = 2.4 + rng.nextDouble() * 3;
      final dy = -((t * speed) % 26) + 13;
      final dx = 4 * math.sin(t / period * math.pi * 2 + phase);
      final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 2.2 + phase));
      final fade = 1 - (dy.abs() / 13).clamp(0.0, 1.0) * 0.6;
      canvas.drawCircle(
        Offset(x + dx, y + dy),
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.85 * twinkle * fade * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_MotePainter old) => old.t != t || old.opacity != opacity;
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 21.7});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _MarkPainter());
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final hex = Path();
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + i * math.pi / 3;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? hex.moveTo(p.dx, p.dy) : hex.lineTo(p.dx, p.dy);
    }
    hex.close();
    canvas.drawPath(hex, Paint()
      ..color = Tone.white
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(hex, Paint()
      ..color = Tone.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.28
      ..strokeJoin = StrokeJoin.round);
    final chevron = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = r * 0.42;
    for (final (dy, alpha) in [(-0.16, 1.0), (0.22, 0.45)]) {
      final y = c.dy + dy * r * 1.6;
      chevron.color = Tone.violetDeep.withValues(alpha: alpha);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - w, y + w * 0.55)
          ..lineTo(c.dx, y - w * 0.15)
          ..lineTo(c.dx + w, y + w * 0.55),
        chevron,
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => false;
}

class Header extends StatelessWidget {
  const Header({super.key, required this.top, required this.back, required this.onBack});

  final double top;
  final double back;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: top + 60,
      child: Stack(
        children: [
          Positioned(left: 156.3, top: top + 103.5 - 62 - 10.85, child: const BrandMark()),
          Positioned(left: 187.3, top: top + 109.7 - 62 - 15.8 * interAscent, child: Line('Ascend', style: Typo.brand)),
          Positioned(
            left: 14,
            top: top + 104.5 - 62 - 22,
            child: IgnorePointer(
              ignoring: back < 0.5,
              child: Opacity(
                opacity: back.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(-14 * (1 - back), 0),
                  child: Pressable(
                    onTap: onBack,
                    scale: 0.92,
                    child: SizedBox(
                      width: 84,
                      height: 44,
                      child: Stack(
                        children: [
                          const Positioned(left: 12, top: 22 - 10, child: PhIcon(Ph.arrowLeft, size: 20)),
                          Positioned(left: 35, top: 28.2 - 16.6 * interAscent, child: Line('Back', style: Typo.back)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.t, required this.child, this.rise = 14, this.blur = 8});

  final double t;
  final double rise;
  final double blur;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    final sigma = blur * (1 - e);
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, rise * (1 - e)),
        child: ImageFiltered(
          enabled: sigma > 0.05,
          imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: child,
        ),
      ),
    );
  }
}

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.index, required this.t});

  final int index;
  final double t;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: SizedBox(
        width: 40,
        height: 22,
        child: Stack(
          children: [
            for (var i = 0; i < 2; i++)
              Positioned(
                left: 13 + i * 10.5,
                top: i == index ? 0 : 5,
                child: Container(
                  width: 4,
                  height: i == index ? 22 : 12,
                  decoration: BoxDecoration(
                    color: i == index ? Tone.white : const Color(0xFF5A5A62),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SolidButton extends StatelessWidget {
  const SolidButton({super.key, required this.label, required this.t, required this.onTap, this.width = 274, this.height = 55, this.leading});

  final String label;
  final double t;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final lit = span(t, 0.25, 1, Curves.easeOut);
    final fill = Color.lerp(const Color(0xFF3A3A40), Colors.white, lit)!;
    return Opacity(
      opacity: span(t, 0, 0.35, Curves.linear),
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - Curves.easeOutCubic.transform(t.clamp(0.0, 1.0)))),
        child: Pressable(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          scale: 0.95,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.12 * lit), blurRadius: 24, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 9)],
                Opacity(opacity: lit, child: Line(label, style: Typo.button)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.t, required this.onTap, required this.leading, this.width = 285, this.height = 55});

  final String label;
  final double t;
  final VoidCallback onTap;
  final Widget leading;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: span(t, 0, 0.5, Curves.linear),
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - Curves.easeOutCubic.transform(t.clamp(0.0, 1.0)))),
        child: Pressable(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          scale: 0.95,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF202024),
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(color: const Color(0x14FFFFFF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [leading, const SizedBox(width: 9), Line(label, style: Typo.buttonLight)],
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _GPainter());
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = size.center(Offset.zero);
    final stroke = s * 0.2;
    final rect = Rect.fromCircle(center: c, radius: s / 2 - stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    const deg = math.pi / 180;
    p.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -150 * deg, 110 * deg, false, p);
    p.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 145 * deg, 70 * deg, false, p);
    p.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 40 * deg, 105 * deg, false, p);
    p.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -8 * deg, 48 * deg, false, p);
    canvas.drawRect(Rect.fromLTWH(c.dx, c.dy - stroke / 2, s / 2 - stroke * 0.1, stroke), Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(_GPainter old) => false;
}
