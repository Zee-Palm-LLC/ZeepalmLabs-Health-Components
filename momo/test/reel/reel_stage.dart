import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:momo/core/art.dart';
import 'package:momo/core/motion.dart';
import 'package:momo/core/palette.dart';
import 'package:momo/core/type.dart';
import 'package:momo/mascot/momo.dart';

TextStyle nunito(double size, {Color color = Shade.cocoa, double weight = 900, double track = 0}) {
  return TextStyle(
    fontFamily: 'Nunito',
    fontSize: size,
    fontVariations: [FontVariation('wght', weight)],
    fontWeight: FontWeight.w900,
    color: color,
    letterSpacing: track * size,
    height: 1.08,
  );
}

class Touch {
  const Touch({required this.start, required this.end, required this.path});

  final double start;
  final double end;
  final List<Offset> path;

  Offset at(double t) {
    if (path.length == 1 || end <= start) return path.first;
    final u = ((t - start) / (end - start)).clamp(0.0, 1.0) * (path.length - 1);
    final i = u.floor().clamp(0, path.length - 2);
    return Offset.lerp(path[i], path[i + 1], Curves.easeInOut.transform(u - i))!;
  }
}

class Caption {
  const Caption(this.start, this.end, this.tag, this.lead, this.punch);

  final double start;
  final double end;
  final String tag;
  final String lead;
  final String punch;
}

class ReelStage extends StatelessWidget {
  const ReelStage({super.key, required this.time, required this.touches, required this.captions, required this.app});

  static const size = Size(1080, 1920);
  static const screen = Size(402, 874);
  static const bezel = 11.0;
  static const scale = 1.5;
  static const phoneTop = 334.0;
  static const outroAt = 27.7;

  static Offset get screenOrigin => Offset((size.width - screen.width * scale) / 2, phoneTop + bezel * scale);

  static Offset toStage(Offset app) => screenOrigin + app * scale;

