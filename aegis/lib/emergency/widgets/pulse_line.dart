import 'dart:math' as math;

import 'package:flutter/material.dart';

class PulseLine extends StatelessWidget {
  const PulseLine({
    super.key,
    required this.samples,
    required this.color,
    this.strokeWidth = 1.6,
    this.curved = false,
    this.glow = false,
    this.fadeEdges = false,
    this.progress,
  });

  final List<double> samples;
  final Color color;
  final double strokeWidth;
  final bool curved;
  final bool glow;
  final bool fadeEdges;

  /// Draws the trace on from the left as this runs. A bright head follows the
  /// tip so the line reads as being written rather than revealed. Null draws
  /// the whole trace at once.
  final Animation<double>? progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _PulseLinePainter(
        samples: samples,
        color: color,
        strokeWidth: strokeWidth,
        curved: curved,
        glow: glow,
        fadeEdges: fadeEdges,
        progress: progress,
      ),
    );
  }
}

class _PulseLinePainter extends CustomPainter {
  _PulseLinePainter({
    required this.samples,
    required this.color,
    required this.strokeWidth,
    required this.curved,
    required this.glow,
    required this.fadeEdges,
    required this.progress,
  }) : super(repaint: progress);

  final List<double> samples;
  final Color color;
  final double strokeWidth;
  final bool curved;
  final bool glow;
  final bool fadeEdges;
  final Animation<double>? progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2 || size.isEmpty) return;

    final bounds = Offset.zero & size;
    final t = progress?.value ?? 1;
    if (t <= 0) return;

    var path = _buildPath(size);
    Offset? head;
    if (t < 1) {
      (path, head) = _trim(path, t);
    }

    if (glow) {
      canvas.drawPath(
        path,
        _stroke(bounds, color.withValues(alpha: 0.4), strokeWidth * 3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    canvas.drawPath(path, _stroke(bounds, color, strokeWidth));

    if (head != null) {
      canvas
        ..drawCircle(
          head,
          strokeWidth * 3.2,
          Paint()
            ..color = color.withValues(alpha: 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        )
        ..drawCircle(head, strokeWidth * 1.3, Paint()..color = color);
    }
  }

  /// Cuts [path] down to the first [t] of its length, and reports where the
  /// cut landed so the caller can mark the tip.
  (Path, Offset?) _trim(Path path, double t) {
    final trimmed = Path();
    Offset? head;

    for (final metric in path.computeMetrics()) {
      final cut = metric.length * t;
      trimmed.addPath(metric.extractPath(0, cut), Offset.zero);
      head = metric.getTangentForOffset(cut)?.position ?? head;
    }
    return (trimmed, head);
  }

  Path _buildPath(Size size) {
    final low = samples.reduce(math.min);
    final range = samples.reduce(math.max) - low;
    final inset = strokeWidth + (glow ? 4 : 0);
    final usableHeight = math.max(0.0, size.height - inset * 2);

    Offset pointAt(int index) {
      final normalized = range == 0 ? 0.5 : (samples[index] - low) / range;
      return Offset(
        size.width * index / (samples.length - 1),
        inset + usableHeight * (1 - normalized),
      );
    }

    final start = pointAt(0);
    final path = Path()..moveTo(start.dx, start.dy);
    for (var i = 1; i < samples.length; i++) {
      final point = pointAt(i);
      if (curved) {
        final previous = pointAt(i - 1);
        final mid = Offset.lerp(previous, point, 0.5)!;
        path.quadraticBezierTo(previous.dx, previous.dy, mid.dx, mid.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    if (curved) {
      final end = pointAt(samples.length - 1);
      path.lineTo(end.dx, end.dy);
    }
    return path;
  }

  Paint _stroke(Rect bounds, Color base, double width) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (!fadeEdges) return paint..color = base;

    final clear = base.withValues(alpha: 0);
    return paint
      ..shader = LinearGradient(
        colors: [clear, base, base, clear],
        stops: const [0, 0.14, 0.86, 1],
      ).createShader(bounds);
  }

  @override
  bool shouldRepaint(_PulseLinePainter oldDelegate) =>
      oldDelegate.samples != samples ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.curved != curved ||
      oldDelegate.glow != glow ||
      oldDelegate.fadeEdges != fadeEdges ||
      oldDelegate.progress != progress;
}
