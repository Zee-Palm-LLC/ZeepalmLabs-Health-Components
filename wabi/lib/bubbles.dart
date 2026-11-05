import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Icon cells in assets/images/bubbles.png (6 x 3 holographic health artworks).
List<Rect> bubbleCells() {
  const xs = [125.0, 331.0, 537.0, 742.0, 948.0, 1153.0];
  const ys = [143.0, 358.0, 573.0];
  return [
    for (final y in ys)
      for (final x in xs) Rect.fromCenter(center: Offset(x, y), width: 184, height: 184),
  ];
}

class Bubble {
  Bubble(this.p, this.v, this.target, this.icon, this.phase) : y0 = p.dy;
  Offset p, v;
  double r = 1.5;
  final double target, phase, y0; // y0: where it was born
  final int icon;
  double age = 0;
  bool dying = false; // shrinks away to make room for new arrivals
}

/// A fountain of glass bubbles: tiny specks first, then a narrow stream from
/// the top of the orb that swells as it rises, floats up against the top of
/// the screen and packs into a funnel. On release they drift away upward.
class BubbleSim {
  final bubbles = <Bubble>[];
  final _rnd = math.Random(5);
  double _emitT = 0, _clock = 0, _flow = 0;
  int _emitted = 0;
  bool emitting = false, flyAway = false;
  static const total = 170;

  void start() {
    emitting = true;
    flyAway = false;
    _emitT = 0;
    _emitted = 0;
    _flow = 0;
  }

  void release() {
    emitting = false;
    flyAway = true;
  }

  void update(double dt, Offset orb, double orbR) {
    _clock += dt;
    if (emitting) {
      // As in the video: a few tiny specks drift out of the orb first, then a
      // narrow stream starts and builds up to full flow.
      _emitT += dt;
      if (_emitT < 0.9) {
        while (_emitted < (_emitT * 14).floor()) {
          _speck(orb, orbR);
        }
      } else {
        final ramp = Curves.easeInOut.transform(((_emitT - 0.9) / 1.6).clamp(0.0, 1.0));
        _flow += dt * (8 + 16 * ramp); // long, steady stream keeps a tail to the orb
        while (_flow >= 1) {
          _flow -= 1;
          _emit(orb, orbR);
          // Endless stream: once full, the oldest bubble quietly shrinks away.
          if (bubbles.where((b) => !b.dying).length > total) {
            for (final b in bubbles) {
              if (!b.dying) {
                b.dying = true;
                break;
              }
            }
          }
        }
      }
    }
    if (bubbles.isEmpty) return;

    final h = dt / 2;
    for (var s = 0; s < 2; s++) {
      for (final b in bubbles) {
        b.age += h;
        // Bubbles are born tiny and swell as they rise away from the orb.
        final grown = ((b.y0 - b.p.dy) / 230).clamp(0.12, 1.0);
        b.r += ((b.dying ? 0 : b.target * grown) - b.r) * (1 - math.exp(-h * (b.dying ? 2.5 : 5)));
        // Buoyancy up, drag, gentle sideways wander.
        final up = flyAway ? -900.0 : -150.0 - b.r * 4;
        final wander = Offset(math.sin(_clock * 0.9 + b.phase) * 22, 0);
        // The plume fans out as it rises (wide at the top, narrow at the orb).
        final fan = flyAway ? 0.0 : (b.p.dx - orb.dx) * 0.9;
        b.v += (Offset(fan, up) + wander) * h;
        b.v *= math.exp(-h * (flyAway ? 1.2 : 2.6));
        b.p += b.v * h;
        if (!flyAway) {
          // Soft side walls and a ceiling slightly above the top edge.
          if (b.p.dx < b.r * 0.6) b.v += Offset((b.r * 0.6 - b.p.dx) * 40 * h, 0);
          if (b.p.dx > 390 - b.r * 0.6) b.v -= Offset((b.p.dx - 390 + b.r * 0.6) * 40 * h, 0);
          final ceil = b.r * 0.35;
          if (b.p.dy < ceil) {
            b.p = Offset(b.p.dx, b.p.dy + (ceil - b.p.dy) * 0.5);
            b.v = Offset(b.v.dx, b.v.dy.abs() * 0.2);
          }
          // Keep the cluster above the orb.
          if (b.p.dy > orb.dy - orbR - b.r && b.age > 0.6) b.v -= Offset(0, 60 * h);
        }
      }
      if (!flyAway) _collide();
    }
    bubbles.removeWhere((b) => (b.dying && b.r < 0.7) || (flyAway && b.p.dy < -b.r - 20));
  }

  /// Stream bubble: leaves the top of the orb, mostly straight up.
  void _emit(Offset orb, double orbR) {
    _emitted++;
    final big = _rnd.nextDouble() < 0.6;
    final target = big ? 12 + _rnd.nextDouble() * 16 : 2.5 + _rnd.nextDouble() * 7;
    bubbles.add(
      Bubble(
        orb + Offset((_rnd.nextDouble() - 0.5) * orbR * 0.5, -orbR * 0.3),
        Offset((_rnd.nextDouble() - 0.5) * 70, -(190 + _rnd.nextDouble() * 130)),
        target,
        _rnd.nextInt(18),
        _rnd.nextDouble() * 6.28,
      ),
    );
  }

