import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:streak_rpg/core/glyphs.dart';
import 'package:streak_rpg/core/motion.dart';
import 'package:streak_rpg/core/style.dart';

/// A finger on the phone: a dot that presses in and a ring that ripples out.
class Touch {
  Touch({required this.start, required this.end, required this.at});

  final double start;
  final double end;

  /// App-space point.
  final Offset at;
}

class Caption {
  const Caption(this.start, this.end, this.tag, this.lead, this.punch);

  final double start;
  final double end;
  final String tag;
  final String lead;
  final String punch;
}

/// A camera keyframe: at [t] the phone is zoomed by [zoom] around app-space y [focus].
class Shot {
  const Shot(this.t, this.zoom, this.focus);

  final double t;
  final double zoom;
  final double focus;
}

/// Eases between shots; holds the last one.
(double, double) cameraAt(List<Shot> shots, double t) {
  if (shots.isEmpty) return (1, 437);
  if (t <= shots.first.t) return (shots.first.zoom, shots.first.focus);
  for (var i = 0; i < shots.length - 1; i++) {
    final a = shots[i];
    final b = shots[i + 1];
    if (t < b.t) {
      final k = Curves.easeInOutCubic.transform(((t - a.t) / (b.t - a.t)).clamp(0.0, 1.0));
      return (lerp(a.zoom, b.zoom, k), lerp(a.focus, b.focus, k));
    }
  }
  return (shots.last.zoom, shots.last.focus);
}

class Lockup {
  const Lockup({required this.tagline, required this.sub});

  final String tagline;
  final String sub;
}

/// 1080 x 1920 social stage: a magic backdrop with drifting loot, the app in a
/// phone, kinetic captions above it, and a logo lockup when the phone flies off.
class ReelStage extends StatelessWidget {
  const ReelStage({super.key, required this.time, required this.touches, required this.captions, required this.app, required this.outroAt, required this.lockup, this.shots = const []});

  static const size = Size(1080, 1920);
  static const screen = Size(402, 874);
  static const bezel = 11.0;
  static const scale = 1.5;
  static const phoneTop = 334.0;

  static Offset get screenOrigin => Offset((size.width - screen.width * scale) / 2, phoneTop + bezel * scale);

  static Offset toStage(Offset app) => screenOrigin + app * scale;

  static Offset toApp(Offset stage) => (stage - screenOrigin) / scale;

  final ValueListenable<double> time;
  final List<Touch> touches;
  final List<Caption> captions;
  final Widget app;
  final double outroAt;
  final Lockup lockup;
  final List<Shot> shots;

