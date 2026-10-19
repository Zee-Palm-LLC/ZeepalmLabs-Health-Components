import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/style.dart';

class Sparkles extends StatelessWidget {
  const Sparkles({super.key, required this.area, this.count = 16, this.seed = 1, this.color = const Color(0xFFFFF4C8), this.opacity = 1, this.big = 0.25});

  final Rect area;
  final int count;
  final int seed;
  final Color color;
  final double opacity;
  final double big;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(builder: (context, t, _) => CustomPaint(painter: _SparklePainter(area, count, seed, t, color, opacity, big), size: Size.infinite)),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.area, this.count, this.seed, this.t, this.color, this.opacity, this.big);

  final Rect area;
  final int count;
  final int seed;
  final double t;
  final Color color;
  final double opacity;
  final double big;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final rng = math.Random(seed);
    for (var i = 0; i < count; i++) {
      final p = Offset(area.left + rng.nextDouble() * area.width, area.top + rng.nextDouble() * area.height);
      final phase = rng.nextDouble();
      final period = 1.6 + rng.nextDouble() * 2.4;
      final star = rng.nextDouble() < big;
      final s = 0.5 + 0.5 * math.sin((t / period + phase) * math.pi * 2);
      final a = opacity * (0.25 + 0.75 * s);
      if (star) {
        final r = (3.5 + rng.nextDouble() * 3.5) * (0.7 + 0.3 * s);
        _star(canvas, p, r, color.withValues(alpha: a));
      } else {
        canvas.drawCircle(p, 0.8 + rng.nextDouble() * 1.4, Paint()..color = color.withValues(alpha: a * 0.9));
      }
    }
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final glow = Paint()
      ..color = color.withValues(alpha: color.a * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(c, r * 0.6, glow);
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t || old.opacity != opacity;
}

class Float extends StatelessWidget {
  const Float({super.key, required this.child, this.dy = 4, this.period = 3.2, this.phase = 0, this.tilt = 0, this.dx = 0});

  final Widget child;
  final double dy;
  final double dx;
  final double period;
  final double phase;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, t, child) {
        final s = wave(t, period, phase);
        final c = wave(t, period * 1.3, phase);
        return Transform.translate(
          offset: Offset(dx * c, dy * s),
          child: Transform.rotate(angle: tilt * c, child: child),
        );
      },
      child: child,
    );
  }
}

class GlassPill extends StatelessWidget {
  const GlassPill({super.key, required this.width, required this.height, this.rim = const Color(0x66FFFFFF), this.fill, this.child, this.radius});

  final double width;
  final double height;
  final Color rim;
  final Gradient? fill;
  final double? radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? height / 2;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r),
              gradient: fill ??
                  const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xE6332E86), Color(0xF2241F69)],
                  ),
              border: Border.all(color: rim, width: 1.6),
              boxShadow: const [BoxShadow(color: Color(0x40140F45), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  const GoldButton({super.key, required this.width, required this.height, required this.label, required this.onTap, this.size = 23, this.leading});

  final double width;
  final double height;
  final String label;
  final double size;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.95,
      child: SizedBox(
        width: width,
        height: height + 6,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 6,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFE08A12),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: const [BoxShadow(color: Color(0x55B0430A), blurRadius: 16, offset: Offset(0, 6))],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFE27A), Color(0xFFFFC93A), Color(0xFFFFB424)],
                    stops: [0, 0.55, 1],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(height / 2),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 14,
                        right: 14,
                        top: 3,
                        height: height * 0.36,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(height),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0)],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(child: _Shine()),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (leading != null) ...[leading!, const SizedBox(width: 10)],
                            Label(label, style: baloo(size, weight: 700, color: Tone.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, t, _) {
        final p = (t % 4.0) / 1.2;
        if (p >= 1) return const SizedBox.expand();
        final x = -1.8 + p * 3.6;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(x - 0.3, -1),
              end: Alignment(x + 0.3, 1),
              colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0)],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.t, required this.style, this.grouped = true, this.suffix = ''});

  final int value;
  final double t;
  final TextStyle style;
  final bool grouped;
  final String suffix;

  static String group(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final v = (value * Curves.easeOutCubic.transform(t.clamp(0.0, 1.0))).round();
    return Label('${grouped ? group(v) : '$v'}$suffix', style: style);
  }
}

class Burst extends StatelessWidget {
  const Burst({super.key, required this.t, required this.center, this.color = Tone.goldHi, this.count = 18, this.radius = 90, this.seed = 2});

  final double t;
  final Offset center;
  final Color color;
  final int count;
  final double radius;
  final int seed;

  @override
  Widget build(BuildContext context) {
    if (t <= 0 || t >= 1) return const SizedBox.shrink();
    return IgnorePointer(child: CustomPaint(painter: _BurstPainter(t, center, color, count, radius, seed), size: Size.infinite));
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t, this.center, this.color, this.count, this.radius, this.seed);

  final double t;
  final Offset center;
  final Color color;
  final int count;
  final double radius;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final e = Curves.easeOutCubic.transform(t);
    final fade = 1 - Curves.easeIn.transform(t);
    canvas.drawCircle(
      center,
      radius * 0.6 * e,
      Paint()
        ..color = color.withValues(alpha: 0.35 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    for (var i = 0; i < count; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final d = radius * (0.5 + rng.nextDouble() * 0.6) * e;
      final p = center + Offset(math.cos(a), math.sin(a)) * d + Offset(0, 30 * t * t);
      final r = (2 + rng.nextDouble() * 3.5) * (1 - t * 0.6);
      canvas.drawCircle(p, r, Paint()..color = color.withValues(alpha: fade));
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