  final ValueListenable<double> time;
  final List<Touch> touches;
  final List<Caption> captions;
  final Widget app;

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
              Positioned(
                left: (size.width - outer.width) / 2,
                top: phoneTop,
                width: outer.width,
                height: outer.height,
                child: Transform.translate(
                  offset: Offset(0, 420 * (1 - rise) + 2000 * outro),
                  child: Transform.rotate(
                    angle: 0.08 * outro,
                    child: Transform.scale(
                      scale: lerp(0.86, 1, rise),
                      alignment: Alignment.topCenter,
                      child: Opacity(opacity: rise.clamp(0.0, 1.0), child: phone),
                    ),
                  ),
                ),
              ),
              for (final c in captions) _CaptionView(caption: c, t: t),
              _Wordmark(t: t, outro: outro),
              _Lockup(t: t),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _decor(double t, double outro) {
    final items = [
      (Art.breakfast, const Offset(96, 520), 132.0, 0.0),
      (Art.lunch, const Offset(984, 470), 140.0, 0.3),
      (Art.snack, const Offset(78, 1190), 120.0, 0.55),
      (Art.croissant, const Offset(1000, 1330), 118.0, 0.8),
      (Art.dinner, const Offset(990, 880), 132.0, 0.2),
      (Art.protein, const Offset(120, 1660), 104.0, 0.65),
      (Art.breakfast, const Offset(960, 1700), 96.0, 0.4),
      (Art.lunch, const Offset(70, 860), 100.0, 0.9),
    ];
    return [
      for (final (i, (asset, pos, side, phase)) in items.indexed)
        Positioned(
          left: pos.dx - side / 2 + (pos.dx < 540 ? -1 : 1) * 260 * outro,
          top: pos.dy - side / 2 + 18 * math.sin((t / 3.6 + phase) * math.pi * 2),
          width: side,
          height: side,
          child: Opacity(
            opacity: ((t - 0.4 - i * 0.12) / 0.6).clamp(0.0, 1.0) * (1 - outro),
            child: Transform.rotate(
              angle: 0.22 * math.sin((t / 4.8 + phase) * math.pi * 2) + (phase - 0.45) * 0.6,
              child: Image.asset(asset, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
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
          colors: [Color(0xFFFFF8EF), Color(0xFFFFEDE0), Color(0xFFFFE0D6)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    final blobs = [
      (Offset(size.width * 0.12, size.height * 0.2), 400.0, const Color(0x40FFB088), 7.0),
      (Offset(size.width * 0.92, size.height * 0.46), 440.0, const Color(0x33FFC98E), 9.0),
      (Offset(size.width * 0.2, size.height * 0.86), 480.0, const Color(0x38FF8E9C), 11.0),
      (Offset(size.width * 0.85, size.height * 0.1), 300.0, const Color(0x26C9B6FF), 8.0),
    ];
    for (final (i, (c, r, color, period)) in blobs.indexed) {
      final center = c + Offset(60 * math.sin(t / period * math.pi * 2 + i), 40 * math.cos(t / period * math.pi * 2 + i));
      canvas.drawCircle(
        center,
        r,
        Paint()..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: center, radius: r)),
      );
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
          BoxShadow(color: Color(0x40B0583C), blurRadius: 90, offset: Offset(0, 50)),
          BoxShadow(color: Color(0x30000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9E6E1), Color(0xFFB9B5AF), Color(0xFFDCD8D2)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(b * s - 4),
        child: DecoratedBox(
          decoration: BoxDecoration(color: const Color(0xFF0D0D0F), borderRadius: BorderRadius.circular(63 * s)),
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
    const ink = Color(0xFF111111);
    final clock = TextPainter(
      text: TextSpan(text: '9:41', style: inter(17, 600, color: ink, tracking: -0.2)),
      textDirection: TextDirection.ltr,
    )..layout();
    clock.paint(canvas, Offset(72.5 - clock.width / 2, 39 - 17 * interAscent));
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
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(338, 27.5, 26, 12.5), const Radius.circular(3.8));
    canvas.drawRRect(
      body,
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
      Paint()..color = const Color(0xFF111015),
    );

    for (final touch in touches) {
      if (t < touch.start || t > touch.end + 0.45) continue;
      final pos = touch.at(t);
      final into = ((t - touch.start) / 0.12).clamp(0.0, 1.0);
      final out = ((t - touch.end) / 0.45).clamp(0.0, 1.0);
      final alpha = into * (1 - out);
      final r = 17 * lerp(1.25, 1, Curves.easeOut.transform(into)) * lerp(1, 0.85, out);
      canvas.drawCircle(pos, r + 1.5, Paint()..color = Colors.black.withValues(alpha: 0.16 * alpha));
      canvas.drawCircle(pos, r, Paint()..color = Colors.white.withValues(alpha: 0.62 * alpha));
      final ring = Curves.easeOut.transform(((t - touch.start) / 0.55).clamp(0.0, 1.0));
      if (ring < 1) {
        canvas.drawCircle(
          touch.path.first,
          17 + 26 * ring,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * (1 - ring)
            ..color = Shade.peach.withValues(alpha: 0.9 * (1 - ring)),
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
    final tag = inter(25, 800, color: Shade.coral, tracking: 4);
    final big = nunito(66);
    final warm = nunito(66, color: Shade.coral);
    return Positioned(
      left: 0,
      right: 0,
      top: 66,
      child: Opacity(
        opacity: 1 - exit,
        child: Transform.translate(
          offset: Offset(0, -40 * exit),
          child: Column(
            children: [
              _pop(Text(c.tag, style: tag), 0, 0.5),
              const SizedBox(height: 14),
              _letters(c.lead, big, 0.08),
              const SizedBox(height: 2),
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

class _Brand extends StatelessWidget {
  const _Brand({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: size * 1.05, height: size * 1.17, child: const Momo(shadow: 0)),
        SizedBox(width: size * 0.18),
        Text('momo', style: nunito(size * 0.95, track: -0.01)),
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
      child: Opacity(opacity: show, child: const Center(child: _Brand(size: 52))),
    );
  }
}

class _Lockup extends StatelessWidget {
  const _Lockup({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    const at = ReelStage.outroAt + 0.35;
    if (t < at) return const SizedBox.shrink();
    final raw = ((t - at) / 0.9).clamp(0.0, 1.0);
    final s = spring(raw, bounce: 0.45, freq: 2.2);
    final word = ((t - at - 0.35) / 0.7).clamp(0.0, 1.0);
    final tag = ((t - at - 0.75) / 0.6).clamp(0.0, 1.0);
    final w = ((t - at - 0.5) / 1.4).clamp(0.0, 1.0);
    final waving = w <= 0 || w >= 1 ? 0.0 : math.sin(w * math.pi) * (0.75 + 0.25 * math.sin(w * math.pi * 6));
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: (raw * 3).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, -260 * (1 - s)),
              child: Transform.scale(
                scale: lerp(0.4, 1, s),
                child: SizedBox(width: 420, height: 466, child: Momo(mood: Mood.happy, wave: waving, squash: 0.12 * math.sin(raw * math.pi) * (1 - raw))),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Opacity(
            opacity: word,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - Curves.easeOutBack.transform(word))),
              child: Text('momo', style: nunito(170, track: -0.02)),
            ),
          ),
          const SizedBox(height: 6),
          Opacity(
            opacity: tag,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - tag)),
              child: Text('Snap it. Log it. Smile.', style: nunito(56, color: Shade.coral, weight: 800)),
            ),
          ),
        ],
      ),
    );
  }
}
