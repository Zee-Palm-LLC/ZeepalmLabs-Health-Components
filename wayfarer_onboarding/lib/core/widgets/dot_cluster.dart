import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Renders a small dot glyph from a row pattern where `#` is a dot, e.g.
/// `['.##', '##.']`. Dots shimmer independently when [twinkle] is provided.
class DotCluster extends StatelessWidget {
  const DotCluster({
    super.key,
    required this.pattern,
    required this.color,
    this.twinkle,
    this.dotSize = 3.4,
    this.gap = 1.8,
  });

  final List<String> pattern;
  final Color color;
  final Animation<double>? twinkle;
  final double dotSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final columns = pattern.fold<int>(0, (widest, row) => math.max(widest, row.length));
    final pitch = dotSize + gap;
    return SizedBox(
      width: columns * pitch - gap,
      height: pattern.length * pitch - gap,
      child: CustomPaint(
        painter: _DotClusterPainter(
          pattern: pattern,
          color: color,
          twinkle: twinkle,
          dotSize: dotSize,
          pitch: pitch,
        ),
      ),
    );
  }
}

class _DotClusterPainter extends CustomPainter {
  _DotClusterPainter({
    required this.pattern,
    required this.color,
    required this.twinkle,
    required this.dotSize,
    required this.pitch,
  }) : super(repaint: twinkle);

  final List<String> pattern;
  final Color color;
  final Animation<double>? twinkle;
  final double dotSize;
  final double pitch;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = dotSize / 2;
    final paint = Paint();
    final t = twinkle?.value;

    for (var row = 0; row < pattern.length; row++) {
      final line = pattern[row];
      for (var column = 0; column < line.length; column++) {
        if (line[column] != '#') continue;
        final seed = (row * 7 + column * 3) * 0.137;
        final alpha = t == null ? 1.0 : 0.55 + 0.45 * (0.5 + 0.5 * math.sin((t * 2 + seed) * 2 * math.pi));
        paint.color = color.withValues(alpha: color.a * alpha);
        canvas.drawCircle(Offset(column * pitch + radius, row * pitch + radius), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotClusterPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.color != color ||
        oldDelegate.twinkle != twinkle ||
        oldDelegate.dotSize != dotSize ||
        oldDelegate.pitch != pitch;
  }
}
