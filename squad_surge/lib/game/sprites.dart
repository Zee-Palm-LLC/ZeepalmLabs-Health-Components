import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A baked character: a few running frames rendered once at high resolution,
/// anchored at the feet (bottom centre) of a [w] × [h] design box.
class Sprite {
  Sprite(this.frames, this.w, this.h);
  final List<ui.Image> frames;
  final double w, h;
}

/// Every character in the game is drawn in code here and baked to images at
/// start-up, so hundreds of them can be drawn per frame cheaply.
class Sprites {
  Sprites._(this.soldier, this.brute, this.boss);

  final Sprite soldier, brute, boss;

  static Sprites bake() => Sprites._(
        _bake(36, 52, 4, 4, _soldier),
        _bake(44, 56, 4, 4, _brute),
        _bake(64, 72, 4, 7, _boss),
      );

  static Sprite _bake(double w, double h, int frames, double scale, void Function(Canvas, int) draw) {
    final out = <ui.Image>[];
    for (var f = 0; f < frames; f++) {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec)..scale(scale);
      draw(c, f);
      out.add(rec.endRecording().toImageSync((w * scale).round(), (h * scale).round()));
    }
    return Sprite(out, w, h);
  }

  static Paint _grad(Rect r, Color a, Color b) =>
      Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a, b]).createShader(r);

  static void _gloss(Canvas c, Rect r) => c.drawOval(
        Rect.fromLTWH(r.left + r.width * 0.16, r.top + r.height * 0.1, r.width * 0.34, r.height * 0.26),
        Paint()..color = Colors.white.withValues(alpha: 0.38),
      );

  /// Blue squad member, seen from behind, rifle up.
  static void _soldier(Canvas c, int f) {
    final step = math.sin(f * math.pi / 2) * 3.2;
    final leg = Paint()..color = const Color(0xFF173F9E);
    c.drawRRect(RRect.fromLTRBR(10, 37 - step, 17, 51 - step, const Radius.circular(3.5)), leg);
    c.drawRRect(RRect.fromLTRBR(19, 37 + step, 26, 51 + step.clamp(-3.2, 0), const Radius.circular(3.5)), leg);
    final body = Rect.fromLTWH(5, 17, 26, 26);
    c.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(12)), _grad(body, const Color(0xFF5CC2FF), const Color(0xFF1C63DC)));
    // Backpack.
    c.drawRRect(RRect.fromLTRBR(11, 23, 25, 36, const Radius.circular(4)), Paint()..color = const Color(0xFF1752BE));
    c.drawRRect(RRect.fromLTRBR(13, 25, 23, 28, const Radius.circular(2)), Paint()..color = const Color(0xFF2A6BD8));
    _gloss(c, body);
    // Rifle held up on the right shoulder.
    c.drawRRect(RRect.fromLTRBR(26, 5, 30.5, 26, const Radius.circular(2)), Paint()..color = const Color(0xFF2B313B));
    c.drawRect(const Rect.fromLTWH(26.8, 3, 3, 3), Paint()..color = const Color(0xFF4A5260));
    // Helmet.
    final head = Rect.fromCircle(center: const Offset(18, 13), radius: 9.5);
    c.drawOval(head, _grad(head, const Color(0xFF6BCBFF), const Color(0xFF1E6AE0)));
    c.drawArc(head.deflate(0.5), 0.15, math.pi - 0.3, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = const Color(0xFF184FB0));
    _gloss(c, head);
  }

  static void _bruteBody(Canvas c, int f, {required Color hi, required Color lo, required Color dark}) {
    final step = math.sin(f * math.pi / 2) * 3.5;
    final leg = Paint()..color = dark;
    c.drawRRect(RRect.fromLTRBR(12, 40 - step, 20, 55 - step, const Radius.circular(4)), leg);
    c.drawRRect(RRect.fromLTRBR(24, 40 + step, 32, 55 + step.clamp(-3.5, 0), const Radius.circular(4)), leg);
    // Swinging arms behind the body edge.
    void arm(double x, double a) {
      c.save();
      c.translate(x, 22);
      c.rotate(a);
      c.drawRRect(RRect.fromLTRBR(-4.5, -2, 4.5, 20, const Radius.circular(4.5)), Paint()..color = lo);
      c.restore();
    }

    arm(6, 0.25 + step * 0.06);
    arm(38, -0.25 + step * 0.06);
    final body = Rect.fromLTWH(5, 12, 34, 34);
    c.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(15)), _grad(body, hi, lo));
    c.drawOval(Rect.fromLTWH(13, 30, 18, 12), Paint()..color = Colors.white.withValues(alpha: 0.12));
    _gloss(c, body);
    // Angry face.
    final white = Paint()..color = Colors.white;
    c.drawOval(const Rect.fromLTWH(11.5, 20, 9, 10), white);
    c.drawOval(const Rect.fromLTWH(23.5, 20, 9, 10), white);
    final ink = Paint()..color = const Color(0xFF1A0A0C);
    c.drawCircle(const Offset(17, 26.5), 2.4, ink);
    c.drawCircle(const Offset(27, 26.5), 2.4, ink);
    final brow = Paint()
      ..color = const Color(0xFF1A0A0C)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(11, 18.5), const Offset(20, 21.5), brow);
    c.drawLine(const Offset(33, 18.5), const Offset(24, 21.5), brow);
    c.drawRRect(RRect.fromLTRBR(17, 34, 27, 38.5, const Radius.circular(2)), ink);
    c.drawRect(const Rect.fromLTWH(18.5, 34, 2, 2), white);
    c.drawRect(const Rect.fromLTWH(23.5, 34, 2, 2), white);
  }

  /// Red horde brute, charging toward the camera.
  static void _brute(Canvas c, int f) =>
      _bruteBody(c, f, hi: const Color(0xFFFF6B5E), lo: const Color(0xFFC8182B), dark: const Color(0xFF7E1020));

  /// The giant: a darker brute with horns, a gold belt and spikes.
  static void _boss(Canvas c, int f) {
    c.save();
    c.translate(10, 16);
    // Horns.
    final horns = [
      Path()
        ..moveTo(9, 16)
        ..quadraticBezierTo(0, 4, 4, -10)
        ..quadraticBezierTo(10, 4, 16, 13)
        ..close(),
      Path()
        ..moveTo(35, 16)
        ..quadraticBezierTo(44, 4, 40, -10)
        ..quadraticBezierTo(34, 4, 28, 13)
        ..close(),
    ];
    for (final h in horns) {
      c.drawPath(h, _grad(h.getBounds(), const Color(0xFFFFF4DC), const Color(0xFFC9A36A)));
      c.drawPath(
        h,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFF7A5A2E),
      );
    }
    _bruteBody(c, f, hi: const Color(0xFFE2463F), lo: const Color(0xFF8E0F22), dark: const Color(0xFF4E0814));
    // Gold belt and buckle.
    c.drawRect(const Rect.fromLTWH(5, 40, 34, 4.5), Paint()..color = const Color(0xFFF5B82E));
    c.drawRRect(RRect.fromLTRBR(18.5, 39, 25.5, 45.5, const Radius.circular(1.5)), Paint()..color = const Color(0xFFFFE07A));
    // Shoulder spikes.
    final spike = Paint()..color = const Color(0xFF3A3F4A);
    c.drawPath(Path()..moveTo(4, 18)..lineTo(-2, 11)..lineTo(9, 14)..close(), spike);
    c.drawPath(Path()..moveTo(40, 18)..lineTo(46, 11)..lineTo(35, 14)..close(), spike);
    c.restore();
  }
}
