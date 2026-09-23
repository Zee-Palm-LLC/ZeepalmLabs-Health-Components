import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../utils/geo.dart';

class RouteThumbnail extends StatelessWidget {
  const RouteThumbnail({
    super.key,
    required this.path,
    this.size = const Size(96, 72),
    this.strokeWidth = 2.4,
  });

  final List<LatLng> path;
  final Size size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: const Color(0xFF070B13),
          border: Border.all(color: Night.hairlineSoft),
          borderRadius: BorderRadius.circular(14),
        ),
        child: CustomPaint(
          painter: _ThumbPainter(path: path, strokeWidth: strokeWidth),
        ),
      ),
    );
  }
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter({required this.path, required this.strokeWidth});

  final List<LatLng> path;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;
    final bounds = GeoBounds.of(path);
    final spanLat = math.max(1e-6, bounds.north - bounds.south);
    final spanLng = math.max(1e-6, bounds.east - bounds.west);
    final inset = size.shortestSide * 0.16;
    final area = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final scale = math.min(area.width / spanLng, area.height / spanLat);

    Offset project(LatLng p) => Offset(
      area.center.dx + (p.lng - (bounds.west + bounds.east) / 2) * scale,
      area.center.dy - (p.lat - (bounds.south + bounds.north) / 2) * scale,
    );

    final points = path.map(project).toList(growable: false);
    const chunks = 22;
    final step = math.max(1, (points.length / chunks).ceil());

    void pass(double width, double blur, double alpha) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width;
      if (blur > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      }
      for (var i = 0; i < points.length - 1; i += step) {
        final end = math.min(i + step + 1, points.length);
        final t = i / math.max(1, points.length - 1);
        paint.color = _colorAt(t).withValues(alpha: alpha);
        final sub = Path()..moveTo(points[i].dx, points[i].dy);
        for (var j = i + 1; j < end; j++) {
          sub.lineTo(points[j].dx, points[j].dy);
        }
        canvas.drawPath(sub, paint);
      }
    }

    pass(strokeWidth * 3.0, 5, 0.22);
    pass(strokeWidth, 0, 1.0);

    canvas.drawCircle(points.first, 2.6, Paint()..color = Spectrum.teal);
    canvas.drawCircle(points.last, 2.6, Paint()..color = Spectrum.amber);
  }

  Color _colorAt(double t) {
    const colors = <Color>[
      Spectrum.deep,
      Spectrum.blue,
      Spectrum.cyan,
      Spectrum.amber,
    ];
    final scaled = t.clamp(0.0, 0.9999) * (colors.length - 1);
    final index = scaled.floor();
    return Color.lerp(colors[index], colors[index + 1], scaled - index)!;
  }

  @override
  bool shouldRepaint(_ThumbPainter old) => old.path != path;
}
