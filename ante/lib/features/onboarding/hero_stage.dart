import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/motion.dart';

class Flight {
  const Flight({
    required this.sprite,
    required this.from,
    required this.spin,
    required this.begin,
    required this.depth,
    this.bob = 4,
    this.period = 4,
    this.phase = 0,
    this.sway = 0.035,
    this.coin = false,
  });

  final Sprite sprite;
  final Offset from;
  final double spin;
  final double begin;
  final double depth;
  final double bob;
  final double period;
  final double phase;
  final double sway;
  final bool coin;
}

const flights = [
  Flight(sprite: Art.dumbbell, from: Offset(190, 40), spin: 0.9, begin: 0.2, depth: 1.25, bob: 3.2, period: 5.2, phase: 0.3),
  Flight(sprite: Art.ticket, from: Offset(-200, 50), spin: -0.8, begin: 0.16, depth: 1.35, bob: 3.6, period: 4.6, phase: 0.1, sway: 0.03),
  Flight(sprite: Art.coinTopRight, from: Offset(120, -160), spin: 0, begin: 0.34, depth: 1.9, bob: 5, period: 3.4, phase: 0.6, coin: true),
  Flight(sprite: Art.coinLeft, from: Offset(-150, -40), spin: 0, begin: 0.3, depth: 1.8, bob: 4.5, period: 3.9, phase: 0.2, coin: true),
  Flight(sprite: Art.coinLow, from: Offset(20, 200), spin: 0, begin: 0.38, depth: 1.6, bob: 3, period: 4.4, phase: 0.8, coin: true),
  Flight(sprite: Art.billTopLeft, from: Offset(-170, -120), spin: -1.4, begin: 0.26, depth: 1.7, bob: 5.5, period: 4.8, phase: 0.45, sway: 0.06),
  Flight(sprite: Art.billTopRight, from: Offset(170, -120), spin: 1.2, begin: 0.3, depth: 1.75, bob: 5, period: 5.4, phase: 0.7, sway: 0.06),
  Flight(sprite: Art.billLowLeft, from: Offset(-160, 160), spin: 1.1, begin: 0.36, depth: 1.55, bob: 4, period: 4.1, phase: 0.15, sway: 0.05),
  Flight(sprite: Art.billLowRight, from: Offset(170, 150), spin: -1.3, begin: 0.4, depth: 1.5, bob: 4.2, period: 5.0, phase: 0.55, sway: 0.05),
];

class HeroStage extends StatelessWidget {
  const HeroStage({super.key, required this.intro, required this.tilt});

  final Animation<double> intro;
  final ValueNotifier<Offset> tilt;

