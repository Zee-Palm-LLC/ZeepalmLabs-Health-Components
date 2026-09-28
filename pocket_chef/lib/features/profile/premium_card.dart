import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key, required this.entrance});

  static const rect = Rect.fromLTRB(17.8, 412.7, 377.3, 498.3);

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    const r = rect;
    final title = inter(15.4, 700, color: Colors.white);
    final body = inter(12.9, 400, color: const Color(0xFFE6DEEF));
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final t = span(entrance.value, 0.42, 0.78, gentle);
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..translateByDouble(80 * (1 - t), 0, 0, 1)
          ..rotateY(-0.7 * (1 - t));
        return Opacity(
          opacity: span(entrance.value, 0.42, 0.56, Curves.linear),
          child: Transform(alignment: Alignment.centerRight, transform: m, child: child),
        );
      },
      child: Pressable(
        scale: 0.98,
        onTap: () {},
        child: Container(
          width: r.width,
          height: r.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [BoxShadow(color: Color(0x33251836), blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF15121F), Color(0xFF231733), Color(0xFF2A1937)],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: -30,
                  top: -40,
                  width: 180,
                  height: 160,
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: RadialGradient(colors: [Color(0x224A2A66), Color(0x004A2A66)])),
                  ),
                ),
                Positioned.fill(
                  child: Tick(builder: (context, s, _) => CustomPaint(painter: _Sheen(s))),
                ),
                Positioned(
                  left: Art.profCrown.left - r.left,
                  top: Art.profCrown.top - r.top,
                  width: Art.profCrown.width,
                  height: Art.profCrown.height,
                  child: _Coin(entrance: entrance),
                ),
                Positioned(
                  left: 108.33 - r.left - bearing('P', title),
                  top: 442.33 - r.top - 100,
                  child: Baseline(
                    baseline: 100,
                    baselineType: TextBaseline.alphabetic,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (b) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF7E9A8), Color(0xFFE6CF7C)],
                      ).createShader(b),
                      child: Text('Premium Chef', style: title),
                    ),
                  ),
                ),
                Pin(x: 108.0 - r.left, base: 463.0 - r.top, text: 'Unlock more recipes, features', style: body),
                Pin(x: 108.0 - r.left, base: 481.0 - r.top, text: 'and exclusive content!', style: body),
                Positioned(
                  left: 345.25 - r.left - 17.5,
                  top: 457.15 - r.top - 17.5,
                  child: Tick(
                    builder: (context, s, child) {
                      final k = math.pow((math.sin(s * math.pi * 2 / 1.8) + 1) / 2, 3).toDouble();
                      return Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(const Color(0x1FFFFFFF), const Color(0x2EFFFFFF), k),
                        ),
                        child: Center(
                          child: Transform.translate(offset: Offset(2.4 * k, 0), child: child),
                        ),
                      );
                    },
                    child: const PhIcon(Ph.arrowRight, size: 22, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final t = span(entrance.value, 0.55, 0.95, Curves.easeOutCubic);
        return Tick(
          builder: (context, s, _) {
            final u = (s % 6) / 6;
            final flip = u < 0.2 ? Curves.easeInOutCubic.transform(u / 0.2) : 0.0;
            final angle = math.pi * 2 * (1 - t) + math.pi * 2 * flip;
            final m = Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(angle);
            final glint = (math.cos(angle) + 1) / 2;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.52 + 0.05 * wave(s, 2.2),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [Color(0x33FFC94A), Color(0x00FFC94A)], stops: [0.6, 1.0]),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.2075,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFF6A5140), Color(0xFF634B39), Color(0xFF5C4430)],
                          stops: [0.75, 0.9, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: m,
                  child: Opacity(opacity: lerp(0.85, 1, glint), child: child),
                ),
                Positioned.fill(child: CustomPaint(painter: _Twinkle(s))),
              ],
            );
          },
        );
      },
      child: Art.profCrown.image(),
    );
  }
}

class _Twinkle extends CustomPainter {
  _Twinkle(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final spots = [const Offset(0.86, 0.14), const Offset(0.12, 0.8), const Offset(0.92, 0.72)];
    for (final (i, p) in spots.indexed) {
      final u = ((seconds + i * 0.9) % 2.7) / 2.7;
      final k = math.sin(u * math.pi);
      if (k <= 0) continue;
      final c = Offset(p.dx * size.width, p.dy * size.height);
      final r = 3.6 * k;
      final path = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r);
      canvas.drawPath(path, Paint()..color = const Color(0xFFFFF1B8).withValues(alpha: k));
    }
  }

  @override
  bool shouldRepaint(_Twinkle old) => old.seconds != seconds;
}

class _Sheen extends CustomPainter {
  _Sheen(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final t = (seconds % 5) / 1.4;
    if (t > 1) return;
    final x = lerp(-120, size.width + 60, Curves.easeInOutCubic.transform(t));
    final band = Rect.fromLTWH(x, -40, 60, size.height + 80);
    canvas.save();
    canvas.translate(band.center.dx, size.height / 2);
    canvas.rotate(0.38);
    canvas.translate(-band.center.dx, -size.height / 2);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0)],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(band),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Sheen old) => old.seconds != seconds;
}
