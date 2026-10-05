import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/parts.dart';

class Column3 {
  const Column3({required this.left, required this.width, required this.top, required this.rank, required this.color, required this.hi, required this.rise});

  final double left;
  final double width;
  final double top;
  final int rank;
  final Color color;
  final Color hi;
  final double rise;
}

class CrewHero extends StatelessWidget {
  const CrewHero({super.key, required this.t});

  final double t;

  static const floor = 545.0;

  @override
  Widget build(BuildContext context) {
    final cols = [
      Column3(left: 34.6, width: 100.4, top: 345.3, rank: 2, color: Tone.mint, hi: Tone.mintHi, rise: span(t, 0.1, 0.36, Curves.linear)),
      Column3(left: 150, width: 100, top: 303.8, rank: 1, color: Tone.violet, hi: Tone.violetHi, rise: span(t, 0.2, 0.46, Curves.linear)),
      Column3(left: 265.5, width: 100.4, top: 371.5, rank: 3, color: Tone.amber, hi: Tone.amberHi, rise: span(t, 0.04, 0.3, Curves.linear)),
    ];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: Glow(center: const Offset(200, 330), color: Tone.violet.withValues(alpha: 0.55), radius: 200, strength: span(t, 0, 0.35))),
        Positioned.fill(child: Motes(area: const Rect.fromLTRB(20, 180, 390, 470), count: 12, seed: 23, opacity: span(t, 0.3, 0.6))),
        Positioned.fill(
          child: Tick(builder: (context, s, _) => CustomPaint(painter: PodiumPainter(cols: cols, seconds: s, chevrons: span(t, 0.45, 0.65, Curves.linear)))),
        ),
        _avatar(t: span(t, 0.36, 0.58, Curves.linear), center: const Offset(84.2, 265.8), radius: 39.6, ring: Tone.mint, art: Art.maya, name: 'Maya', tagCenter: const Offset(85.5, 308.3)),
        _avatar(t: span(t, 0.28, 0.5, Curves.linear), center: const Offset(315, 301.3), radius: 39.6, ring: Tone.amber, art: Art.leo, name: 'Leo', tagCenter: const Offset(316.3, 342.9)),
        _avatar(t: span(t, 0.44, 0.66, Curves.linear), center: const Offset(200.4, 227.5), radius: 36.7, ring: Tone.violet, art: Art.you, name: 'You', tagCenter: const Offset(199.8, 271.5), halo: true),
      ],
    );
  }

  Widget _avatar({required double t, required Offset center, required double radius, required Color ring, required String art, required String name, required Offset tagCenter, bool halo = false}) {
    final s = spring(t, bounce: 0.38, freq: 2);
    final tag = span(t, 0.45, 1, Curves.linear);
    return Positioned(
      left: center.dx - 60,
      top: center.dy - 70,
      width: 120,
      height: 140 + (tagCenter.dy - center.dy),
      child: Opacity(
        opacity: span(t, 0, 0.25, Curves.linear),
        child: Transform.translate(
          offset: Offset(0, -70 * (1 - s)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (halo)
                Positioned(
                  left: 60 - 54,
                  top: 70 - 54,
                  child: Tick(
                    builder: (context, sec, _) => Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Tone.violet.withValues(alpha: 0.14 + 0.08 * math.sin(sec * 2)), width: 1.2),
                        gradient: RadialGradient(colors: [Tone.violet.withValues(alpha: 0.18), Tone.violet.withValues(alpha: 0)]),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 60 - radius,
                top: 70 - radius,
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ring, width: halo ? 4 : 3.5),
                    gradient: RadialGradient(center: const Alignment(0, -0.3), colors: [Color.lerp(ring, Colors.white, 0.55)!, Color.lerp(ring, Colors.black, 0.35)!]),
                    boxShadow: [BoxShadow(color: ring.withValues(alpha: 0.35), blurRadius: 18)],
                  ),
                  child: ClipOval(
                    child: Transform.translate(
                      offset: Offset(0, radius * 0.18),
                      child: Image.asset(art, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 70 + (tagCenter.dy - center.dy) - 10,
                child: Center(
                  child: Transform.scale(
                    scale: spring(tag, bounce: 0.5, freq: 2.4),
                    child: Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(color: ring, borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [Line(name, style: Typo.tag.copyWith(color: ring == Tone.mint ? const Color(0xFF07291C) : Colors.white))]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PodiumPainter extends CustomPainter {
  PodiumPainter({required this.cols, required this.seconds, required this.chevrons});

  final List<Column3> cols;
  final double seconds;
  final double chevrons;

  @override
  void paint(Canvas canvas, Size size) {
    const floor = CrewHero.floor;
    for (final col in cols) {
      if (col.rise <= 0) continue;
      final e = spring(col.rise, bounce: 0.2, freq: 1.6);
      final top = floor - (floor - col.top) * e;
      final rx = col.width / 2;
      const ry = 12.0;
      final body = Rect.fromLTRB(col.left, top, col.left + col.width, floor + 40);
      final fade = span(col.rise, 0, 0.3, Curves.linear);
      canvas.drawRect(
        body,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, top),
            const Offset(0, floor + 20),
            [col.color.withValues(alpha: 0.95 * fade), col.color.withValues(alpha: 0.55 * fade), col.color.withValues(alpha: 0)],
            [0, 0.5, 1],
          ),
      );
      canvas.save();
      canvas.clipRect(body);
      canvas.drawRect(
        body,
        Paint()
          ..shader = ui.Gradient.linear(
            body.centerLeft,
            body.centerRight,
            [Colors.white.withValues(alpha: 0.18 * fade), Colors.white.withValues(alpha: 0), Colors.black.withValues(alpha: 0.18 * fade)],
            [0, 0.45, 1],
          ),
      );
      canvas.restore();
      final cap = Rect.fromCenter(center: Offset(col.left + rx, top), width: col.width, height: ry * 2);
      canvas.drawOval(cap, Paint()..color = Color.lerp(col.color, Colors.black, 0.25)!.withValues(alpha: fade));
      canvas.drawOval(
        cap.deflate(1),
        Paint()
          ..shader = ui.Gradient.linear(cap.topCenter, cap.bottomCenter, [col.hi.withValues(alpha: 0.9 * fade), col.color.withValues(alpha: 0.7 * fade)], [0, 1]),
      );
      final digit = TextPainter(text: TextSpan(text: '${col.rank}', style: Typo.podium.copyWith(fontSize: 29)), textDirection: TextDirection.ltr)..layout();
      final baseline = top + (col.rank == 1 ? 47 : 48);
      digit.paint(canvas, Offset(col.left + rx - digit.width / 2, baseline - 29 * interAscent));
      if (col.rank == 1 && chevrons > 0) {
        for (var i = 0; i < 2; i++) {
          final phase = ((seconds * 0.9 + i * 0.5) % 1.0);
          final y = top + 108 - phase * 30 + i * 0;
          final alpha = math.sin(phase * math.pi) * chevrons;
          final w = 22.0;
          final path = Path()
            ..moveTo(col.left + rx - w, y + w * 0.7)
            ..lineTo(col.left + rx, y)
            ..lineTo(col.left + rx + w, y + w * 0.7);
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 9
              ..strokeCap = StrokeCap.square
              ..strokeJoin = StrokeJoin.miter
              ..color = Colors.white.withValues(alpha: 0.8 * alpha),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(PodiumPainter old) => true;
}

class Socials extends StatelessWidget {
  const Socials({super.key, required this.apple, required this.google, required this.login, required this.onApple, required this.onGoogle, required this.onLogin});

  final double apple;
  final double google;
  final double login;
  final VoidCallback onApple;
  final VoidCallback onGoogle;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 402,
      height: 170,
      child: Stack(
        children: [
          Positioned(
            left: 60,
            top: 0,
            child: SolidButton(
              label: 'Continue with Apple',
              t: apple,
              width: 285,
              onTap: onApple,
              leading: Opacity(opacity: span(apple, 0.25, 1), child: const PhIcon(Ph.apple, size: 19, color: Color(0xFF0A0A0A))),
            ),
          ),
          Positioned(left: 60, top: 67.2, child: GhostButton(label: 'Continue with Google', t: google, onTap: onGoogle, leading: const GoogleMark(size: 18))),
          Positioned(
            left: 0,
            right: 0,
            top: 155.3 - 15 * interAscent,
            child: Opacity(
              opacity: login,
              child: Center(
                child: GestureDetector(
                  onTap: onLogin,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Already climbing? ', style: Typo.login),
                        TextSpan(text: 'Log in', style: Typo.login.copyWith(color: Tone.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
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