  /// Opening speck: a tiny droplet that drifts out slowly at a wide angle.
  void _speck(Offset orb, double orbR) {
    _emitted++;
    final ang = -math.pi / 2 + (_rnd.nextDouble() - 0.5) * 2.4;
    bubbles.add(
      Bubble(
        orb + Offset(math.cos(ang), math.sin(ang)) * orbR * 0.6,
        Offset(math.cos(ang), math.sin(ang)) * (60 + _rnd.nextDouble() * 90),
        1.5 + _rnd.nextDouble() * 2.5,
        _rnd.nextInt(18),
        _rnd.nextDouble() * 6.28,
      ),
    );
  }

  void _collide() {
    final n = bubbles.length;
    for (var i = 0; i < n; i++) {
      final a = bubbles[i];
      for (var j = i + 1; j < n; j++) {
        final b = bubbles[j];
        final d = b.p - a.p;
        final min = a.r + b.r + 0.4;
        final dist2 = d.distanceSquared;
        if (dist2 >= min * min || dist2 < 1e-6) continue;
        final dist = math.sqrt(dist2);
        final push = (min - dist) / dist * 0.5;
        final wa = b.r / (a.r + b.r), wb = a.r / (a.r + b.r);
        a.p -= d * push * wa;
        b.p += d * push * wb;
        final rv = b.v - a.v;
        final nrm = d / dist;
        final vn = rv.dx * nrm.dx + rv.dy * nrm.dy;
        if (vn < 0) {
          a.v += nrm * vn * 0.4 * wa;
          b.v -= nrm * vn * 0.4 * wb;
        }
      }
    }
  }
}

/// Bakes every bubble look once into a single sprite sheet: the artwork
/// fisheye-scaled inside a glass sphere with a dark refraction rim, an
/// iridescent dispersion ring and specular glints. All the blurs happen
/// here, once. The last cell is the tiny dark droplet.
class BubbleSprites {
  BubbleSprites._(this.sheet, this.count);
  final ui.Image sheet;
  final int count;
  static const px = 128.0; // cell size
  static const radius = px / 2 - 2;

  Rect cell(int i) => Rect.fromLTWH(i * px, 0, px, px);
  int get droplet => count - 1;

  static const _rainbow = SweepGradient(
    colors: [
      Color(0xFFFF3DD6),
      Color(0xFFFF9A3D),
      Color(0xFFFFF04D),
      Color(0xFF4DFFEA),
      Color(0xFF3D6BFF),
      Color(0xFFB13DFF),
      Color(0xFFFF3DD6),
    ],
  );

  static BubbleSprites build(ui.Image art, List<Rect> cells) {
    final n = cells.length + 1;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    const r = radius;
    for (var i = 0; i < n; i++) {
      final c = Offset(i * px + px / 2, px / 2);
      final rect = Rect.fromCircle(center: c, radius: r);
      if (i == n - 1) {
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.3, -0.4),
              colors: [Color(0xFFE9D5DD), Color(0xFF5B3A55), Color(0xFF241521)],
              stops: [0, 0.55, 1],
            ).createShader(rect),
        );
        canvas.drawCircle(c + const Offset(-r * 0.32, -r * 0.36), r * 0.28, Paint()..color = const Color(0xCCFFFFFF));
        continue;
      }
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));
      canvas.drawImageRect(
        art,
        cells[i],
        Rect.fromCircle(center: c, radius: r * 1.28),
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0x00000000), Color(0x00000000), Color(0xAA2A0E2E)],
            stops: [0, 0.72, 1],
          ).createShader(rect),
      );
      canvas.drawCircle(
        c,
        r * 0.9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.16
          ..blendMode = BlendMode.screen
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, r * 0.05)
          ..shader = _rainbow.createShader(rect.shift(const Offset(0, r * 0.1))),
      );
      canvas.restore();
      canvas.drawOval(
        Rect.fromCenter(center: c + const Offset(-r * 0.36, -r * 0.42), width: r * 0.5, height: r * 0.3),
        Paint()
          ..color = const Color(0xBFFFFFFF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, r * 0.05),
      );
      canvas.drawCircle(c + const Offset(r * 0.42, r * 0.38), r * 0.08, Paint()..color = const Color(0x80FFFFFF));
    }
    return BubbleSprites._(rec.endRecording().toImageSync((n * px).round(), px.round()), n);
  }
}

/// Draws every bubble in a single drawAtlas call from the baked sprites, so
/// a screen full of glass spheres costs about as much as one image.
class BubblePainter extends CustomPainter {
  BubblePainter(this.sim, this.sprites, Listenable repaint) : super(repaint: repaint);
  final BubbleSim sim;
  final BubbleSprites? sprites;

  final _xf = <RSTransform>[];
  final _rects = <Rect>[];

  @override
  void paint(Canvas canvas, Size size) {
    final s = sprites;
    if (s == null || sim.bubbles.isEmpty) return;
    _xf.clear();
    _rects.clear();
    const half = BubbleSprites.px / 2;
    for (final b in sim.bubbles) {
      if (b.r < 0.6) continue;
      _xf.add(
        RSTransform.fromComponents(
          rotation: 0,
          scale: b.r / BubbleSprites.radius,
          anchorX: half,
          anchorY: half,
          translateX: b.p.dx,
          translateY: b.p.dy,
        ),
      );
      _rects.add(s.cell(b.r < 6 ? s.droplet : b.icon));
    }
    if (_xf.isEmpty) return;
    canvas.drawAtlas(s.sheet, _xf, _rects, null, null, null, Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(BubblePainter old) => old.sprites != sprites;
}
