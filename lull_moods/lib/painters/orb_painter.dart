import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../layout.dart';
import '../mood.dart';

typedef _Particle = ({double x, double y, double size, double speed});

List<_Particle> _seed(int n, int salt) => List.generate(n, (i) {
      final r = Random(i * 31 + salt);
      return (x: r.nextDouble(), y: r.nextDouble(), size: r.nextDouble(), speed: 0.6 + r.nextDouble() * 0.7);
    });

/// The mood character (halo, body, parametric face) plus the ambient effects
/// that belong to it: bubbles, pulse rings, clouds, rain and floating Z's.
class OrbPainter extends CustomPainter {
  OrbPainter({
    required this.v,
    required this.time,
    required this.geo,
    required this.dip,
    required this.poke,
  }) : super(repaint: Listenable.merge([time, poke]));

  final MoodVisual v;
  final ValueListenable<double> time;
  final Geo geo;

  /// Vertical sink while morphing between moods (the "sunset").
  final double dip;

  /// 0..1 progress of a poke reaction.
  final Animation<double> poke;

  static const _joy = FaceSpec(eyeOpen: 0, closedCurve: 1, mouthCurve: 1.3, mouthWidth: 46, blush: 1.2);
  static final _bubbles = _seed(16, 3);
  static final _drops = _seed(44, 7);

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final s = geo.s;
    final a = v.ambient;
    final pk = poke.value;
    final wobble = sin(pk * pi * 3) * (1 - pk);
    final joy = sin(pk * pi).clamp(0.0, 1.0);
    final face = FaceSpec.lerp(v.face, _joy, joy * 0.9);

    final breathe = 1 + 0.012 * sin(t * (1.3 + a.sparks * 2.4));
    final jitter = Offset(sin(t * 47) * 0.8, cos(t * 41) * 0.6) * s * a.sparks;
    final c = geo.orbCenter + Offset(0, dip) + jitter;
    final r = geo.orbR;

    if (a.bubbles > 0.01) _paintBubbles(canvas, size, t, a.bubbles);

