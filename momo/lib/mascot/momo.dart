import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/palette.dart';

enum Mood { idle, think, talk, happy, curious }

class Pose {
  const Pose({
    this.blink = 0,
    this.look = Offset.zero,
    this.mouth = 0,
    this.smile = 1,
    this.squash = 0,
    this.lean = 0,
    this.wave = 0,
    this.sway = 0,
    this.brow = 0,
    this.hop = 0,
    this.arms = 0,
  });

  final double blink;
  final Offset look;
  final double mouth;
  final double smile;
  final double squash;
  final double lean;
  final double wave;
  final double sway;
  final double brow;
  final double hop;
  final double arms;
}

class Gaze {
  static final pointer = ValueNotifier<Offset?>(null);
}

class Momo extends StatefulWidget {
  const Momo({super.key, this.mood = Mood.idle, this.squash = 0, this.lean = 0, this.wave = 0, this.shadow = 1, this.excite = 0});

  final Mood mood;
  final double squash;
  final double lean;
  final double wave;
  final double shadow;
  final double excite;

  static const artboard = Size(180, 200);

  @override
  State<Momo> createState() => _MomoState();
}

class _MomoState extends State<Momo> {
  Offset _look = Offset.zero;
  double _talk = 0;
  double _last = 0;

  Offset _gazeTarget(double t) {
    final pointer = Gaze.pointer.value;
    final box = context.findRenderObject() as RenderBox?;
    if (widget.mood == Mood.think) return Offset(0.55 + 0.12 * wave(t, 3.1), -0.7);
    if (widget.mood == Mood.curious) return const Offset(-0.35, 0.55);
    if (pointer != null && box != null && box.attached && box.hasSize) {
      final center = box.localToGlobal(box.size.center(Offset.zero));
      final scale = box.getTransformTo(null).getMaxScaleOnAxis();
      final d = (pointer - center) / (scale * 120);
      final len = d.distance;
      return len > 1 ? d / len : d;
    }
    return Offset(0.28 * wave(t, 7.3, 0), 0.12 * wave(t, 5.1, 0));
  }

  Pose _pose(double t) {
    final dt = (t - _last).clamp(0.0, 0.1);
    _last = t;
    final target = _gazeTarget(t);
    final k = 1 - math.exp(-dt * 9);
    _look = Offset.lerp(_look, target, dt == 0 ? 1 : k)!;
    final talking = widget.mood == Mood.talk;
    _talk = lerp(_talk, talking ? 1 : 0, dt == 0 ? (talking ? 1 : 0) : 1 - math.exp(-dt * 10));
    final cycle = t % 4.6;
    var blink = 0.0;
    if (cycle > 4.42) blink = math.sin((cycle - 4.42) / 0.18 * math.pi);
    final second = (t + 2.3) % 9.2;
    if (second > 9.02) blink = math.max(blink, math.sin((second - 9.02) / 0.18 * math.pi));
    final happy = widget.mood == Mood.happy;
    final mouth = _talk * (0.28 + 0.5 * (0.5 + 0.5 * math.sin(t * 15.0)) * (0.6 + 0.4 * math.sin(t * 4.3)).abs());
    final hop = happy ? (wave(t, 0.62).abs() * -5) : 0.0;
    return Pose(
      blink: blink.clamp(0.0, 1.0),
      look: _look,
      mouth: mouth,
      smile: happy ? 1.35 : 1,
      squash: widget.squash + 0.018 * wave(t, 2.8) + (happy ? 0.05 * wave(t, 0.31) : 0),
      lean: widget.lean + 0.025 * wave(t, 5.6),
      wave: widget.wave,
      sway: 0.09 * wave(t, 3.4) + 0.05 * wave(t, 1.3),
      brow: widget.mood == Mood.think ? 1 : (happy ? -0.4 : 0),
      hop: hop,
      arms: wave(t, 2.8) * 0.5 + widget.excite,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, t, _) => CustomPaint(
        painter: MomoPainter(_pose(t), shadow: widget.shadow),
        size: Size.infinite,
      ),
    );
  }
}

class MomoPainter extends CustomPainter {
  MomoPainter(this.pose, {this.shadow = 1});

  final Pose pose;
  final double shadow;

