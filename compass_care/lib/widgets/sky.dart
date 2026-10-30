import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme.dart';

enum SkyMode { intro, setup }

/// Which part of the sky to paint, so content can sit between cloud layers.
enum SkyLayer { all, back, front }

/// A volumetric cumulus rendered once into an image (puffs of soft radial
/// gradients with a warm underside), then only translated per frame.
class _Cloud {
  _Cloud(this.x, this.y, this.w, this.depth, this.speed, int seed) : image = _render(w, seed);

  final double x, y, w, depth, speed; // design units
  final ui.Image image;

  // The image is padded around the nominal w x h box so soft edges never clip.
  static const padX = 0.2, padTop = 0.45, padBottom = 0.25;

  static ui.Image _render(double w, int seed) {
    final rnd = math.Random(seed);
    final h = w * 0.62;
    const k = 2.0; // supersample for crisp edges at 2-3x DPR
    final rec = ui.PictureRecorder();
    final c = Canvas(rec)
      ..scale(k)
      ..translate(w * padX, h * padTop);
    final full = Rect.fromLTWH(-w * padX, -h * padTop, w * (1 + 2 * padX), h * (1 + padTop + padBottom));
    final puffs = <(Offset, double)>[];
    final n = 8 + rnd.nextInt(4);
    for (var i = 0; i < n; i++) {
      final f = i / (n - 1);
      final arch = math.sin(f * math.pi);
      final r = w * (0.1 + 0.15 * arch + rnd.nextDouble() * 0.04);
      final cx = w * (0.12 + 0.76 * f) + (rnd.nextDouble() - 0.5) * w * 0.06;
      final cy = h * (0.78 - 0.32 * arch) + (rnd.nextDouble() - 0.5) * h * 0.08;
      puffs.add((Offset(cx, cy), r));
    }
    // Flat misty base behind the puffs.
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.02, h * 0.6, w * 0.96, h * 0.38), Radius.circular(h * 0.19)),
      Paint()
        ..color = const Color(0xFFFBE4DE)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.05),
    );
    // Opaque lobes, back (higher) to front (lower): each lit from the top-left
    // with a blush rim, so overlapping lobes read as separate billows.
    puffs.sort((p, q) => p.$1.dy.compareTo(q.$1.dy));
    for (final (o, r) in puffs) {
      final rect = Rect.fromCircle(center: o, radius: r);
      c.drawCircle(
        o,
        r,
        Paint()
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.04)
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.45),
            radius: 1.05,
            colors: [Color(0xFFFFFFFF), Color(0xFFFFF5F2), Color(0xFFF6D0C7), Color(0xFFEDB2A6)],
            stops: [0, 0.45, 0.82, 1],
          ).createShader(rect),
      );
    }
    // Soft underside so the bank sits on a misty floor.
    final floor = Rect.fromLTWH(-w * 0.05, h * 0.82, w * 1.1, h * 0.3);
    c.drawOval(
      floor,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xEEFFF3F0), Color(0x00FFF3F0)]).createShader(floor),
    );
    return rec.endRecording().toImageSync((full.width * k).ceil(), (full.height * k).ceil());
  }
}

/// The animated background shared by every screen: gradient sky, drifting
/// cloud layers with depth parallax, and twinkling sparkles.
class Sky extends StatefulWidget {
  const Sky({super.key, required this.mode, this.parallax, this.cloudLine = 400, this.layer = SkyLayer.all});

  final SkyMode mode;
  final ValueListenable<double>? parallax; // e.g. carousel page offset
  final double cloudLine; // design y of the cloud bank (intro)
  final SkyLayer layer;

  @override
  State<Sky> createState() => _SkyState();
}