    canvas.drawCircle(c, 296 * s * breathe, Paint()..color = v.halo.withValues(alpha: 0.26));
    canvas.drawCircle(c, 222 * s * breathe, Paint()..color = v.halo.withValues(alpha: 0.62));
    if (a.sparks > 0.01) _paintSparks(canvas, c, t, a.sparks);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(breathe * (1 + 0.07 * wobble), breathe * (1 - 0.07 * wobble));
    final orbRect = Rect.fromCircle(center: Offset.zero, radius: r);
    final body = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.7),
        radius: 1.05,
        colors: [v.orbLight, v.orbDark],
      ).createShader(orbRect);
    canvas.drawCircle(Offset.zero, r, body);
    canvas.drawCircle(
      Offset.zero,
      r - 1.2 * s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * s
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0x59FFFFFF), const Color(0x00FFFFFF)],
          stops: const [0, 0.35],
        ).createShader(orbRect),
    );
    _paintFace(canvas, face, t, body);
    canvas.restore();

    if (a.clouds > 0.01) _paintClouds(canvas, t, a.clouds);
    if (a.rain > 0.01) _paintRain(canvas, size, t, a.rain);
    if (a.zz > 0.01) _paintZz(canvas, t, a.zz);
  }

  // ── Face ────────────────────────────────────────────────────────────────

  void _paintFace(Canvas canvas, FaceSpec f, double t, Paint body) {
    final s = geo.s;
    final bt = t % 4.6;
    final blink = bt < 0.16 ? (1 - sin(bt / 0.16 * pi)).clamp(0.0, 1.0) : 1.0;
    final open = f.eyeOpen * blink;
    final gaze = Offset(sin(t * 0.5) * 2.5, cos(t * 0.37) * 1.2) * s * f.eyeOpen;
    final ink = v.faceInk;

    final blushPaint = Paint()
      ..color = v.blush.withValues(alpha: (v.blush.a * 0.62 * f.blush).clamp(0.0, 1.0))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * s);
    for (final side in const [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(side * 86 * s, -44 * s), width: 40 * s, height: 17 * s),
        blushPaint,
      );
    }

    for (final side in const [-1.0, 1.0]) {
      final o = Offset(side * 58 * s, -70 * s) + gaze;
      _paintEye(canvas, o, f, open, side, body);
      if (f.browAlpha > 0.01) {
        final by = o.dy - 30 * s * f.eyeScale;
        canvas.drawLine(
          Offset(o.dx - side * 13 * s, by - 7 * s * f.browTilt),
          Offset(o.dx + side * 15 * s, by + 3 * s * f.browTilt),
          Paint()
            ..color = ink.withValues(alpha: f.browAlpha.clamp(0.0, 1.0))
            ..strokeWidth = 4 * s
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    _paintMouth(canvas, f, t);
    if (f.tear > 0.01) _paintTear(canvas, f, t);
    if (f.sweat > 0.01) _paintSweat(canvas, f, t);
  }

  void _paintEye(Canvas canvas, Offset o, FaceSpec f, double open, double side, Paint body) {
    final s = geo.s;
    final ink = v.faceInk;
    final w = 30 * s * f.eyeScale;
    final h = 35 * s * f.eyeScale;
    final vis = Curves.easeOut.transform(((open - 0.08) / 0.5).clamp(0.0, 1.0));

    if (vis > 0) {
      final eh = max(6 * s, h * open);
      final rect = Rect.fromCenter(center: o, width: w, height: eh);
      canvas.drawOval(rect, Paint()..color = ink.withValues(alpha: vis));
      final hl = ((open - 0.45) / 0.55).clamp(0.0, 1.0) * vis;
      if (hl > 0) {
        canvas.drawCircle(o + Offset(w * 0.2, -eh * 0.2), w * 0.17, Paint()..color = Color.fromRGBO(255, 255, 255, 0.95 * hl));
        canvas.drawCircle(o + Offset(-w * 0.14, eh * 0.2), w * 0.08, Paint()..color = Color.fromRGBO(255, 255, 255, 0.6 * hl));
      }
      if (f.lidDroop > 0.01) {
        // A heavy lid painted with the body shader so it blends into the skin.
        final top = rect.top - 3 * s;
        final cover = eh * f.lidDroop;
        final outerX = o.dx + side * w * 0.8;
        final innerX = o.dx - side * w * 0.8;
        final lid = Path()
          ..moveTo(outerX, top - 4 * s)
          ..lineTo(innerX, top - 4 * s)
          ..lineTo(innerX, top + cover * 0.25)
          ..lineTo(outerX, top + cover * 1.1)
          ..close();
        canvas.drawPath(lid, body);
      }
    }

    if (vis < 1) {
      final hw = w * 0.48;
      final p = Path()
        ..moveTo(o.dx - hw, o.dy)
        ..quadraticBezierTo(o.dx, o.dy - 18 * s * f.closedCurve, o.dx + hw, o.dy);
      canvas.drawPath(
        p,
        Paint()
          ..color = ink.withValues(alpha: 1 - vis)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5 * s
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintMouth(Canvas canvas, FaceSpec f, double t) {
    final s = geo.s;
    final ink = v.faceInk;
    final m = Offset(0, -20 * s);
    final hw = f.mouthWidth * s / 2;
    final k = 13 * s * f.mouthCurve;
    final wv = 7 * s * f.mouthWave * (1 + 0.25 * sin(t * 7));
    final line = 1 - f.mouthOpen;

    if (line > 0.01 && hw > 0.5) {
      final p = Path()
        ..moveTo(m.dx - hw, m.dy)
        ..cubicTo(m.dx - hw * 0.35, m.dy + k - wv, m.dx + hw * 0.35, m.dy + k + wv, m.dx + hw, m.dy);
      canvas.drawPath(
        p,
        Paint()
          ..color = ink.withValues(alpha: line.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.6 * s
          ..strokeCap = StrokeCap.round,
      );
    }
    if (f.mouthOpen > 0.01) {
      final br = 1 + 0.18 * sin(t * 1.3);
      canvas.drawOval(
        Rect.fromCenter(center: m + Offset(0, 2 * s), width: 9 * s * br, height: 8 * s * br),
        Paint()..color = ink.withValues(alpha: f.mouthOpen.clamp(0.0, 1.0)),
      );
    }
  }

  void _paintTear(Canvas canvas, FaceSpec f, double t) {
    final s = geo.s;
    final ph = (t * 0.45) % 1.0;
    final fade = ph < 0.15 ? ph / 0.15 : 1 - (ph - 0.15) / 0.85;
    _drop(canvas, Offset(70 * s, -48 * s + ph * 46 * s), 4.6 * s, Color.fromRGBO(160, 212, 255, f.tear.clamp(0.0, 1.0) * fade));
  }

  void _paintSweat(Canvas canvas, FaceSpec f, double t) {
    final s = geo.s;
    final ph = (t * 0.3) % 1.0;
    final fade = ph < 0.2 ? ph / 0.2 : 1 - (ph - 0.2) / 0.8;
    _drop(canvas, Offset(112 * s, -112 * s + ph * 16 * s), 6.5 * s, Color.fromRGBO(255, 255, 255, 0.85 * f.sweat.clamp(0.0, 1.0) * fade));
  }

  static void _drop(Canvas canvas, Offset o, double r, Color color) {
    final p = Path()
      ..moveTo(o.dx, o.dy - r * 2.2)
      ..quadraticBezierTo(o.dx + r * 1.05, o.dy - r * 0.6, o.dx + r, o.dy)
      ..arcToPoint(Offset(o.dx - r, o.dy), radius: Radius.circular(r))
      ..quadraticBezierTo(o.dx - r * 1.05, o.dy - r * 0.6, o.dx, o.dy - r * 2.2)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  // ── Ambience ────────────────────────────────────────────────────────────

  void _paintBubbles(Canvas canvas, Size size, double t, double k) {
    final s = geo.s;
    final top = geo.y(150);
    final span = size.height - top;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * s;
    final shine = Paint();
    for (final b in _bubbles) {
      final ph = (b.y + t * 0.05 * b.speed) % 1.0;
      final p = Offset(b.x * size.width + sin(t * 0.9 + b.y * 9) * 10 * s, size.height - ph * span);
      final fade = sin(ph * pi) * k;
      final r = (2.5 + b.size * 5.5) * s;
      ring.color = Color.fromRGBO(255, 255, 255, 0.65 * fade);
      shine.color = Color.fromRGBO(255, 255, 255, 0.5 * fade);
      canvas.drawCircle(p, r, ring);
      canvas.drawCircle(p + Offset(-r * 0.35, -r * 0.35), r * 0.22, shine);
    }
  }

  void _paintSparks(Canvas canvas, Offset c, double t, double k) {
    final s = geo.s;
    for (var i = 0; i < 2; i++) {
      final ph = (t * 0.55 + i * 0.5) % 1.0;
      canvas.drawCircle(
        c,
        (225 + ph * 90) * s,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * s
          ..color = v.halo.withValues(alpha: (1 - ph) * 0.6 * k),
      );
    }
    final p = Paint()
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final ang = -pi / 2 + (i - 2.5) * 0.3;
      final flick = 0.5 + 0.5 * sin(t * 11 + i * 1.7);
      final d = Offset(cos(ang), sin(ang));
      p.color = v.ink.withValues(alpha: 0.5 * k * flick);
      canvas.drawLine(c + d * (228 * s), c + d * ((228 + 12 * flick) * s), p);
    }
  }

  void _paintClouds(Canvas canvas, double t, double k) {
    final s = geo.s;
    final base = geo.orbCenter;
    final a = k.clamp(0.0, 1.0);
    final fill = Paint()..color = v.cloud.withValues(alpha: a);
    final shade = Paint()..color = Color.lerp(v.cloud, v.orbDark, 0.3)!.withValues(alpha: a * 0.9);
    final slide = (1 - k) * 170 * s;
    _cloud(canvas, base + Offset(-140 * s - slide + sin(t * 0.35) * 5 * s, -238 * s), 150 * s, fill, shade);
    _cloud(canvas, base + Offset(150 * s + slide + sin(t * 0.3 + 1) * 4 * s, -255 * s), 92 * s, fill, shade);
  }

  static void _cloud(Canvas canvas, Offset c, double w, Paint fill, Paint shade) {
    final h = w * 0.36;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, h * 0.25), width: w, height: h * 0.7),
        Radius.circular(h * 0.35),
      ))
      ..addOval(Rect.fromCircle(center: c + Offset(-w * 0.18, -h * 0.05), radius: h * 0.42))
      ..addOval(Rect.fromCircle(center: c + Offset(w * 0.1, -h * 0.22), radius: h * 0.55))
      ..addOval(Rect.fromCircle(center: c + Offset(w * 0.32, h * 0.05), radius: h * 0.32));
    canvas.drawPath(path.shift(Offset(0, w * 0.025)), shade);
    canvas.drawPath(path, fill);
  }

  void _paintRain(Canvas canvas, Size size, double t, double k) {
    final s = geo.s;
    final top = geo.orbCenter.dy - 250 * s;
    final span = size.height - top;
    final p = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.5 * k.clamp(0.0, 1.0))
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round;
    for (final d in _drops) {
      final y = top + ((d.y + t * d.speed * 0.55) % 1.0) * span;
      final x = d.x * size.width - (y - top) * 0.12;
      canvas.drawLine(Offset(x, y), Offset(x - 2.4 * s, y + 13 * s * d.speed), p);
    }
  }

  void _paintZz(Canvas canvas, double t, double k) {
    final s = geo.s;
    final base = geo.orbCenter + Offset(104 * s, -262 * s);
    for (var i = 0; i < 3; i++) {
      final ph = (t * 0.28 + i / 3) % 1.0;
      final a = (sin(ph * pi) * k).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(text: 'Z', style: inter((9 + ph * 11) * s, FontWeight.w800, v.inkSoft.withValues(alpha: a))),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, base + Offset(ph * 24 * s, -ph * 34 * s) - Offset(tp.width / 2, tp.height / 2));
      tp.dispose();
    }
  }

  @override
  bool shouldRepaint(OrbPainter old) => old.v != v || old.dip != dip || old.geo != geo;
}
