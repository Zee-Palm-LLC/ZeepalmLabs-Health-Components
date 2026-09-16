import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// Coarse equirectangular land mask (lat 80N..-60S, 64 x 28 cells) stored as
/// inclusive column spans per row. Detailed enough for a stylised dot map.
abstract final class WorldLandmask {
  static const columns = 64;
  static const rows = 28;

  static const List<List<List<int>>> _spans = [
    [[14, 18], [21, 27], [37, 38], [48, 52]],
    [[8, 19], [20, 28], [44, 60]],
    [[2, 18], [20, 27], [35, 38], [39, 63]],
    [[1, 18], [21, 25], [28, 29], [33, 63]],
    [[2, 5], [7, 17], [19, 22], [32, 58], [60, 61]],
    [[7, 21], [31, 32], [33, 56], [58, 59]],
    [[8, 21], [31, 32], [32, 56], [57, 57]],
    [[9, 20], [31, 55], [56, 57]],
    [[9, 19], [30, 33], [34, 54], [56, 57]],
    [[10, 18], [30, 36], [37, 54], [55, 56]],
    [[11, 17], [29, 37], [38, 54]],
    [[12, 15], [16, 16], [17, 18], [29, 42], [44, 48], [49, 53], [54, 54]],
    [[13, 16], [29, 42], [45, 47], [49, 52], [55, 55]],
    [[15, 17], [29, 41], [45, 46], [49, 51], [55, 55]],
    [[17, 22], [29, 40], [46, 46], [50, 51]],
    [[18, 23], [31, 40], [50, 54]],
    [[18, 25], [33, 40], [49, 54], [56, 56]],
    [[18, 26], [34, 39], [51, 54], [56, 58]],
    [[19, 26], [34, 39], [55, 57]],
    [[19, 26], [34, 39], [41, 41], [53, 59]],
    [[20, 25], [35, 39], [41, 41], [52, 59]],
    [[20, 24], [35, 38], [52, 59]],
    [[20, 23], [35, 37], [52, 58]],
    [[20, 22], [36, 36], [53, 58]],
    [[20, 21], [58, 58], [62, 62]],
    [[20, 21], [61, 62]],
    [[20, 20]],
    [[21, 21]],
  ];

  static bool isLand(double u, double v) {
    final row = (v * rows).floor();
    if (row < 0 || row >= rows) return false;
    final column = (u * columns).floor();
    for (final span in _spans[row]) {
      if (column >= span[0] && column <= span[1]) return true;
    }
    return false;
  }
}

class WorldDotMapPainter extends CustomPainter {
  WorldDotMapPainter({
    required this.animation,
    required this.color,
    this.curve = Curves.linear,
    this.spacing = 5.2,
    this.dotRadius = 1.35,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Curve curve;
  final Color color;
  final double spacing;
  final double dotRadius;

  static final Map<(Size, double), List<Offset>> _dotCache = {};

  List<Offset> _dotsFor(Size size) {
    return _dotCache.putIfAbsent((size, spacing), () {
      final dots = <Offset>[];
      final rowHeight = spacing * 0.866;
      var row = 0;
      for (var y = rowHeight / 2; y < size.height; y += rowHeight, row++) {
        final shift = row.isOdd ? spacing / 2 : 0.0;
        for (var x = spacing / 2 + shift; x < size.width; x += spacing) {
          if (WorldLandmask.isLand(x / size.width, y / size.height)) dots.add(Offset(x, y));
        }
      }
      return dots;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final dots = _dotsFor(size);
    final progress = curve.transform(animation.value);
    if (progress <= 0) return;

    if (progress >= 1) {
      canvas.drawPoints(
        PointMode.points,
        dots,
        Paint()
          ..color = color
          ..strokeWidth = dotRadius * 2
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    // Radial wipe from the map's visual centre.
    final origin = Offset(size.width * 0.5, size.height * 0.45);
    final reach = size.longestSide * 0.62;
    final paint = Paint();
    for (final dot in dots) {
      final distance = (dot - origin).distance / reach;
      final local = ((progress * 1.35 - distance) * 5).clamp(0.0, 1.0);
      if (local == 0) continue;
      paint.color = color.withValues(alpha: color.a * local);
      canvas.drawCircle(dot, dotRadius * (0.4 + 0.6 * local), paint);
    }
  }

  @override
  bool shouldRepaint(WorldDotMapPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.curve != curve ||
        oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.dotRadius != dotRadius;
  }
}
