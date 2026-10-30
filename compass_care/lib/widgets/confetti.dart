import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Confetti with real-ish physics: an upward cannon burst, gravity, quadratic
/// air drag, sideways flutter, and a 3D tumble (pieces flip edge-on and their
/// shading darkens with the facing angle).
class Confetti extends StatefulWidget {
  const Confetti({super.key, this.origin = const Offset(195, 120), this.count = 140});
  final Offset origin; // design units
  final int count;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _Piece {
  _Piece(math.Random r, Offset o)
    : p = o + Offset((r.nextDouble() - 0.5) * 30, (r.nextDouble() - 0.5) * 10),
      v = Offset.fromDirection(-math.pi / 2 + (r.nextDouble() - 0.5) * 2.4, 260 + r.nextDouble() * 520),
      spin = (r.nextDouble() - 0.5) * 14,
      flipSpeed = 4 + r.nextDouble() * 9,
      phase = r.nextDouble() * 6.28,
      w = 4 + r.nextDouble() * 5,
      h = 2.5 + r.nextDouble() * 4,
      round = r.nextDouble() < 0.25,
      color = _palette[r.nextInt(_palette.length)];

  Offset p, v;
  double angle = 0;
  final double spin, flipSpeed, phase, w, h;
  final bool round;
  final Color color;

  static const _palette = [
    Color(0xFFF0473A),
    Color(0xFFFFB020),
    Color(0xFF8E5CF4),
    Color(0xFF4F7CF2),
    Color(0xFF33B26B),
    Color(0xFFFF7EB0),
    Color(0xFFFFD84D),
  ];
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  final _rnd = math.Random(3);
  late final List<_Piece> _pieces = List.generate(widget.count, (_) => _Piece(_rnd, widget.origin));
  late final Ticker _ticker;
  final _t = ValueNotifier(0.0);
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = now;
    final time = now.inMicroseconds / 1e6;
    for (final c in _pieces) {
      final speed = c.v.distance;
      final drag = c.v * (-0.0026 * speed); // quadratic drag
      final flutter = Offset(math.sin(time * c.flipSpeed * 0.6 + c.phase) * 60, 0);
      c.v += (const Offset(0, 420) + drag + flutter) * dt;
      c.p += c.v * dt;
      c.angle += c.spin * dt;
      // Recycle into a gentle, endless snowfall once off-screen.
      if (c.p.dy > 900) {
        c.p = Offset(_rnd.nextDouble() * 390, -20 - _rnd.nextDouble() * 60);
        c.v = Offset((_rnd.nextDouble() - 0.5) * 40, 30);
      }
    }
    _t.value = time;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _ConfettiPainter(_pieces, _t), size: Size.infinite),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t) : super(repaint: t);
  final List<_Piece> pieces;
  final ValueNotifier<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 390;
    final paint = Paint();
    for (final c in pieces) {
      final flip = math.cos(t.value * c.flipSpeed + c.phase);
      final shade = 0.55 + 0.45 * flip.abs();
      paint.color = Color.lerp(Colors.black, c.color, shade)!;
      canvas.save();
      canvas.translate(c.p.dx * s, c.p.dy * s);
      canvas.rotate(c.angle);
      canvas.scale(s, s * flip.abs().clamp(0.08, 1));
      if (c.round) {
        canvas.drawCircle(Offset.zero, c.h * 0.8, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: c.w, height: c.h), const Radius.circular(1)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
