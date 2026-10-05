import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/parts.dart';

class LevelHero extends StatelessWidget {
  const LevelHero({super.key, required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final level = (24 * Curves.easeOutCubic.transform(span(t, 0.08, 0.55, Curves.linear))).round();
    final card = span(t, 0.12, 0.42, Curves.linear);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: Glow(center: const Offset(204, 330), color: Tone.violet.withValues(alpha: 0.42), radius: 230, strength: span(t, 0, 0.3))),
        Positioned.fill(child: Motes(area: const Rect.fromLTRB(20, 170, 390, 440), count: 12, opacity: span(t, 0.2, 0.5))),
        Positioned(
          left: 204 - 140,
          top: 298 - 140,
          width: 280,
          height: 280,
          child: Tick(
            builder: (context, s, _) => CustomPaint(painter: RingPainter(t: t, seconds: s)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 282.3 - 22.9 * interAscent,
          child: Opacity(opacity: span(t, 0.04, 0.2), child: Center(child: Line('LVL', style: Typo.lvl))),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 329.3 - 49.9 * interAscent,
          child: Opacity(
            opacity: span(t, 0.04, 0.2),
            child: Center(
              child: Transform.scale(
                scale: 1 + 0.08 * math.sin(span(t, 0.5, 0.62, Curves.linear) * math.pi),
                child: Line('$level', style: Typo.level),
              ),
            ),
          ),
        ),
        Positioned(left: 0, right: 0, top: 440, child: _Stack(t: t)),
        Positioned(
          left: 18,
          top: 349.5,
          child: _Fly(t: card, child: _HeroCard(check: span(t, 0.66, 0.82, Curves.linear), sheen: t)),
        ),
      ],
    );
  }
}

class _Fly extends StatelessWidget {
  const _Fly({required this.t, required this.child});

  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = spring(t, bounce: 0.28, freq: 1.7);
    final angle = lerp(-0.2, -0.0208, s);
    return Opacity(
      opacity: span(t, 0, 0.3, Curves.linear),
      child: Transform.translate(
        offset: Offset(lerp(-30, 0, s), lerp(110, 0, s)),
        child: Transform.rotate(angle: angle, child: Transform.scale(scale: lerp(0.86, 1, s), child: child)),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.check, required this.sheen});

  final double check;
  final double sheen;

