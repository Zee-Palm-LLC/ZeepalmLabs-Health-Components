import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pocket_chef/core/art.dart';
import 'package:pocket_chef/core/motion.dart';
import 'package:pocket_chef/core/palette.dart';
import 'package:pocket_chef/core/type.dart';
import 'package:pocket_chef/widgets/chef_hat.dart';

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
  static const screen = Size(393, 896);
  static const bezel = 11.0;
  static const scale = 1.55;
  static const phoneTop = 338.0;

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
        final rise = spring(((t - 0.1) / 1.1).clamp(0.0, 1.0), bounce: 0.3, freq: 2);
        final outro = Curves.easeInOutCubic.transform(((t - 28.1) / 0.9).clamp(0.0, 1.0));
        final outer = Size((screen.width + bezel * 2) * scale, (screen.height + bezel * 2) * scale);
        return SizedBox.fromSize(
          size: size,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(child: CustomPaint(painter: _Backdrop(t))),
              ..._decor(t),
              Positioned(
                left: (size.width - outer.width) / 2,
                top: phoneTop,
                width: outer.width,
                height: outer.height,
                child: Transform.translate(
                  offset: Offset(0, 420 * (1 - rise) + 260 * outro),
                  child: Transform.scale(
                    scale: lerp(0.86, 1, rise) * lerp(1, 0.78, outro),
                    alignment: Alignment.topCenter,
                    child: Opacity(opacity: rise.clamp(0.0, 1.0), child: phone),
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

  List<Widget> _decor(double t) {
    final items = [
      (Art.toss1, const Offset(78, 520), 1.9, 0.0),
      (Art.profBasilA, const Offset(930, 470), 2.1, 0.3),
      (Art.toss0, const Offset(60, 1180), 1.7, 0.55),
      (Art.profPepper, const Offset(935, 1330), 1.4, 0.8),
      (Art.toss2, const Offset(950, 880), 1.9, 0.2),
      (Art.detailBasil, const Offset(110, 1640), 2.2, 0.65),
      (Art.toss5, const Offset(880, 1680), 2.6, 0.4),
      (Art.toss6, const Offset(150, 860), 2.6, 0.9),
    ];
    return [
      for (final (i, (sprite, pos, k, phase)) in items.indexed)
        Positioned(
          left: pos.dx - sprite.width * k / 2,
          top: pos.dy - sprite.height * k / 2 + 16 * math.sin((t / 3.4 + phase) * math.pi * 2),
          width: sprite.width * k,
          height: sprite.height * k,
          child: Opacity(
            opacity: ((t - 0.4 - i * 0.12) / 0.6).clamp(0.0, 1.0),
            child: Transform.rotate(angle: 0.25 * math.sin((t / 4.6 + phase) * math.pi * 2) + phase, child: sprite.image(fit: BoxFit.contain)),
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
          colors: [Color(0xFFFFF6EE), Color(0xFFFFE9E4), Color(0xFFFFDCDC)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    final blobs = [
      (Offset(size.width * 0.12, size.height * 0.2), 380.0, const Color(0x33FF6B7E), 7.0),
      (Offset(size.width * 0.92, size.height * 0.46), 420.0, const Color(0x2EFFB35C), 9.0),
      (Offset(size.width * 0.2, size.height * 0.86), 460.0, const Color(0x33FF4D67), 11.0),
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
        borderRadius: BorderRadius.circular(60 * s),
        boxShadow: const [
          BoxShadow(color: Color(0x44A0303C), blurRadius: 90, offset: Offset(0, 50)),
          BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A3A40), Color(0xFF0C0C0F), Color(0xFF2A2A30)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(b * s - 3),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(58 * s)),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(49 * s),
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
                            padding: EdgeInsets.only(top: 54, bottom: 26),
                            viewPadding: EdgeInsets.only(top: 54, bottom: 26),
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
    const ink = Color(0xFF0B0A12);
    final clock = TextPainter(
      text: TextSpan(text: '9:41', style: inter(16.5, 650, color: ink, track: -0.01)),
      textDirection: TextDirection.ltr,
    )..layout();
    clock.paint(canvas, Offset(52 - clock.width / 2, 21));
    final p = Paint()..color = ink;
    for (var i = 0; i < 4; i++) {
      final h = 4.5 + i * 2.2;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(298 + i * 5.2, 33 - h, 3.4, h), const Radius.circular(1)), p);
    }
    final wifi = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    const wc = Offset(327.5, 33.5);
    for (final r in [4.2, 8.0, 11.6]) {
      canvas.drawArc(Rect.fromCircle(center: wc, radius: r), -math.pi * 0.77, math.pi * 0.54, false, wifi);
    }
    canvas.drawCircle(wc + const Offset(0, -0.6), 1.6, p);
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(343, 22.5, 25, 12), const Radius.circular(3.6));
    canvas.drawRRect(body, Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(345, 24.5, 21, 8), const Radius.circular(2.2)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(369.2, 26.5, 1.8, 4), const Radius.circular(1)), Paint()..color = ink.withValues(alpha: 0.4));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(135, 11, 123, 36), const Radius.circular(18)), Paint()..color = Colors.black);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width / 2, size.height - 8), width: 136, height: 5), const Radius.circular(3)),
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
            ..color = Colors.white.withValues(alpha: 0.9 * (1 - ring)),
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
    final tag = inter(25, 800, color: Palette.tomato, track: 0.16);
    final big = gummy(64, color: Palette.navy);
    final red = gummy(64, color: Palette.cherry);
    return Positioned(
      left: 0,
      right: 0,
      top: 64,
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
              _letters(c.punch, red, 0.24),
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
              final raw = ((t - caption.start - delay - i * 0.028) / 0.5).clamp(0.0, 1.0);
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
      bottom: 52,
      child: Opacity(
        opacity: show,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ChefHat(size: 44),
            const SizedBox(width: 12),
            Text('Pocket', style: outfit(40)),
            Text('Chef', style: outfit(40, color: const Color(0xFFE81A2E))),
          ],
        ),
      ),
    );
  }
}

class _Lockup extends StatelessWidget {
  const _Lockup({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    if (t < 28.2) return const SizedBox.shrink();
    final raw = ((t - 28.2) / 0.9).clamp(0.0, 1.0);
    final s = spring(raw, bounce: 0.5, freq: 2.4);
    final tag = ((t - 28.7) / 0.6).clamp(0.0, 1.0);
    return Positioned(
      left: 0,
      right: 0,
      top: 150,
      child: Column(
        children: [
          Opacity(
            opacity: (raw * 3).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: lerp(0.5, 1, s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(angle: -0.6 * (1 - s), child: const ChefHat(size: 104)),
                  const SizedBox(width: 22),
                  Text('Pocket', style: outfit(96)),
                  Text('Chef', style: outfit(96, color: const Color(0xFFE81A2E))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Opacity(
            opacity: tag,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - tag)),
              child: Text('Small bites, big smiles.', style: gummy(52, color: Palette.navy)),
            ),
          ),
        ],
      ),
    );
  }
}