class _SkyState extends State<Sky> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((d) => _t.value = d.inMicroseconds / 1e6);
  final _t = ValueNotifier(0.0);
  late List<_Cloud> _clouds;

  @override
  void initState() {
    super.initState();
    _clouds = _bank();
    _ticker.start();
  }

  @override
  void didUpdateWidget(Sky old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode || old.cloudLine != widget.cloudLine) _clouds = _bank();
  }

  List<_Cloud> _bank() {
    final y = widget.cloudLine;
    return switch (widget.mode) {
      SkyMode.intro => [
        _Cloud(-90, y - 90, 260, 0.6, 3, 1),
        _Cloud(250, y - 100, 250, 0.6, -2.5, 2),
        _Cloud(-140, y - 40, 300, 0.85, 4, 3),
        _Cloud(110, y - 30, 280, 0.9, -3, 4),
        _Cloud(280, y - 50, 260, 0.8, 3.5, 5),
        _Cloud(-60, y + 10, 330, 1.1, -2, 6),
        _Cloud(200, y + 20, 340, 1.15, 2.5, 7),
        _Cloud(60, y + 40, 280, 1.2, 1.8, 8),
        _Cloud(330, y + 35, 260, 1.25, -1.6, 9),
      ],
      SkyMode.setup => [
        _Cloud(-120, 150, 280, 0.7, 2.5, 11),
        _Cloud(240, 130, 260, 0.75, -2, 12),
        _Cloud(-150, 640, 300, 1.0, 3, 13),
        _Cloud(230, 650, 300, 1.05, -2.5, 14),
        _Cloud(40, 700, 320, 1.2, 2, 15),
      ],
    };
  }

  @override
  void dispose() {
    _ticker.dispose();
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SkyPainter(
          mode: widget.mode,
          clouds: _clouds,
          t: _t,
          parallax: widget.parallax,
          cloudLine: widget.cloudLine,
          layer: widget.layer,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter({
    required this.mode,
    required this.clouds,
    required this.t,
    this.parallax,
    required this.cloudLine,
    required this.layer,
  }) : super(repaint: Listenable.merge([t, ?parallax]));

  final SkyMode mode;
  final List<_Cloud> clouds;
  final ValueNotifier<double> t;
  final ValueListenable<double>? parallax;
  final double cloudLine;
  final SkyLayer layer;

  static final _stars = () {
    final r = math.Random(7);
    return List.generate(18, (_) => (r.nextDouble(), r.nextDouble(), r.nextDouble() * 6, 0.6 + r.nextDouble()));
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 390;
    final time = t.value;
    final px = parallax?.value ?? 0;
    if (layer != SkyLayer.front) _background(canvas, size, s, time, px);

    // Clouds: slow drift + parallax by depth; images drawn with high quality.
    final paint = Paint()..filterQuality = FilterQuality.medium;
    for (final c in clouds) {
      if (layer == SkyLayer.back && c.depth >= 0.8) continue;
      if (layer == SkyLayer.front && c.depth < 0.8) continue;
      final drift = math.sin(time * 0.08 * c.speed.abs() + c.x) * 14 + time * c.speed;
      final x = ((c.x + drift - px * 60 * c.depth) % 620 + 620) % 620 - 160;
      final bob = math.sin(time * 0.35 + c.y) * 3;
      final h = c.w * 0.62;
      final dst = Rect.fromLTWH(
        (x - c.w * _Cloud.padX) * s,
        (c.y + bob - h * _Cloud.padTop) * s,
        c.w * (1 + 2 * _Cloud.padX) * s,
        h * (1 + _Cloud.padTop + _Cloud.padBottom) * s,
      );
      canvas.drawImageRect(c.image, Offset.zero & Size(c.image.width.toDouble(), c.image.height.toDouble()), dst, paint);
    }
  }

  void _background(Canvas canvas, Size size, double s, double time, double px) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    if (mode == SkyMode.intro) {
      final skyH = (cloudLine + 40) * s;
      final sky = Rect.fromLTWH(0, 0, size.width, skyH);
      // Warm diagonal: peach-orange top-left into coral red top-right.
      canvas.drawRect(
        sky,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment(-1, -0.6),
            end: Alignment(1, 0.4),
            colors: [Color(0xFFFF9E73), Color(0xFFFB6A4A), C.red],
            stops: [0, 0.45, 1],
          ).createShader(sky),
      );
      // Soft vertical fade into the white page.
      final fade = Rect.fromLTWH(0, skyH - 150 * s, size.width, 150 * s);
      canvas.drawRect(
        fade,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00FFFFFF), Color(0x99FDE6E0), Colors.white],
          ).createShader(fade),
      );
      // Twinkling sparkles in the sky.
      for (final (fx, fy, ph, k) in _stars) {
        final tw = 0.5 + 0.5 * math.sin(time * 1.6 * k + ph);
        final p = Offset((fx * 390 - px * 18 * k) % 390 * s, fy * (cloudLine - 80) * s);
        _sparkle(canvas, p, (1.2 + 1.6 * tw) * s, 0.35 + 0.55 * tw);
      }
    } else {
      final r = Offset.zero & size;
      canvas.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFDEEEA), Color(0xFFF9D2C9), Color(0xFFFBDDD6), Colors.white],
            stops: [0.02, 0.22, 0.55, 0.82, 0.97],
          ).createShader(r),
      );
    }
  }

  void _sparkle(Canvas canvas, Offset p, double r, double a) {
    final paint = Paint()..color = Colors.white.withValues(alpha: a);
    final path = Path()
      ..moveTo(p.dx, p.dy - r * 2)
      ..quadraticBezierTo(p.dx, p.dy, p.dx + r * 2, p.dy)
      ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r * 2)
      ..quadraticBezierTo(p.dx, p.dy, p.dx - r * 2, p.dy)
      ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r * 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.mode != mode || old.clouds != clouds;
}
