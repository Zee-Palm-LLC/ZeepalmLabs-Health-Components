import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'clock.dart';

class StreamLine {
  const StreamLine({
    required this.from,
    required this.to,
    required this.color,
    required this.level,
    required this.progress,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final double level;
  final double progress;
}

class StreamsPainter extends CustomPainter {
  StreamsPainter(this.lines) : super(repaint: SceneClock.instance);

  final List<StreamLine> lines;

  static Path pathFor(Offset a, Offset b, int index) {
    final dx = b.dx - a.dx;
    final drop = b.dy - a.dy;
    final p = Path()..moveTo(a.dx, a.dy);
    final side = dx.abs() > 60;
    if (side) {
      p.cubicTo(
        a.dx + dx * 0.02,
        a.dy + drop * 0.22,
        a.dx + dx * 0.18,
        a.dy + drop * 0.3,
        a.dx + dx * 0.5,
        a.dy + drop * 0.34,
      );
      p.cubicTo(
        a.dx + dx * 0.86,
        a.dy + drop * 0.38,
        b.dx - dx * 0.05,
        a.dy + drop * 0.55,
        b.dx,
        b.dy,
      );
    } else {
      p.cubicTo(
        a.dx + dx * 0.1 - 6,
        a.dy + drop * 0.35,
        b.dx - dx * 0.25 + (index.isEven ? 8 : -8),
        a.dy + drop * 0.55,
        b.dx,
        b.dy,
      );
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = SceneClock.instance.value;
    for (var i = 0; i < lines.length; i++) {
      final s = lines[i];
      if (s.progress <= 0.001) continue;
      final full = pathFor(s.from, s.to, i);
      final metric = full.computeMetrics().first;
      final len = metric.length;
      final head = len * s.progress;
      final path = metric.extractPath(0, head);
      final level = s.level.clamp(0.0, 1.0);
      final bright = Color.lerp(s.color, const Color(0xFFFFFFFF), 0.25)!;
      final shader = ui.Gradient.linear(
        s.from,
        s.to,
        [
          bright.withValues(alpha: 0.95),
          s.color.withValues(alpha: 0.85),
          const Color(0xFFD9D2FF).withValues(alpha: 0.65),
        ],
        [0, 0.55, 1],
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 + level * 5
          ..strokeCap = StrokeCap.round
          ..color = s.color.withValues(alpha: 0.16 + level * 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1 + level * 0.9
          ..strokeCap = StrokeCap.round
          ..shader = shader,
      );
      final dot = Paint()..blendMode = BlendMode.plus;
      final count = 5;
      for (var k = 0; k < count; k++) {
        final phase = ((t * (0.16 + level * 0.1) + k / count + i * 0.13) % 1.0);
        final d = phase * len;
        if (d > head) continue;
        final tan = metric.getTangentForOffset(d);
        if (tan == null) continue;
        final fade = math.sin(phase * math.pi);
        final wobble = math.sin(t * 2 + k * 3 + i) * 1.2;
        final pos =
            tan.position + Offset(-tan.vector.dy, tan.vector.dx) * wobble;
        dot
          ..color = bright.withValues(alpha: 0.55 * fade * (0.4 + level))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
        canvas.drawCircle(pos, 1.4 + level, dot);
      }
      if (s.progress < 1) {
        final tip = metric.getTangentForOffset(head);
        if (tip != null) {
          canvas.drawCircle(
            tip.position,
            5,
            Paint()
              ..color = bright.withValues(alpha: 0.7)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(StreamsPainter old) => true;
}
