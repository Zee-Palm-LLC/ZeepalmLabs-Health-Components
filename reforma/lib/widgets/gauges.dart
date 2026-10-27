import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'motion.dart';

// ---------------------------------------------------------------------------
// Recovery ring: the score springs up (with a little overshoot) and the arc
// head carries a soft glow.

class RecoveryRing extends StatefulWidget {
  const RecoveryRing({super.key, required this.value, this.delay = const Duration(milliseconds: 450)});

  final int value;
  final Duration delay;

  @override
  State<RecoveryRing> createState() => _RecoveryRingState();
}

class _RecoveryRingState extends State<RecoveryRing> with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this, value: stillMode ? widget.value.toDouble() : 0);
  static final _spring = SpringDescription.withDampingRatio(mass: 1, stiffness: 36, ratio: 0.62);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.animateWith(SpringSimulation(_spring, _c.value, widget.value.toDouble(), 0));
    });
  }

  @override
  void didUpdateWidget(RecoveryRing old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _c.animateWith(SpringSimulation(_spring, _c.value, widget.value.toDouble(), _c.velocity));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(child: CustomPaint(size: const Size(120, 120), painter: _RingPainter(_c)));
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v) : super(repaint: v);

  final Animation<double> v;
  static final _label = TextPainter(
    text: TextSpan(text: 'Recovery', style: inter(11, FontWeight.w500, C.ink2)),
    textDirection: TextDirection.ltr,
  )..layout();
  static final _of = TextPainter(
    text: TextSpan(text: '/100', style: inter(11, FontWeight.w400, C.muted)),
    textDirection: TextDirection.ltr,
  )..layout();
  static final _nums = <int, TextPainter>{};

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 56.0;
    final val = v.value.clamp(0.0, 100.0);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0x99FFFFFF),
    );
    canvas.drawCircle(
      c,
      r - 6,
      Paint()..color = const Color(0x40FFFFFF),
    );
    final sweep = val / 100 * math.pi * 2;
    if (sweep > 0.01) {
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: math.pi * 2,
            colors: const [Color(0xFF4F8F82), C.teal, Color(0xFF235A50)],
            transform: const GradientRotation(-math.pi / 2),
          ).createShader(rect),
      );
      final a = -math.pi / 2 + sweep;
      final head = c + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawCircle(
        head,
        7,
        Paint()
          ..color = C.teal.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    _label.paint(canvas, Offset(c.dx - _label.width / 2, c.dy - 32));
    final n = val.round();
    final tp = _nums.putIfAbsent(
      n,
      () => TextPainter(
        text: TextSpan(text: '$n', style: inter(32, FontWeight.w500, C.ink, ls: -0.5, tabular: true)),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2 + 1));
    _of.paint(canvas, Offset(c.dx - _of.width / 2, c.dy + 20));
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}

// ---------------------------------------------------------------------------
// Progress bar that fills with spring physics after a stagger delay.

class SpringBar extends StatefulWidget {
  const SpringBar({super.key, required this.value, this.delay = Duration.zero, this.height = 4});

  final double value;
  final Duration delay;
  final double height;

  @override
  State<SpringBar> createState() => _SpringBarState();
}

class _SpringBarState extends State<SpringBar> with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this, value: stillMode ? widget.value : 0);
  static final _spring = SpringDescription.withDampingRatio(mass: 1, stiffness: 90, ratio: 0.55);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.animateWith(SpringSimulation(_spring, 0, widget.value, 0));
    });
  }

  @override
  void didUpdateWidget(SpringBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _c.animateWith(SpringSimulation(_spring, _c.value, widget.value, _c.velocity));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(double.infinity, widget.height), painter: _BarPainter(_c));
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.v) : super(repaint: v);

  final Animation<double> v;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, r), Paint()..color = C.track);
    final w = (v.value.clamp(0.0, 1.05)) * size.width;
    if (w < 1) return;
    final fr = Rect.fromLTWH(0, 0, math.min(w, size.width), size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fr, r),
      Paint()..shader = const LinearGradient(colors: [Color(0xFFB7A2F0), C.lavDeep]).createShader(fr),
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => false;
}

// ---------------------------------------------------------------------------
// Pain scale: parametric emoji faces, a spring-driven selection ring that
// glides between them, wobble + pop on the picked face, scrubbable by drag.

