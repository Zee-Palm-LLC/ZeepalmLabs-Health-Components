import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Everything the candle scene needs for one frame.
class CandleState {
  const CandleState({
    required this.t,
    required this.height,
    required this.burn,
    required this.flame,
    required this.warm,
    required this.smokeAge,
    required this.sparkAge,
  });

  final double t; // seconds, for flicker
  final double height; // 0 (stub) … 1 (fresh candle)
  final double burn; // 0 … 1 how far this candle has burnt (drips grow)
  final double flame; // 0 out … 1 full flame
  final double warm; // 0 cold grey wax / dark room … 1 lit
  final double smokeAge; // seconds since the flame went out (< 0: none)
  final double sparkAge; // seconds since relight (< 0: none)
}

// Scene layout on the 390 × 844 canvas.
const _cx = 195.0;
const tableTop = 440.0;
const _base = 466.0;
const _w = 104.0;
const _fullH = 218.0, _minH = 38.0;

/// The warm room, wooden table, brass dish and the wax candle itself, with
/// its pool, drips, wick, flame, glow and smoke.
class CandlePainter extends CustomPainter {
  CandlePainter(this.s);
  final CandleState s;

  double get _h => _minH + (_fullH - _minH) * s.height;
  double get _top => _base - _h;
  Offset get _wick => Offset(_cx + 1, _top - 2);