  static const trophyCenter = Offset(201, 206);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Tick(
              builder: (context, s, _) => AnimatedBuilder(
                animation: intro,
                builder: (context, _) => CustomPaint(
                  painter: _Aura(
                    seconds: s,
                    burst: span(intro.value, 0.1, 0.5, Curves.easeOut),
                    settle: span(intro.value, 0.2, 0.8, Curves.easeInOut),
                  ),
                ),
              ),
            ),
          ),
        ),
        _Trophy(intro: intro, tilt: tilt),
        for (final f in flights) _Flyer(flight: f, intro: intro, tilt: tilt),
        Positioned.fill(
          child: IgnorePointer(
            child: Tick(
              builder: (context, s, _) => AnimatedBuilder(
                animation: intro,
                builder: (context, _) => CustomPaint(
                  painter: _Sparkles(seconds: s, reveal: span(intro.value, 0.45, 0.9, Curves.easeOut)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Trophy extends StatelessWidget {
  const _Trophy({required this.intro, required this.tilt});

  final Animation<double> intro;
  final ValueNotifier<Offset> tilt;

  @override
  Widget build(BuildContext context) {
    const s = Art.trophy;
    return Positioned(
      left: s.left,
      top: s.top,
      width: s.width,
      height: s.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([intro, tilt]),
        builder: (context, child) {
          final t = intro.value;
          final rise = spring(span(t, 0.08, 0.62, Curves.linear), bounce: 0.25, freq: 2.6);
          final p = tilt.value;
          final m = Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..translateByDouble(p.dx * 6, 70 * (1 - rise) + p.dy * 6, 0, 1)
            ..rotateY(p.dx * 0.12)
            ..rotateX(-p.dy * 0.08)
            ..scaleByDouble(lerp(0.55, 1, rise), lerp(0.55, 1, rise), 1, 1);
          return Opacity(
            opacity: span(t, 0.08, 0.26, Curves.linear),
            child: Transform(alignment: const Alignment(0, 0.6), transform: m, child: child),
          );
        },
        child: Tick(
          builder: (context, sec, child) {
            final cycle = (sec % 4.2) / 1.3;
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (rect) {
                final x = lerp(-0.6, 1.6, cycle.clamp(0.0, 1.0));
                return LinearGradient(
                  begin: Alignment(-1 + x * 2 - 0.35, -1),
                  end: Alignment(-1 + x * 2 + 0.35, 1),
                  colors: cycle < 1
                      ? const [Color(0x00FFFFFF), Color(0x70FFF6DA), Color(0x00FFFFFF)]
                      : const [Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0x00FFFFFF)],
                  stops: const [0.35, 0.5, 0.65],
                ).createShader(rect);
              },
              child: child,
            );
          },
          child: s.image(),
        ),
      ),
    );
  }
}

class _Flyer extends StatelessWidget {
  const _Flyer({required this.flight, required this.intro, required this.tilt});

  final Flight flight;
  final Animation<double> intro;
  final ValueNotifier<Offset> tilt;

  @override
  Widget build(BuildContext context) {
    final s = flight.sprite;
    return Positioned(
      left: s.left,
      top: s.top,
      width: s.width,
      height: s.height,
      child: Tick(
        builder: (context, sec, child) => AnimatedBuilder(
          animation: Listenable.merge([intro, tilt]),
          builder: (context, child) {
            final raw = span(intro.value, flight.begin, flight.begin + 0.36, Curves.linear);
            final land = spring(raw, bounce: 0.3, freq: 2.2);
            final arc = math.sin(raw * math.pi) * 26;
            final rest = 1 - land;
            final idle = span(intro.value, flight.begin + 0.3, flight.begin + 0.5, Curves.easeInOut);
            final bob = (wave(sec, flight.period, flight.phase) - wave(0, flight.period, flight.phase)) * flight.bob * idle;
            final sway = (wave(sec, flight.period * 1.3, flight.phase + 0.25) - wave(0, flight.period * 1.3, flight.phase + 0.25)) * flight.sway * idle;
            final p = tilt.value * flight.depth;
            final m = Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..translateByDouble(flight.from.dx * rest + p.dx * 9, flight.from.dy * rest - arc * rest + bob + p.dy * 9, 0, 1)
              ..rotateZ(flight.spin * rest + sway);
            if (flight.coin) {
              final spin = raw < 1 ? (1 - raw) * math.pi * 4 : 0.0;
              final flick = math.max(0.0, wave(sec, 6.5, flight.phase));
              m.rotateY(spin + (flick > 0.985 ? (flick - 0.985) / 0.015 * math.pi * 2 : 0) * idle);
            }
            final grow = lerp(0.4, 1, land);
            m.scaleByDouble(grow, grow, 1, 1);
            return Opacity(
              opacity: span(intro.value, flight.begin, flight.begin + 0.08, Curves.linear),
              child: Transform(alignment: Alignment.center, transform: m, child: child),
            );
          },
          child: child,
        ),
        child: s.image(),
      ),
    );
  }
}

class _Aura extends CustomPainter {
  _Aura({required this.seconds, required this.burst, required this.settle});

  final double seconds;
  final double burst;
  final double settle;

  @override
  void paint(Canvas canvas, Size size) {
    const c = HeroStage.trophyCenter;
    final breathe = 0.5 + 0.5 * wave(seconds, 3.6);
    final glowR = 120.0 + 14 * breathe;
    final glow = Paint()
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 170, 70, 0.08 * settle + 0.05 * breathe * settle),
          Color.fromRGBO(200, 80, 160, 0.04 * settle),
          const Color(0x00000000),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: glowR));
    canvas.drawCircle(c, glowR, glow);

    final rays = Paint()..blendMode = BlendMode.plus;
    const count = 14;
    final rot = seconds * 0.12;
    for (var i = 0; i < count; i++) {
      final a = rot + i * math.pi * 2 / count;
      final len = 150 + 30 * math.sin(i * 1.7 + seconds * 0.8);
      final w = 0.075 + 0.02 * math.sin(i * 2.3);
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - w) * len, c.dy + math.sin(a - w) * len)
        ..lineTo(c.dx + math.cos(a + w) * len, c.dy + math.sin(a + w) * len)
        ..close();
      rays.shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 214, 140, 0.045 * settle),
          const Color(0x00000000),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: len));
      canvas.drawPath(path, rays);
    }

    if (burst > 0 && burst < 1) {
      final r = 30 + 230 * burst;
      final ring = Paint()
        ..blendMode = BlendMode.plus
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18 * (1 - burst) + 1
        ..color = Color.fromRGBO(255, 205, 130, 0.5 * (1 - burst))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(c, r, ring);
      final flash = Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [Color.fromRGBO(255, 230, 180, 0.55 * (1 - burst)), const Color(0x00000000)],
        ).createShader(Rect.fromCircle(center: c, radius: 170));
      canvas.drawCircle(c, 170, flash);
    }
  }

  @override
  bool shouldRepaint(_Aura old) => old.seconds != seconds || old.burst != burst || old.settle != settle;
}

class _Sparkles extends CustomPainter {
  _Sparkles({required this.seconds, required this.reveal});

  final double seconds;
  final double reveal;

  static const spots = [
    Offset(150, 118), Offset(262, 112), Offset(118, 176), Offset(290, 228),
    Offset(96, 262), Offset(244, 290), Offset(176, 104), Offset(330, 190),
    Offset(70, 150), Offset(210, 372), Offset(140, 300), Offset(318, 290),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (reveal <= 0) return;
    final p = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < spots.length; i++) {
      final tw = math.max(0.0, math.sin(seconds * (1.6 + i * 0.13) + i * 2.1));
      final a = tw * tw * reveal;
      if (a < 0.02) continue;
      final r = 2.2 + 3.2 * tw + (i % 3);
      final c = spots[i] + Offset(0, -4 * math.sin(seconds * 0.5 + i));
      p.color = Color.fromRGBO(255, 236, 190, 0.85 * a);
      final path = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
        ..close();
      canvas.drawPath(path, p);
      p.color = Color.fromRGBO(255, 200, 120, 0.35 * a);
      canvas.drawCircle(c, r * 0.9, p..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      p.maskFilter = null;
    }
  }

  @override
  bool shouldRepaint(_Sparkles old) => old.seconds != seconds || old.reveal != reveal;
}
