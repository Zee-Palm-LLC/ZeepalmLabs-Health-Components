import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/palette.dart';

class FaceShape {
  const FaceShape(this.squint, this.mouth, this.open, this.brow);

  final double squint;
  final double mouth;
  final double open;
  final double brow;

  static const table = [
    FaceShape(0.00, -0.82, 0.00, 0.00),
    FaceShape(0.70, -0.38, 0.00, 1.00),
    FaceShape(0.90, 0.42, 0.00, 0.00),
    FaceShape(0.06, 0.86, 0.00, 0.00),
    FaceShape(0.94, 1.00, 1.00, 0.00),
  ];

  static FaceShape lerpShape(FaceShape a, FaceShape b, double t) => FaceShape(
    lerp(a.squint, b.squint, t),
    lerp(a.mouth, b.mouth, t),
    lerp(a.open, b.open, t),
    lerp(a.brow, b.brow, t),
  );
}

class MoodFace extends StatelessWidget {
  const MoodFace({
    super.key,
    required this.index,
    required this.selection,
    required this.seconds,
    this.size = 34,
  });

  final int index;
  final double selection;
  final double seconds;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size * 2.1,
      child: CustomPaint(
        painter: _FacePainter(index: index, selection: selection, seconds: seconds, base: size),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter({required this.index, required this.selection, required this.seconds, required this.base});

  final int index;
  final double selection;
  final double seconds;
  final double base;

  double _blink() {
    final phase = (seconds * 0.42 + index * 0.37) % 1.0;
    if (phase > 0.965) return math.sin((phase - 0.965) / 0.035 * math.pi);
    return 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final bob = math.sin((seconds * 0.9 + index * 1.3)) * 0.9 * (1 - selection * 0.5);
    final r = base / 2 * (1 + 0.33 * selection);
    final at = centre + Offset(0, bob - 3.0 * selection);

    if (selection > 0.01) {
      final glow = 0.72 + 0.28 * math.sin(seconds * 2.1);
      canvas.drawCircle(
        at,
        r * (1.85 + 0.12 * glow),
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            at,
            r * 2.0,
            [
              Ember.gold.withValues(alpha: 0.42 * selection * glow),
              Ember.amber.withValues(alpha: 0.14 * selection),
              const Color(0x00000000),
            ],
            const [0.0, 0.45, 1.0],
          ),
      );
      canvas.drawCircle(
        at,
        r * 1.34,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = Ember.gold.withValues(alpha: 0.30 * selection),
      );
    }

    canvas.drawCircle(
      at.translate(0, r * 0.16),
      r * 0.98,
      Paint()
        ..color = const Color(0x59000000)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawCircle(
      at,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          at.translate(-r * 0.32, -r * 0.38),
          r * 1.55,
          const [Color(0xFFFFE289), Color(0xFFFFC53F), Color(0xFFF09A1E), Color(0xFFD97C12)],
          const [0.0, 0.34, 0.74, 1.0],
        ),
    );
    canvas.drawCircle(
      at,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = const Color(0x40FFF0C0),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: at, radius: r)));
    canvas.drawOval(
      Rect.fromCenter(center: at.translate(-r * 0.30, -r * 0.46), width: r * 0.72, height: r * 0.44),
      Paint()
        ..color = const Color(0x8CFFFFFF)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 2.6),
    );
    canvas.restore();

    final blink = _blink();
    final shape = FaceShape.lerpShape(FaceShape.table[index], const FaceShape(1.0, 0, 0, 0), blink * 0.9);

    final ink = Paint()
      ..color = const Color(0xFF5E3103)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.145
      ..strokeCap = StrokeCap.round;

    for (final sign in [-1.0, 1.0]) {
      final eye = at + Offset(sign * r * 0.38, -r * 0.16);
      if (shape.squint < 0.42) {
        final open = 1 - shape.squint / 0.42;
        canvas.drawOval(
          Rect.fromCenter(center: eye, width: r * 0.24, height: r * 0.26 * open + r * 0.06),
          Paint()..color = const Color(0xFF5E3103),
        );
      } else {
        final w = r * 0.30;
        final lift = r * 0.28 * (shape.squint - 0.42) / 0.58;
        final dip = shape.brow > 0.5 ? -lift : lift;
        canvas.drawPath(
          Path()
            ..moveTo(eye.dx - w, eye.dy + dip * 0.55)
            ..quadraticBezierTo(eye.dx, eye.dy - dip, eye.dx + w, eye.dy + dip * 0.55),
          ink,
        );
      }
    }

    final mouthW = r * (0.36 + 0.30 * shape.open + 0.10 * shape.mouth.abs());
    final mouthY = at.dy + r * 0.34;
    final bend = r * 0.44 * shape.mouth;
    if (shape.open > 0.35) {
      final mouth = Path()
        ..moveTo(at.dx - mouthW, mouthY - r * 0.10)
        ..quadraticBezierTo(at.dx, mouthY + bend * 1.6, at.dx + mouthW, mouthY - r * 0.10)
        ..quadraticBezierTo(at.dx, mouthY + bend * 0.18, at.dx - mouthW, mouthY - r * 0.10)
        ..close();
      canvas.drawPath(mouth, Paint()..color = const Color(0xFF5E3103));
      canvas.save();
      canvas.clipPath(mouth);
      canvas.drawRect(
        Rect.fromLTWH(at.dx - mouthW, mouthY - r * 0.16, mouthW * 2, r * 0.15),
        Paint()..color = const Color(0xFFFFF6E4),
      );
      canvas.restore();
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(at.dx - mouthW, mouthY - bend * 0.45)
          ..quadraticBezierTo(at.dx, mouthY + bend, at.dx + mouthW, mouthY - bend * 0.45),
        ink,
      );
    }
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      old.selection != selection || old.seconds != seconds || old.index != index;
}