  /// Flicker: a couple of incommensurate sines read as natural.
  double _n(double k) => math.sin(s.t * 7.3 * k) * 0.5 + math.sin(s.t * 12.9 * k + 1.3) * 0.3 + math.sin(s.t * 3.1 * k + 2.1) * 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    final light = s.warm * (0.86 + 0.14 * s.flame) * (1 + 0.05 * _n(1) * s.flame);
    _room(canvas, size, light);
    _table(canvas, size, light);
    _candle(canvas, light);
    if (s.flame > 0.01) _flame(canvas);
    if (s.smokeAge >= 0 && s.smokeAge < 4) _smoke(canvas);
    if (s.sparkAge >= 0 && s.sparkAge < 0.6) _spark(canvas);
  }

  void _room(Canvas c, Size size, double light) {
    final r = Offset.zero & size;
    c.drawRect(r, Paint()..color = Color.lerp(const Color(0xFF0D0B0A), const Color(0xFF140C06), s.warm)!);
    final glowC = Offset(_cx, _top - 30);
    c.drawCircle(
      glowC,
      420,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF8A4A1A).withValues(alpha: 0.75 * light),
          const Color(0xFF4A260C).withValues(alpha: 0.45 * light),
          const Color(0xFF1A0E06).withValues(alpha: 0),
        ], stops: const [0, 0.45, 1]).createShader(Rect.fromCircle(center: glowC, radius: 420)),
    );
  }

  void _table(Canvas c, Size size, double light) {
    final r = Rect.fromLTRB(0, tableTop, size.width, size.height);
    c.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF221D19), const Color(0xFF3A2414), light)!,
            Color.lerp(const Color(0xFF141110), const Color(0xFF1C110A), light)!,
            const Color(0xFF0B0907),
          ],
          stops: const [0, 0.4, 1],
        ).createShader(r),
    );
    // Wood grain.
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.18);
    for (var i = 0; i < 14; i++) {
      final y = tableTop + 10 + i * 12.0 + (i * i % 5);
      final p = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 30) {
        p.lineTo(x, y + math.sin(x * 0.02 + i * 1.7) * 2.2);
      }
      c.drawPath(p, grain);
    }
    // Front edge highlight.
    c.drawRect(Rect.fromLTWH(0, tableTop, size.width, 1.5), Paint()..color = const Color(0xFFFFC27A).withValues(alpha: 0.18 * light + 0.04));
    // Pool of light on the table.
    final pool = Rect.fromCenter(center: const Offset(_cx, _base + 6), width: 360, height: 90);
    c.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFA14A).withValues(alpha: 0.32 * light),
          const Color(0xFFFFA14A).withValues(alpha: 0),
        ]).createShader(pool),
    );
  }

  void _candle(Canvas c, double light) {
    final left = _cx - _w / 2, right = _cx + _w / 2;
    // Brass dish.
    final dish = Rect.fromCenter(center: const Offset(_cx, _base + 2), width: 150, height: 20);
    c.drawOval(dish.shift(const Offset(0, 4)), Paint()..color = Colors.black.withValues(alpha: 0.45)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    c.drawOval(
      dish,
      Paint()
        ..shader = LinearGradient(colors: [
          Color.lerp(const Color(0xFF5A4A2A), const Color(0xFF8A5E1E), light)!,
          Color.lerp(const Color(0xFF9C8650), const Color(0xFFF2C063), light)!,
          Color.lerp(const Color(0xFF5A4A2A), const Color(0xFF7A4E14), light)!,
        ]).createShader(dish),
    );
    c.drawOval(dish.deflate(5).shift(const Offset(0, -1)), Paint()..color = Color.lerp(const Color(0xFF3A3020), const Color(0xFF6A440E), light)!);

    // Wax body: cylindrical shading, warm near the flame when lit.
    final body = Rect.fromLTRB(left, _top, right, _base);
    final cold = [const Color(0xFF5E5A54), const Color(0xFF8E8A82), const Color(0xFFA29E95), const Color(0xFF7C786F), const Color(0xFF4C4943)];
    final hot = [const Color(0xFFB9A88E), const Color(0xFFF5EBD8), const Color(0xFFFFFBF0), const Color(0xFFE7DAC2), const Color(0xFF9C8A70)];
    final cols = [for (var i = 0; i < 5; i++) Color.lerp(cold[i], hot[i], s.warm)!];
    c.drawRect(
      body,
      Paint()..shader = LinearGradient(colors: cols, stops: const [0, 0.3, 0.45, 0.72, 1]).createShader(body),
    );
    // Warm translucency glowing down from the flame.
    c.drawRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFFC77A).withValues(alpha: 0.55 * light * s.flame), const Color(0x00FFC77A)],
        ).createShader(Rect.fromLTRB(left, _top, right, _top + 70)),
    );
    // Drips running down the front, growing as the candle burns.
    final drip = Paint()..color = Color.lerp(const Color(0xFFA6A198), const Color(0xFFFFF8EA), s.warm)!;
    const drips = [(-0.27, 0.6, 5.5), (0.12, 1.0, 6.5)];
    for (final (fx, k, wd) in drips) {
      final len = math.min(_h - 14, 8 + 50 * k * s.burn);
      final x = _cx + fx * _w;
      c.drawRRect(RRect.fromLTRBR(x - wd / 2, _top + 2, x + wd / 2, _top + len, Radius.circular(wd / 2)), drip);
      c.drawCircle(Offset(x, _top + len - 1), wd * 0.62, drip);
    }
    // Top: rim and the melted pool.
    final rim = Rect.fromCenter(center: Offset(_cx, _top), width: _w, height: 16);
    c.drawOval(rim, Paint()..color = Color.lerp(const Color(0xFF9C978E), const Color(0xFFFFF6E6), s.warm)!);
    final poolR = rim.deflate(5);
    c.drawOval(
      poolR,
      Paint()
        ..shader = RadialGradient(colors: [
          Color.lerp(const Color(0xFF6E6A62), const Color(0xFFFFD58A), s.warm * s.flame)!,
          Color.lerp(const Color(0xFF85817A), const Color(0xFFF2D7AC), s.warm)!,
        ]).createShader(poolR),
    );
    // Wick.
    final wick = Path()
      ..moveTo(_cx, _top + 1)
      ..quadraticBezierTo(_cx + 1, _top - 6, _wick.dx, _wick.dy - 6);
    c.drawPath(
      wick,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF1A120C),
    );
    if (s.flame > 0.05 || (s.smokeAge >= 0 && s.smokeAge < 1.2)) {
      final ember = s.flame > 0.05 ? 1.0 : (1 - s.smokeAge / 1.2);
      c.drawCircle(Offset(_wick.dx, _wick.dy - 6), 1.8, Paint()..color = const Color(0xFFFF7A2E).withValues(alpha: ember));
    }
  }

  void _flame(Canvas c) {
    final f = s.flame;
    final sway = _n(0.8) * 2.2 * f;
    final h = (40 + 4 * _n(1.4)) * f;
    final w = 15.0 * (0.6 + 0.4 * f);
    final base = Offset(_wick.dx, _wick.dy - 2);
    final tip = Offset(base.dx + sway, base.dy - h);
    Path drop(double sw, double sh) => Path()
      ..moveTo(base.dx, base.dy + 4 * sh)
      ..cubicTo(base.dx - w * sw, base.dy, base.dx - w * 0.55 * sw, base.dy - h * 0.55 * sh, tip.dx, base.dy - h * sh)
      ..cubicTo(base.dx + w * 0.55 * sw, base.dy - h * 0.55 * sh, base.dx + w * sw, base.dy, base.dx, base.dy + 4 * sh)
      ..close();

    // Halo.
    c.drawCircle(
      base - Offset(0, h * 0.45),
      70 * f,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFC46B).withValues(alpha: 0.45),
          const Color(0xFFFF8A2B).withValues(alpha: 0.12),
          const Color(0x00FF8A2B),
        ], stops: const [0, 0.4, 1]).createShader(Rect.fromCircle(center: base - Offset(0, h * 0.45), radius: 70 * f)),
    );
    final outer = drop(1, 1);
    final bounds = outer.getBounds();
    c.drawPath(
      outer,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5)
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0x553A6BFF), Color(0xFFFFB03A), Color(0xFFFF8A1F), Color(0x00FF6A00)],
          stops: [0, 0.25, 0.7, 1],
        ).createShader(bounds),
    );
    c.drawPath(
      drop(0.55, 0.72),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0x00FFFFFF), Color(0xFFFFFDF0), Color(0xFFFFE9A8)],
          stops: [0, 0.35, 1],
        ).createShader(bounds),
    );
  }

  void _smoke(Canvas c) {
    final a = s.smokeAge;
    for (var k = 0; k < 3; k++) {
      final local = a - k * 0.35;
      if (local <= 0) continue;
      final rise = local * 46;
      final fade = (1 - local / 3.2).clamp(0.0, 1.0) * math.min(1, local * 3);
      for (var i = 0; i < 26; i++) {
        final y = i * 6.0;
        if (y > rise) break;
        final x = math.sin(y * 0.045 + local * 1.6 + k * 2) * (4 + y * 0.12) + k * 3;
        final p = Offset(_wick.dx + x, _wick.dy - 8 - y);
        c.drawCircle(
          p,
          2.5 + y * 0.06,
          Paint()
            ..color = const Color(0xFFD8D2CA).withValues(alpha: 0.16 * fade * (1 - y / 160))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  void _spark(Canvas c) {
    final k = s.sparkAge / 0.6;
    for (var i = 0; i < 9; i++) {
      final a = -math.pi / 2 + (i - 4) * 0.32;
      final d = 6 + 34 * Curves.easeOut.transform(k);
      final p = _wick + Offset(math.cos(a) * d, math.sin(a) * d - 6);
      c.drawCircle(p, 1.8 * (1 - k), Paint()..color = const Color(0xFFFFD27A).withValues(alpha: 1 - k));
    }
  }

  @override
  bool shouldRepaint(CandlePainter old) => true;
}