  @override
  Widget build(BuildContext context) {
    const w = 366.0;
    const h = 84.0;
    return SizedBox(
      width: w,
      height: h + 5,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 5,
            width: w,
            height: h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Tone.violetDeep,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Tone.violet.withValues(alpha: 0.45), blurRadius: 34, offset: const Offset(0, 10)),
                  const BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 6)),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: w,
            height: h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF9C82FF), Color(0xFF8061F8)],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(child: _Sheen(t: sheen)),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 1.4,
                    child: ColoredBox(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  Positioned(
                    left: 39 - 18.2,
                    top: 43.5 - 18.2,
                    child: Container(
                      width: 36.4,
                      height: 36.4,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4B33B8)),
                      alignment: Alignment.center,
                      child: Image.asset(Art.run, width: 22, height: 22, filterQuality: FilterQuality.medium),
                    ),
                  ),
                  Positioned(left: 72.7, top: 41.2 - 17.6 * interAscent, child: Line('Sunrise Run', style: Typo.cardTitle)),
                  Positioned(left: 73, top: 61.5 - 14.2 * interAscent, child: Line('30 min easy jog', style: Typo.cardSub)),
                  Positioned(right: w - 310.7, top: 46.5 - 17.3 * interAscent, child: Line('+150 XP', style: Typo.cardXp)),
                  Positioned(
                    left: 332.8 - 9.6,
                    top: 39.5 - 9.6,
                    child: Transform.scale(
                      scale: spring(check, bounce: 0.5, freq: 2.4),
                      child: Container(
                        width: 19.2,
                        height: 19.2,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        alignment: Alignment.center,
                        child: const PhIcon(Ph.check, size: 11.5, color: Color(0xFF2A1C78)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheen extends StatelessWidget {
  const _Sheen({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, _) {
        final first = span(t, 0.82, 1, Curves.linear);
        final loop = t >= 1 ? ((s % 4.2) / 1.1).clamp(0.0, 1.0) : 0.0;
        final p = t < 1 ? first : loop;
        if (p <= 0 || p >= 1) return const SizedBox.expand();
        final x = -1.6 + p * 3.2;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(x - 0.35, -1),
              end: Alignment(x + 0.35, 1),
              colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.28), Colors.white.withValues(alpha: 0)],
              stops: const [0, 0.5, 1],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final second = span(t, 0.24, 0.48, Curves.linear);
    final third = span(t, 0.32, 0.56, Curves.linear);
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (r) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xCCFFFFFF), Color(0x66FFFFFF), Color(0x00FFFFFF)],
        stops: [0, 0.55, 1],
      ).createShader(r),
      child: SizedBox(
        height: 124,
        child: Stack(
          children: [
            Positioned(
              left: 41.7,
              top: 4,
              child: Reveal(t: second, rise: 18, blur: 4, child: const _GhostCard(width: 319, height: 66, icon: Art.journal, title: 'Journal', sub: '10 min reflection', xp: '+120 XP')),
            ),
            Positioned(
              left: 62,
              top: 76,
              child: Reveal(t: third, rise: 18, blur: 4, child: const _GhostCard(width: 278, height: 46, icon: Art.water, title: 'Hydrate', sub: '', xp: '+80 XP', small: true)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostCard extends StatelessWidget {
  const _GhostCard({required this.width, required this.height, required this.icon, required this.title, required this.sub, required this.xp, this.small = false});

  final double width;
  final double height;
  final String icon;
  final String title;
  final String sub;
  final String xp;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final titleStyle = inter(small ? 13 : 14.6, 700, tracking: -0.3, color: const Color(0xFFB8B8C2));
    final subStyle = inter(12.4, 500, color: const Color(0xFF5E5E68));
    final xpStyle = inter(small ? 13 : 15, 700, tracking: -0.3, color: const Color(0xFF7A7A86));
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C24),
        borderRadius: BorderRadius.circular(small ? 18 : 22),
        border: Border.all(color: Tone.cardLine, width: 0.9),
      ),
      child: Stack(
        children: [
          Positioned(left: 26, top: height / 2 - 9, child: Image.asset(icon, width: 18, height: 18, filterQuality: FilterQuality.medium)),
          Positioned(left: 59.3, top: (small ? height / 2 + 5 : 27.5) - titleStyle.fontSize! * interAscent, child: Line(title, style: titleStyle)),
          if (sub.isNotEmpty) Positioned(left: 59.3, top: 46 - 12.4 * interAscent, child: Line(sub, style: subStyle)),
          Positioned(right: width - (small ? 232 : 273.3), top: height / 2 + 5 - xpStyle.fontSize! * interAscent, child: Line(xp, style: xpStyle)),
          Positioned(
            left: (small ? 254 : 295.3) - 9,
            top: height / 2 - 9,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF4A4A54), width: 1.6)),
            ),
          ),
        ],
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  RingPainter({required this.t, required this.seconds});

  final double t;
  final double seconds;

  static const deg = math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const outer = 128.5;
    const inner = 84.5;
    const mid = (outer + inner) / 2;
    const width = outer - inner;
    final appear = span(t, 0, 0.18);
    final rect = Rect.fromCircle(center: c, radius: mid);

    canvas.drawCircle(
      c,
      outer - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Colors.white.withValues(alpha: 0.16 * appear),
    );
    canvas.drawCircle(
      c,
      inner,
      Paint()
        ..shader = ui.Gradient.radial(
          c + const Offset(0, 30),
          inner,
          [const Color(0xFF221C3A).withValues(alpha: appear), const Color(0xFF131218).withValues(alpha: appear)],
          [0, 1],
        ),
    );
    canvas.drawCircle(
      c,
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.07 * appear),
    );

    final left = Curves.easeOutCubic.transform(span(t, 0.1, 0.5, Curves.linear));
    if (left > 0) {
      const start = 125 * deg;
      final sweep = 71 * deg * left;
      _arc(canvas, rect, width, start, sweep, [Tone.mintDeep, Tone.mint, const Color(0xFF8FF0CC)], false);
    }
    final right = Curves.easeOutCubic.transform(span(t, 0.22, 0.62, Curves.linear));
    if (right > 0) {
      const end = 58 * deg;
      final sweep = 138 * deg * right;
      _arc(canvas, rect, width, end - sweep, sweep, [const Color(0xFFDCD2FF), Tone.violet, const Color(0xFF6D6699)], true);
      final pulse = 0.5 + 0.5 * math.sin(seconds * 2.4);
      final tip = c + Offset(math.cos(end - sweep), math.sin(end - sweep)) * mid;
      canvas.drawCircle(
        tip,
        width * 0.55,
        Paint()
          ..shader = ui.Gradient.radial(tip, width * 0.75, [Colors.white.withValues(alpha: 0.32 + 0.14 * pulse), Colors.white.withValues(alpha: 0)], [0, 1]),
      );
    }
  }

  void _arc(Canvas canvas, Rect rect, double width, double start, double sweep, List<Color> colors, bool headBright) {
    final c = rect.center;
    final path = Path()..addArc(rect, start, sweep);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 10
        ..strokeCap = StrokeCap.round
        ..color = colors[1].withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    final shader = SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: math.pi * 2,
      transform: GradientRotation(start - 0.15),
      colors: headBright ? [colors[0], colors[1], colors[2], colors[2]] : [colors[0], colors[1], colors[2], colors[2]],
      stops: [0, (sweep * 0.45 / (math.pi * 2)).clamp(0.01, 0.98), ((sweep + 0.3) / (math.pi * 2)).clamp(0.02, 0.99), 1],
    ).createShader(rect.inflate(width));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
    canvas.save();
    canvas.clipPath(
      Path()
        ..addPath(path, Offset.zero)
        ..fillType = PathFillType.nonZero,
    );
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.28
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    final edge = Path()..addArc(Rect.fromCircle(center: c, radius: rect.width / 2 + width / 2 - 3), start, sweep);
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(RingPainter old) => old.t != t || old.seconds != seconds;
}