class Expr {
  const Expr({this.smile = 0, this.brow = 0, this.squint = 0, this.open = 0, this.tears = 0, this.tilt = 0, this.blush = 0});

  final double smile, brow, squint, open, tears, tilt, blush;

  static const levels = [
    Expr(smile: 1, open: 0.55, blush: 0.6),
    Expr(smile: -0.1, brow: 0.35, tilt: 0.9),
    Expr(smile: -0.75, brow: 0.9, squint: 0.15),
    Expr(smile: -0.9, brow: 1, open: 0.35, tears: 0.6),
    Expr(smile: -1, brow: 1, squint: 1, open: 0.9, tears: 1),
  ];

  static const labels = ['No pain', 'Mild', 'Moderate', 'High', 'Very high'];
}

class EmojiScale extends StatefulWidget {
  const EmojiScale({super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  State<EmojiScale> createState() => _EmojiScaleState();
}

class _EmojiScaleState extends State<EmojiScale> with TickerProviderStateMixin {
  static const centers = [36.0, 103.0, 173.0, 240.0, 307.0];
  late final _x = AnimationController.unbounded(vsync: this, value: centers[widget.selected]);
  late final _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 900), value: 1);
  static final _spring = SpringDescription.withDampingRatio(mass: 1, stiffness: 260, ratio: 0.68);

  @override
  void didUpdateWidget(EmojiScale old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      _x.animateWith(SpringSimulation(_spring, _x.value, centers[widget.selected], _x.velocity));
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _x.dispose();
    _pop.dispose();
    super.dispose();
  }

  int _nearest(double dx) {
    var best = 0;
    for (var i = 1; i < centers.length; i++) {
      if ((centers[i] - dx).abs() < (centers[best] - dx).abs()) best = i;
    }
    return best;
  }

