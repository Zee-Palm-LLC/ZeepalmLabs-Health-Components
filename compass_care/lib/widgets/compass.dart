import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme.dart';

/// The Compass Care emblem: a compass rose with a heart at its centre.
/// The needle is a damped spring that chases [heading] (radians, 0 = north,
/// clockwise), so it overshoots and settles like a real magnetised needle;
/// the heart beats with a double pulse and sends out a soft glow ring.
class CompassEmblem extends StatefulWidget {
  const CompassEmblem({super.key, required this.size, this.heading = math.pi / 4, this.spinIn = true, this.glow = true});

  final double size;
  final double heading;
  final bool spinIn;
  final bool glow;

  @override
  State<CompassEmblem> createState() => _CompassEmblemState();
}

class _CompassEmblemState extends State<CompassEmblem> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _frame = ValueNotifier(0);
  double _angle = 0, _vel = 0, _time = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Start a full turn and a half away so it whips round and settles.
    _angle = widget.spinIn ? widget.heading - math.pi * 2.6 : widget.heading;
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = now;
    _time = now.inMicroseconds / 1e6;
    final target = widget.heading + 0.045 * math.sin(_time * 1.1) + 0.02 * math.sin(_time * 2.7);
    // Semi-implicit Euler on an under-damped spring, sub-stepped for stability.
    for (var i = 0; i < 4; i++) {
      final h = dt / 4;
      _vel += ((target - _angle) * 90 - _vel * 7.5) * h;
      _angle += _vel * h;
    }
    _frame.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(size: Size.square(widget.size), painter: _CompassPainter(this)),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(this.s) : super(repaint: s._frame);
  final _CompassEmblemState s;

  /// Lub-dub: two quick pulses then rest, period 1.4 s.
  static double beat(double t) {
    final p = t % 1.4;
    double pulse(double c, double w) => math.exp(-math.pow((p - c) / w, 2).toDouble());
    return pulse(0.12, 0.06) + 0.6 * pulse(0.34, 0.07);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.34;
    final t = s._time;
    final b = beat(t);

    if (s.widget.glow) {
      canvas.drawCircle(
        c,
        r * 1.55,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFF8B7A).withValues(alpha: 0.30 + 0.12 * b),
              const Color(0x00FF8B7A),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * 1.55)),
      );
      // Echo ring emitted on each beat.
      final ph = (t % 1.4) / 1.4;
      canvas.drawCircle(
        c,
        r * (1.0 + 0.5 * ph),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.04 * (1 - ph)
          ..color = C.red.withValues(alpha: 0.35 * (1 - ph)),
      );
    }

    // Cardinal spikes.
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final dir = Offset(math.sin(a), -math.cos(a));
      final nrm = Offset(-dir.dy, dir.dx);
      final base = c + dir * r * 0.86;
      final tip = c + dir * r * 1.42;
      final w = r * 0.15;
      final half1 = Path()
        ..moveTo(base.dx + nrm.dx * w, base.dy + nrm.dy * w)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(base.dx, base.dy)
        ..close();
      final half2 = Path()
        ..moveTo(base.dx - nrm.dx * w, base.dy - nrm.dy * w)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(base.dx, base.dy)
        ..close();
      canvas.drawPath(half1, Paint()..color = const Color(0xFFF2584A));
      canvas.drawPath(half2, Paint()..color = const Color(0xFFD9392D));
    }

    // Bezel ring with a lit top edge.
    final ring = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7746A), C.red, Color(0xFFD7362A)],
        ).createShader(ring),
    );
    // Face.
    final face = Rect.fromCircle(center: c, radius: r * 0.84);
    canvas.drawCircle(
      c,
      r * 0.84,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.3),
          radius: 0.95,
          colors: [Color(0xFFFFE3DC), Color(0xFFFBB7AA), Color(0xFFF48E80)],
          stops: [0, 0.65, 1],
        ).createShader(face),
    );
    // Inner shadow on the face for depth.
    canvas.drawCircle(
      c,
      r * 0.84,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..color = const Color(0x33B02418)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.04),
    );
    // Ticks.
    final tick = Paint()
      ..color = const Color(0xFFE0493C)
      ..strokeWidth = r * 0.05
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final major = i % 3 == 0;
      final d = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(c + d * r * (major ? 0.6 : 0.66), c + d * r * 0.74, tick..strokeWidth = r * (major ? 0.055 : 0.035));
    }

    // Needle (behind heart): long north arm, short south arm, two-tone halves.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(s._angle);
    final nw = r * 0.13;
    final north = r * 1.22, south = r * 0.92;
    canvas.drawShadow(
      Path()
        ..moveTo(0, -north)
        ..lineTo(nw, 0)
        ..lineTo(0, south)
        ..lineTo(-nw, 0)
        ..close(),
      const Color(0xFF7A1A10),
      r * 0.06,
      false,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, -north)
        ..lineTo(nw, 0)
        ..lineTo(0, 0)
        ..close(),
      Paint()..color = const Color(0xFFD02F23),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, -north)
        ..lineTo(-nw, 0)
        ..lineTo(0, 0)
        ..close(),
      Paint()..color = const Color(0xFFF5675A),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, south)
        ..lineTo(nw, 0)
        ..lineTo(0, 0)
        ..close(),
      Paint()..color = const Color(0xFFE9897E),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, south)
        ..lineTo(-nw, 0)
        ..lineTo(0, 0)
        ..close(),
      Paint()..color = const Color(0xFFF6B0A6),
    );
    canvas.restore();

    // Heart, beating.
    final hs = r * 0.62 * (1 + 0.07 * b);
    final heart = heartPath(c.translate(0, r * 0.04), hs);
    canvas.drawShadow(heart, const Color(0xFF9E2216), r * 0.05, false);
    canvas.drawPath(
      heart,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD5CD), Color(0xFFF9998B)],
        ).createShader(Rect.fromCenter(center: c, width: hs, height: hs)),
    );
    canvas.drawPath(
      heart,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFE8473A),
    );
    // Specular glint on the heart.
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(-hs * 0.2, -hs * 0.18), width: hs * 0.22, height: hs * 0.12),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, hs * 0.03),
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) => false;
}

/// A plump, symmetric heart centred on [c] with overall width [w].
Path heartPath(Offset c, double w) {
  final h = w * 0.9;
  final top = c.dy - h * 0.42;
  return Path()
    ..moveTo(c.dx, top + h * 0.2)
    ..cubicTo(c.dx - w * 0.08, top - h * 0.05, c.dx - w * 0.5, top - h * 0.05, c.dx - w * 0.5, top + h * 0.3)
    ..cubicTo(c.dx - w * 0.5, top + h * 0.58, c.dx - w * 0.18, top + h * 0.76, c.dx, top + h * 0.95)
    ..cubicTo(c.dx + w * 0.18, top + h * 0.76, c.dx + w * 0.5, top + h * 0.58, c.dx + w * 0.5, top + h * 0.3)
    ..cubicTo(c.dx + w * 0.5, top - h * 0.05, c.dx + w * 0.08, top - h * 0.05, c.dx, top + h * 0.2)
    ..close();
}