  @override
  Widget build(BuildContext context) {
    final phone = _Phone(time: time, touches: touches, child: app);
    return ValueListenableBuilder<double>(
      valueListenable: time,
      child: phone,
      builder: (context, t, phone) {
        final rise = spring(((t - 0.05) / 1.1).clamp(0.0, 1.0), bounce: 0.3, freq: 2);
        final outro = Curves.easeInOutCubic.transform(((t - outroAt) / 0.9).clamp(0.0, 1.0));
        final outer = Size((screen.width + bezel * 2) * scale, (screen.height + bezel * 2) * scale);
        return SizedBox.fromSize(
          size: size,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(child: CustomPaint(painter: _Backdrop(t))),
              ..._decor(t, outro),
              // The camera: zoom around the focus and bring it toward the frame's centre,
              // cropped below the captions so the punch-in reads as a close-up.
              Positioned.fill(
                top: 300,
                child: ClipRect(
                  child: Builder(
                    builder: (context) {
                      final (zoom, focusY) = cameraAt(shots, t);
                      final focus = toStage(Offset(screen.width / 2, focusY)) - const Offset(0, 300);
                      const target = Offset(540, 800);
                      final k = ((zoom - 1) / 0.45).clamp(0.0, 1.0);
                      final shift = (target - focus) * k;
                      final m = Matrix4.identity()
                        ..translateByDouble(focus.dx + shift.dx, focus.dy + shift.dy, 0, 1)
                        ..scaleByDouble(zoom, zoom, 1, 1)
                        ..translateByDouble(-focus.dx, -focus.dy, 0, 1);
                      return Transform(
                        transform: m,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: (size.width - outer.width) / 2,
                              top: phoneTop - 300,
                              width: outer.width,
                              height: outer.height,
                              child: Transform.translate(
                                offset: Offset(0, 420 * (1 - rise) + 2000 * outro),
                                child: Transform.rotate(
                                  angle: -0.08 * outro,
                                  child: Transform.scale(
                                    scale: lerp(0.86, 1, rise),
                                    alignment: Alignment.topCenter,
                                    child: Opacity(opacity: rise.clamp(0.0, 1.0), child: phone),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              for (final c in captions) _CaptionView(caption: c, t: t),
              _Wordmark(t: t, outro: outro),
              _LockupView(t: t, at: outroAt + 0.35, lockup: lockup),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _decor(double t, double outro) {
    final items = [
      (Art.gift, const Offset(104, 560), 132.0, 0.0),
      (Art.fire, const Offset(990, 500), 112.0, 0.3),
      (Art.shieldGold, const Offset(84, 1180), 120.0, 0.55),
      (Art.chestSmall, const Offset(992, 1330), 136.0, 0.8),
      (Art.iconStar, const Offset(992, 900), 100.0, 0.2),
      (Art.shieldPurple, const Offset(112, 1640), 108.0, 0.65),
      (Art.trophy, const Offset(968, 1700), 112.0, 0.4),
      (Art.icBolt, const Offset(74, 880), 84.0, 0.9),
    ];
    return [
      for (final (i, (art, pos, side, phase)) in items.indexed)
        Positioned(
          left: pos.dx - side / 2 + (pos.dx < 540 ? -1 : 1) * 260 * outro,
          top: pos.dy - side / 2 + 18 * math.sin((t / 3.6 + phase) * math.pi * 2),
          width: side,
          height: side,
          child: Opacity(
            opacity: ((t - 0.4 - i * 0.12) / 0.6).clamp(0.0, 1.0) * (1 - outro),
            child: Transform.rotate(
              angle: 0.22 * math.sin((t / 4.8 + phase) * math.pi * 2) + (phase - 0.45) * 0.6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [const Color(0xFFFFB82E).withValues(alpha: 0.28), const Color(0x00FFB82E)]),
                      ),
                    ),
                  ),
                  Image.asset(art.path, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
                ],
              ),
            ),
          ),
        ),
    ];
  }
}

class _Backdrop extends CustomPainter {
  _Backdrop(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1150), Color(0xFF0B0B2A), Color(0xFF1A0F33)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    final blobs = [
      (Offset(size.width * 0.1, size.height * 0.18), 460.0, const Color(0x667A4CFF), 7.0),
      (Offset(size.width * 0.94, size.height * 0.44), 470.0, const Color(0x40FFB02E), 9.0),
      (Offset(size.width * 0.18, size.height * 0.84), 500.0, const Color(0x48E77BFF), 11.0),
      (Offset(size.width * 0.86, size.height * 0.08), 330.0, const Color(0x4045C9CE), 8.0),
    ];
    for (final (i, (c, r, color, period)) in blobs.indexed) {
      final center = c + Offset(60 * math.sin(t / period * math.pi * 2 + i), 40 * math.cos(t / period * math.pi * 2 + i));
      canvas.drawCircle(
        center,
        r,
        Paint()..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
    // Slow god rays from the top.
    final top = Offset(size.width / 2, -200);
    for (var i = 0; i < 9; i++) {
      final a = math.pi / 2 + (i - 4) * 0.16 + 0.05 * math.sin(t * 0.4 + i);
      final w = 0.035 + 0.02 * math.sin(t * 0.7 + i * 1.3);
      final p = Path()
        ..moveTo(top.dx, top.dy)
        ..lineTo(top.dx + math.cos(a - w) * 2600, top.dy + math.sin(a - w) * 2600)
        ..lineTo(top.dx + math.cos(a + w) * 2600, top.dy + math.sin(a + w) * 2600)
        ..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFFFFD45A).withValues(alpha: 0.025));
    }
    // Sparkles drifting up.
    final rng = math.Random(9);
    for (var i = 0; i < 46; i++) {
      final p = Offset(rng.nextDouble() * size.width, (rng.nextDouble() * size.height - t * (10 + rng.nextDouble() * 18)) % size.height);
      final tw = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 2 + i));
      final c = i % 3 == 0 ? const Color(0xFFFFE07A) : (i % 3 == 1 ? const Color(0xFFC9B6FF) : Colors.white);
      canvas.drawCircle(p, 1.4 + rng.nextDouble() * 2, Paint()..color = c.withValues(alpha: 0.45 * tw));
    }
  }

  @override
  bool shouldRepaint(_Backdrop old) => old.t != t;
}

class _Phone extends StatelessWidget {
  const _Phone({required this.time, required this.touches, required this.child});

  final ValueListenable<double> time;
  final List<Touch> touches;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const s = ReelStage.scale;
    const b = ReelStage.bezel;
    const screen = ReelStage.screen;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(66 * s),
        boxShadow: const [
          BoxShadow(color: Color(0x887A4CFF), blurRadius: 120, offset: Offset(0, 40)),
          BoxShadow(color: Color(0x40FFB02E), blurRadius: 60, offset: Offset(0, -10)),
          BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 12)),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A7BC8), Color(0xFF2C2650), Color(0xFF6E5FB0)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(b * s - 4),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(63 * s)),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(55 * s),
              child: FittedBox(
                alignment: Alignment.topLeft,
                child: SizedBox.fromSize(
                  size: screen,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: MediaQuery(
                          data: const MediaQueryData(
                            size: screen,
                            devicePixelRatio: 3,
                            padding: EdgeInsets.only(top: 62, bottom: 34),
                            viewPadding: EdgeInsets.only(top: 62, bottom: 34),
                          ),
                          child: child,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ValueListenableBuilder<double>(
                            valueListenable: time,
                            builder: (context, t, _) => CustomPaint(painter: _Chrome(t, touches)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chrome extends CustomPainter {
  _Chrome(this.t, this.touches);

  final double t;
  final List<Touch> touches;

  @override
  void paint(Canvas canvas, Size size) {
    const ink = Color(0xFFF5F5F7);
    final clock = TextPainter(
      text: TextSpan(text: '9:41', style: poppins(16.5, FontWeight.w600, color: ink)),
      textDirection: TextDirection.ltr,
    )..layout();
    clock.paint(canvas, Offset(72.5 - clock.width / 2, 39 - 16.5 * 1.05));
    final p = Paint()..color = ink;
    for (var i = 0; i < 4; i++) {
      final h = 4.6 + i * 2.3;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(289 + i * 5.3, 38 - h, 3.5, h), const Radius.circular(1)), p);
    }
    final wifi = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    const wc = Offset(320, 38.5);
    for (final r in [4.2, 8.0, 11.6]) {
      canvas.drawArc(Rect.fromCircle(center: wc, radius: r), -math.pi * 0.77, math.pi * 0.54, false, wifi);
    }
    canvas.drawCircle(wc + const Offset(0, -0.6), 1.6, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(338, 27.5, 26, 12.5), const Radius.circular(3.8)),
      Paint()
        ..color = ink.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(340, 29.5, 22, 8.5), const Radius.circular(2.3)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(365.3, 31.5, 1.8, 4.5), const Radius.circular(1)), Paint()..color = ink.withValues(alpha: 0.4));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(139, 14, 124, 37), const Radius.circular(18.5)), Paint()..color = Colors.black);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width / 2, size.height - 8), width: 140, height: 5), const Radius.circular(3)),
      Paint()..color = const Color(0xFFF2F2F5),
    );

    for (final touch in touches) {
      if (t < touch.start || t > touch.end + 0.45) continue;
      final pos = touch.at;
      final into = ((t - touch.start) / 0.12).clamp(0.0, 1.0);
      final out = ((t - touch.end) / 0.45).clamp(0.0, 1.0);
      final alpha = into * (1 - out);
      final r = 17 * lerp(1.25, 1, Curves.easeOut.transform(into)) * lerp(1, 0.85, out);
      canvas.drawCircle(pos, r + 1.5, Paint()..color = Colors.black.withValues(alpha: 0.25 * alpha));
      canvas.drawCircle(pos, r, Paint()..color = Colors.white.withValues(alpha: 0.6 * alpha));
      final ring = Curves.easeOut.transform(((t - touch.start) / 0.55).clamp(0.0, 1.0));
      if (ring < 1) {
        canvas.drawCircle(
          pos,
          17 + 26 * ring,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * (1 - ring)
            ..color = Tone.goldHi.withValues(alpha: 0.9 * (1 - ring)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_Chrome old) => old.t != t;
}

class _CaptionView extends StatelessWidget {
  const _CaptionView({required this.caption, required this.t});

  final Caption caption;
  final double t;

  @override
  Widget build(BuildContext context) {
    final c = caption;
    if (t < c.start || t > c.end + 0.5) return const SizedBox.shrink();
    final exit = Curves.easeInCubic.transform(((t - c.end) / 0.45).clamp(0.0, 1.0));
    final tag = poppins(24, FontWeight.w700, color: const Color(0xFFC9B6FF), tracking: 6);
    final big = poppins(66, FontWeight.w700, tracking: -1.2, shadows: const [Shadow(color: Color(0x88000000), blurRadius: 18, offset: Offset(0, 6))]);
    final warm = poppins(66, FontWeight.w700, tracking: -1.2, color: const Color(0xFFFFD84A), shadows: const [Shadow(color: Color(0x99F08A10), blurRadius: 26)]);
    return Positioned(
      left: 0,
      right: 0,
      top: 52,
      child: Opacity(
        opacity: 1 - exit,
        child: Transform.translate(
          offset: Offset(0, -40 * exit),
          child: Column(
            children: [
              _pop(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0x337A4CFF),
                    border: Border.all(color: const Color(0x66C9B6FF), width: 1.5),
                  ),
                  child: Text(c.tag, style: tag),
                ),
                0,
                0.5,
              ),
              const SizedBox(height: 8),
              _letters(c.lead, big, 0.08),
              _letters(c.punch, warm, 0.24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pop(Widget child, double delay, double span) {
    final raw = ((t - caption.start - delay) / span).clamp(0.0, 1.0);
    final s = spring(raw, bounce: 0.4, freq: 2.4);
    return Opacity(
      opacity: (raw * 3).clamp(0.0, 1.0),
      child: Transform.translate(offset: Offset(0, 24 * (1 - s)), child: child),
    );
  }

  Widget _letters(String text, TextStyle style, double delay) {
    final chars = text.split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, ch) in chars.indexed)
          Builder(
            builder: (context) {
              final raw = ((t - caption.start - delay - i * 0.026) / 0.5).clamp(0.0, 1.0);
              final s = spring(raw, bounce: 0.55, freq: 2.6);
              return Opacity(
                opacity: (raw * 4).clamp(0.0, 1.0),
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..translateByDouble(0, 40 * (1 - s), 0, 1)
                    ..rotateZ(0.3 * (1 - s) * (i.isEven ? -1 : 1))
                    ..scaleByDouble(lerp(0.4, 1, s), lerp(0.4, 1, s) * 1.12, 1, 1),
                  child: Text(ch, style: style),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.t, required this.outro});

  final double t;
  final double outro;

  @override
  Widget build(BuildContext context) {
    final show = ((t - 0.8) / 0.6).clamp(0.0, 1.0) * (1 - outro);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 34,
      child: Opacity(
        opacity: show,
        child: Center(child: SizedBox(width: 236, height: 150, child: Image.asset(Art.logo.path, fit: BoxFit.contain, filterQuality: FilterQuality.medium))),
      ),
    );
  }
}

class _LockupView extends StatelessWidget {
  const _LockupView({required this.t, required this.at, required this.lockup});

  final double t;
  final double at;
  final Lockup lockup;

  @override
  Widget build(BuildContext context) {
    if (t < at) return const SizedBox.shrink();
    final raw = ((t - at) / 0.9).clamp(0.0, 1.0);
    final s = spring(raw, bounce: 0.45, freq: 2.2);
    final word = ((t - at - 0.45) / 0.7).clamp(0.0, 1.0);
    final tag = ((t - at - 0.85) / 0.6).clamp(0.0, 1.0);
    final spin = (t - at) * 0.25;
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: (raw * 3).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, -220 * (1 - s)),
              child: Transform.scale(
                scale: lerp(0.3, 1, s),
                child: SizedBox(
                  width: 1000,
                  height: 620,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(angle: spin, child: CustomPaint(size: const Size(1000, 1000), painter: _Rays())),
                      Container(
                        width: 760,
                        height: 560,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [const Color(0xFF7A4CFF).withValues(alpha: 0.55), const Color(0x007A4CFF)]),
                        ),
                      ),
                      SizedBox(width: 760, height: 483, child: Image.asset(Art.logo.path, fit: BoxFit.contain, filterQuality: FilterQuality.medium)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: word,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - Curves.easeOutBack.transform(word))),
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (r) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: goldText, stops: goldStops).createShader(r),
                child: Text(lockup.tagline, style: poppins(64, FontWeight.w700, tracking: -0.5)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: tag,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - tag)),
              child: Text(lockup.sub, style: poppins(38, FontWeight.w500, color: const Color(0xFFE4E1F7))),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rays extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 16; i++) {
      final a = i * math.pi * 2 / 16;
      final p = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - 0.07) * 500, c.dy + math.sin(a - 0.07) * 500)
        ..lineTo(c.dx + math.cos(a + 0.07) * 500, c.dy + math.sin(a + 0.07) * 500)
        ..close();
      canvas.drawPath(
        p,
        Paint()..shader = const RadialGradient(colors: [Color(0x55FFD45A), Color(0x00FFD45A)]).createShader(Rect.fromCircle(center: c, radius: 500)),
      );
    }
  }

  @override
  bool shouldRepaint(_Rays old) => false;
}