  void _pick(double dx) {
    final i = _nearest(dx);
    if (i != widget.selected) {
      HapticFeedback.selectionClick();
      widget.onChanged(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _pick(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => _pick(d.localPosition.dx),
      child: RepaintBoundary(
        child: CustomPaint(
          size: const Size(double.infinity, 84),
          painter: _EmojiRowPainter(_x, _pop, widget.selected),
        ),
      ),
    );
  }
}

class _EmojiRowPainter extends CustomPainter {
  _EmojiRowPainter(this.x, this.pop, this.selected) : super(repaint: Listenable.merge([x, pop]));

  final Animation<double> x, pop;
  final int selected;
  static final _labels = <String, TextPainter>{};

  TextPainter _label(String s, bool on) => _labels.putIfAbsent(
        '$s$on',
        () => TextPainter(
          text: TextSpan(text: s, style: inter(10.5, on ? FontWeight.w500 : FontWeight.w400, on ? C.ink : C.ink2)),
          textDirection: TextDirection.ltr,
        )..layout(),
      );

  @override
  void paint(Canvas canvas, Size size) {
    const cy = 30.0;
    // Selection ring glides with spring physics.
    final rc = Offset(x.value, cy);
    canvas.drawCircle(rc, 29, Paint()..color = C.lavSoft);
    canvas.drawCircle(
      rc,
      29,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = C.lav,
    );
    final t = pop.value;
    for (var i = 0; i < 5; i++) {
      final c = Offset(_EmojiScaleState.centers[i], cy);
      final on = i == selected;
      // Damped wobble + pop on the selected face.
      final wob = on ? math.sin(t * 18) * math.exp(-t * 5) * 0.28 : 0.0;
      final sc = on ? 1 + 0.16 * math.sin(math.min(1, t * 2.2) * math.pi) * (1 - t * 0.4) : 1.0;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(wob);
      canvas.scale(sc);
      paintFace(canvas, 17, Expr.levels[i]);
      canvas.restore();
      final lp = _label(Expr.labels[i], on);
      lp.paint(canvas, Offset(c.dx - lp.width / 2, cy + 41));
    }
  }

  @override
  bool shouldRepaint(_EmojiRowPainter old) => old.selected != selected;
}

/// Draws one emoji face of radius [r] centred at the origin.
void paintFace(Canvas canvas, double r, Expr e) {
  final rect = Rect.fromCircle(center: Offset.zero, radius: r);
  canvas.drawCircle(
    const Offset(0, 1.2),
    r,
    Paint()
      ..color = const Color(0x22B07A10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
  );
  canvas.drawCircle(
    Offset.zero,
    r,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.45),
        radius: 1.05,
        colors: [Color(0xFFFFE680), Color(0xFFFFC93C), Color(0xFFF2A92A)],
        stops: [0, 0.6, 1],
      ).createShader(rect),
  );
  final k = r / 17;
  canvas.save();
  canvas.scale(k);
  const ink = Color(0xFF5A3A1C);
  final stroke = Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round;
  final fill = Paint()..color = ink;

  if (e.blush > 0) {
    final b = Paint()
      ..color = const Color(0xFFFF8A65).withValues(alpha: 0.35 * e.blush)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-9.5, 3.5), width: 5, height: 3), b);
    canvas.drawOval(Rect.fromCenter(center: const Offset(9.5, 3.5), width: 5, height: 3), b);
  }

  // Eyes.
  for (final s in [-1.0, 1.0]) {
    final ec = Offset(5.4 * s, -2.6);
    if (e.squint > 0.6) {
      // tightly shut  >  <
      final p = Path()
        ..moveTo(ec.dx - 2.6 * s, ec.dy - 2.2)
        ..lineTo(ec.dx + 1.6 * s, ec.dy)
        ..lineTo(ec.dx - 2.6 * s, ec.dy + 2.2);
      canvas.drawPath(p, stroke);
    } else {
      final h = 4.8 * (1 - e.squint * 0.6);
      canvas.drawOval(Rect.fromCenter(center: ec, width: 3.3, height: h), fill);
      canvas.drawCircle(ec + const Offset(-0.5, -1.0), 0.65, Paint()..color = Colors.white.withValues(alpha: 0.85));
    }
    // Brows: inner end lifts with worry; "Mild" raises just one.
    final lift = e.tilt > 0 ? (s > 0 ? e.brow * 1.6 : 0.0) : e.brow;
    if (lift > 0.05) {
      final inner = Offset(2.2 * s, -7.6 - lift * 1.8);
      final outer = Offset(8.4 * s, -7.0 + lift * 0.9 - (e.tilt > 0 ? 0.8 : 0));
      canvas.drawLine(inner, outer, stroke..strokeWidth = 1.3);
      stroke.strokeWidth = 1.5;
    }
  }

  // Mouth.
  final y = 6.0 + (e.smile < 0 ? 1.5 : 0);
  final w = 6.2 - e.open * 1.2;
  final skew = e.tilt * 1.3;
  if (e.open > 0.05) {
    final top = y - 1.2 + (e.smile > 0 ? -0.6 : e.open * 1.0);
    final bottom = y + e.smile * 5.2 + e.open * 4.2 * (e.smile > 0 ? 1 : 0.6);
    final p = Path()
      ..moveTo(-w, top + (e.smile < 0 ? 2.0 : 0))
      ..quadraticBezierTo(0, top - (e.smile < 0 ? e.open * 3.4 : 0), w, top + (e.smile < 0 ? 2.0 : 0))
      ..quadraticBezierTo(0, e.smile < 0 ? top + e.open * 6 : bottom + 2.2, -w, top + (e.smile < 0 ? 2.0 : 0))
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFF6B3322));
    if (e.smile > 0) {
      canvas.save();
      canvas.clipPath(p);
      canvas.drawCircle(Offset(0, bottom + 2.6), 3.4, Paint()..color = const Color(0xFFF07F7F));
      canvas.restore();
    }
  } else {
    final p = Path()
      ..moveTo(-w, y - skew)
      ..quadraticBezierTo(0, y + e.smile * 5.0, w, y + skew);
    canvas.drawPath(p, stroke);
  }

  // Tears.
  if (e.tears > 0) {
    final tear = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8FD3FF), Color(0xFF3FA5EE)],
      ).createShader(const Rect.fromLTWH(-12, -2, 24, 18));
    for (final s in [-1.0, 1.0]) {
      if (e.tears > 0.8) {
        final stream = RRect.fromRectAndRadius(Rect.fromLTWH(5.4 * s - 1.6, -0.5, 3.2, 14.5), const Radius.circular(1.6));
        canvas.drawRRect(stream, tear);
      } else if (s > 0) {
        final p = Path()
          ..moveTo(7.5, 0)
          ..quadraticBezierTo(5.2, 4.5, 7.5, 5.6)
          ..quadraticBezierTo(9.8, 4.5, 7.5, 0)
          ..close();
        canvas.drawPath(p, tear);
      }
    }
  }
  canvas.restore();
}
