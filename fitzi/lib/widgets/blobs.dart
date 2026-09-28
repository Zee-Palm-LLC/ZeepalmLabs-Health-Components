import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../core/motion.dart';

class Blob {
  const Blob({
    required this.center,
    required this.radii,
    required this.colors,
    required this.stops,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.wobble = 0.035,
    this.speed = 1,
    this.seed = 0,
    this.drift = const Offset(4, 6),
    this.soft = 0,
    this.delay = 0,
  });

  final Offset center;
  final Size radii;
  final List<Color> colors;
  final List<double> stops;
  final Alignment begin;
  final Alignment end;
  final double wobble;
  final double speed;
  final double seed;
  final Offset drift;
  final double soft;
  final double delay;
}

class BlobField extends StatelessWidget {
  const BlobField({super.key, required this.blobs, required this.entrance, this.parallax = Offset.zero});

  final List<Blob> blobs;
  final Animation<double> entrance;
  final Offset parallax;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, _) => CustomPaint(
        painter: _BlobPainter(blobs, seconds, entrance, parallax),
        size: Size.infinite,
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.blobs, this.seconds, this.entrance, this.parallax) : super(repaint: entrance);

  final List<Blob> blobs;
  final double seconds;
  final Animation<double> entrance;
  final Offset parallax;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < blobs.length; i++) {
      final b = blobs[i];
      final grow = spring(span(entrance.value, b.delay, b.delay + 0.55, Curves.linear), bounce: 0.25, freq: 2.4);
      if (grow <= 0) continue;
      final t = seconds * b.speed;
      final depth = 0.4 + 0.6 * (i % 3) / 2;
      final c = b.center +
          Offset(math.sin(t * 0.37 + b.seed) * b.drift.dx, math.cos(t * 0.29 + b.seed * 1.7) * b.drift.dy) +
          parallax * depth;
      final path = _shape(c, b.radii * grow, t, b);
      final rect = Rect.fromCenter(center: c, width: b.radii.width * 2, height: b.radii.height * 2);
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          b.begin.withinRect(rect),
          b.end.withinRect(rect),
          b.colors,
          b.stops,
        );
      if (b.soft > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, b.soft);
      canvas.drawPath(path, paint);
    }
  }

  Path _shape(Offset c, Size r, double t, Blob b) {
    const n = 48;
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2;
      final w = 1 +
          b.wobble * math.sin(3 * a + t * 0.9 + b.seed) +
          b.wobble * 0.6 * math.sin(5 * a - t * 1.3 + b.seed * 2.1) +
          b.wobble * 0.4 * math.cos(2 * a + t * 0.6 + b.seed * 0.7);
      pts.add(c + Offset(math.cos(a) * r.width * w, math.sin(a) * r.height * w));
    }
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 0; i < n; i++) {
      final p0 = pts[(i - 1 + n) % n];
      final p1 = pts[i];
      final p2 = pts[(i + 1) % n];
      final p3 = pts[(i + 2) % n];
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.seconds != seconds || old.parallax != parallax;
}