  static final Path body = Path()
    ..moveTo(90, 42)
    ..cubicTo(102, 27, 139, 24, 153, 51)
    ..cubicTo(167, 76, 166, 125, 148, 152)
    ..cubicTo(132, 174, 112, 182, 90, 182)
    ..cubicTo(68, 182, 48, 174, 32, 152)
    ..cubicTo(14, 125, 13, 76, 27, 51)
    ..cubicTo(41, 24, 78, 27, 90, 42)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / Momo.artboard.width, size.height / Momo.artboard.height);
    canvas.save();
    canvas.translate((size.width - Momo.artboard.width * s) / 2, (size.height - Momo.artboard.height * s) / 2);
    canvas.scale(s);
    _shadow(canvas);
    canvas.save();
    final sx = 1 + pose.squash;
    final sy = 1 - pose.squash;
    canvas.translate(90, 188 + pose.hop);
    canvas.rotate(pose.lean);
    canvas.scale(sx, sy);
    canvas.translate(-90, -188);
    _feet(canvas);
    _arm(canvas, left: true);
    if (pose.wave < 0.25) _arm(canvas, left: false);
    _leaf(canvas);
    _body(canvas);
    _face(canvas);
    if (pose.wave >= 0.25) _arm(canvas, left: false);
    canvas.restore();
    canvas.restore();
  }

  void _shadow(Canvas canvas) {
    if (shadow <= 0) return;
    final spread = 1 + pose.hop * 0.03;
    final paint = Paint()
      ..color = const Color(0xFF3A2A1A).withValues(alpha: 0.2 * shadow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5);
    canvas.drawOval(Rect.fromCenter(center: const Offset(90, 191), width: 124 * spread, height: 14 * spread), paint);
  }

  void _feet(Canvas canvas) {
    for (final x in [71.0, 109.0]) {
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, 183), width: 27, height: 15), const Radius.circular(7.5));
      canvas.drawRRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Shade.shoe, Shade.shoeDeep],
          ).createShader(r.outerRect),
      );
      final sole = RRect.fromRectAndRadius(Rect.fromLTWH(x - 13.5, 186.5, 27, 4), const Radius.circular(2));
      canvas.drawRRect(sole, Paint()..color = const Color(0xFFF4F1E8));
    }
  }

  void _arm(Canvas canvas, {required bool left}) {
    canvas.save();
    final pivot = left ? const Offset(26, 112) : const Offset(154, 112);
    canvas.translate(pivot.dx, pivot.dy);
    final rest = left ? 0.32 + pose.arms * 0.08 : -0.32 - pose.arms * 0.08;
    final raise = left ? 0.0 : -2.1 * pose.wave;
    canvas.rotate(rest + raise);
    final arm = Rect.fromCenter(center: Offset(left ? -6 : 6, 12), width: 21, height: 30);
    canvas.drawOval(
      arm,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [Shade.apricot, Shade.peach, Shade.coral],
          stops: [0, 0.55, 1],
        ).createShader(arm),
    );
    canvas.drawOval(
      arm,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Shade.ember.withValues(alpha: 0.28),
    );
    canvas.restore();
  }

  void _leaf(Canvas canvas) {
    canvas.save();
    canvas.translate(91, 36);
    canvas.rotate(pose.sway);
    canvas.translate(-91, -36);
    final stem = Path()
      ..moveTo(90, 44)
      ..quadraticBezierTo(89, 33, 94, 22);
    canvas.drawPath(
      stem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF7A5236),
    );
    final big = Path()
      ..moveTo(94, 25)
      ..cubicTo(102, 7, 124, -1, 140, 7)
      ..cubicTo(132, 23, 110, 32, 94, 25)
      ..close();
    canvas.drawPath(
      big,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(96, 24), const Offset(138, 6), [Shade.leafDeep, Shade.leaf, const Color(0xFF8CCB6E)], [0, 0.55, 1]),
    );
    final rib = Path()
      ..moveTo(97, 23)
      ..quadraticBezierTo(116, 12, 134, 8);
    canvas.drawPath(
      rib,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFBFE3A6).withValues(alpha: 0.75),
    );
    final small = Path()
      ..moveTo(91, 31)
      ..cubicTo(84, 20, 70, 17, 61, 22)
      ..cubicTo(68, 32, 82, 35, 91, 31)
      ..close();
    canvas.drawPath(
      small,
      Paint()..shader = ui.Gradient.linear(const Offset(90, 30), const Offset(62, 21), [Shade.leafDeep, Shade.leaf], [0, 1]),
    );
    canvas.restore();
  }

  void _body(Canvas canvas) {
    final bounds = body.getBounds();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.32, -0.42),
          radius: 0.95,
          colors: [Color(0xFFFFEACB), Shade.apricot, Shade.peach, Shade.coral],
          stops: [0, 0.3, 0.68, 1],
        ).createShader(bounds),
    );
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.62, -0.05),
          radius: 0.62,
          colors: [Shade.blush.withValues(alpha: 0.5), Shade.blush.withValues(alpha: 0)],
        ).createShader(bounds),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 112),
          const Offset(0, 184),
          [const Color(0x00D9583F), const Color(0x47D9583F)],
          [0, 1],
        ),
    );
    final crease = Path()
      ..moveTo(90, 43)
      ..cubicTo(80, 56, 76, 72, 79, 88);
    canvas.drawPath(
      crease,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(const Offset(90, 43), const Offset(79, 88), [Shade.ember.withValues(alpha: 0.5), Shade.ember.withValues(alpha: 0)], [0, 1])
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );
    final glint = Path()
      ..moveTo(94, 45)
      ..cubicTo(86, 57, 83, 70, 85, 82);
    canvas.drawPath(
      glint,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(const Offset(94, 45), const Offset(85, 82), [Colors.white.withValues(alpha: 0.45), Colors.white.withValues(alpha: 0)], [0, 1]),
    );
    canvas.save();
    canvas.translate(50, 66);
    canvas.rotate(-0.62);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 34, height: 17),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );
    canvas.restore();
    canvas.drawCircle(const Offset(63, 52), 3.2, Paint()..color = Colors.white.withValues(alpha: 0.75));
    final freckle = Paint()..color = Shade.ember.withValues(alpha: 0.28);
    for (final p in const [Offset(140, 86), Offset(146, 98), Offset(136, 140), Offset(40, 146), Offset(118, 166)]) {
      canvas.drawCircle(p, 1.3, freckle);
    }
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.white.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.restore();
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = Shade.ember.withValues(alpha: 0.32),
    );
  }

  void _face(Canvas canvas) {
    final blush = Paint()
      ..color = const Color(0xFFFF6F7C).withValues(alpha: 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(Rect.fromCenter(center: const Offset(51, 124), width: 20, height: 11), blush);
    canvas.drawOval(Rect.fromCenter(center: const Offset(129, 124), width: 20, height: 11), blush);
    final shift = Offset(pose.look.dx * 2.2, pose.look.dy * 1.6);
    _eye(canvas, const Offset(70, 101) + shift * 0.6, left: true);
    _eye(canvas, const Offset(110, 101) + shift * 0.6, left: false);
    _brows(canvas, shift);
    _mouth(canvas, shift * 0.7);
  }

  void _eye(Canvas canvas, Offset c, {required bool left}) {
    final open = 1 - pose.blink;
    if (open < 0.12) {
      final lid = Path()
        ..moveTo(c.dx - 10, c.dy + 1)
        ..quadraticBezierTo(c.dx, c.dy + 7, c.dx + 10, c.dy + 1);
      canvas.drawPath(
        lid,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round
          ..color = Shade.eye,
      );
      return;
    }
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(1, open);
    final white = Rect.fromCenter(center: Offset.zero, width: 29.5, height: 36);
    canvas.drawOval(
      white.translate(0, 1.2),
      Paint()
        ..color = Shade.ember.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.drawOval(
      white,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.3),
          radius: 0.8,
          colors: [Colors.white, Color(0xFFFFF7EC)],
        ).createShader(white),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(white));
    final p = Offset(pose.look.dx * 4.6, pose.look.dy * 5.4 + 2.2);
    final pupil = Rect.fromCenter(center: p, width: 15, height: 20.5);
    canvas.drawOval(pupil, Paint()..color = Shade.eye);
    canvas.drawCircle(p + const Offset(-2.4, -4.2), 2.6, Paint()..color = Colors.white);
    canvas.drawCircle(p + const Offset(2.6, 3.6), 1.2, Paint()..color = Colors.white.withValues(alpha: 0.85));
    canvas.restore();
    canvas.drawOval(
      white,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Shade.ember.withValues(alpha: 0.3),
    );
    canvas.restore();
  }

  void _brows(Canvas canvas, Offset shift) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFB4553D).withValues(alpha: 0.75);
    final lift = pose.brow;
    final l = Path()
      ..moveTo(62 + shift.dx, 81 + shift.dy - lift * 1.5)
      ..quadraticBezierTo(70 + shift.dx, 77 + shift.dy - lift * 2, 78 + shift.dx, 80 + shift.dy - lift * 1);
    final r = Path()
      ..moveTo(102 + shift.dx, 80 + shift.dy - lift * 4)
      ..quadraticBezierTo(110 + shift.dx, 76 + shift.dy - lift * 6, 118 + shift.dx, 80 + shift.dy - lift * 4.5);
    canvas.drawPath(l, paint);
    canvas.drawPath(r, paint);
  }

  void _mouth(Canvas canvas, Offset shift) {
    final c = const Offset(90, 128) + shift;
    final o = pose.mouth.clamp(0.0, 1.0);
    final w = 11.0 + 1.5 * (pose.smile - 1) * 4;
    if (o < 0.04) {
      final smile = Path()
        ..moveTo(c.dx - w, c.dy - 1)
        ..quadraticBezierTo(c.dx, c.dy + 9 * pose.smile, c.dx + w, c.dy - 1);
      canvas.drawPath(
        smile,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.1
          ..strokeCap = StrokeCap.round
          ..color = Shade.mouth,
      );
      return;
    }
    final depth = 5 + 11 * o;
    final shape = Path()
      ..moveTo(c.dx - w, c.dy - 1)
      ..quadraticBezierTo(c.dx, c.dy + 2, c.dx + w, c.dy - 1)
      ..quadraticBezierTo(c.dx + w * 0.8, c.dy + depth, c.dx, c.dy + depth)
      ..quadraticBezierTo(c.dx - w * 0.8, c.dy + depth, c.dx - w, c.dy - 1)
      ..close();
    canvas.drawPath(shape, Paint()..color = Shade.mouth);
    canvas.save();
    canvas.clipPath(shape);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx + 1, c.dy + depth - 1), width: w * 1.2, height: depth * 0.7),
      Paint()..color = const Color(0xFFFF8A86),
    );
    canvas.restore();
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = Shade.mouth,
    );
  }

  @override
  bool shouldRepaint(MomoPainter old) => true;
}
