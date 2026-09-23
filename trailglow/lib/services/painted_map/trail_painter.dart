import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/palette.dart';
import '../../data/models/heatmap_data.dart';
import '../../utils/geo.dart';
import '../map_scene.dart';
import 'map_projection.dart';

class TrailPainter extends CustomPainter {
  TrailPainter({
    required this.camera,
    required this.scene,
    required this.pulse,
    super.repaint,
  });

  final MapCamera camera;
  final MapScene scene;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final p = MapProjection(camera, size);

    final heat = scene.heatmap;
    if (heat != null) _drawHeatmap(canvas, p, heat);

    for (final line in scene.lines) {
      if (line.path.length < 2) continue;
      if (line.style == TrailStyle.ghost) {
        _drawGhost(canvas, p, line);
      } else {
        _drawTrail(canvas, p, line);
      }
    }

    for (final marker in scene.markers) {
      _drawMarker(canvas, p, marker);
    }
  }

  void _drawHeatmap(Canvas canvas, MapProjection p, HeatmapData heat) {
    final paths = <Path>[];
    for (final trace in heat.traces) {
      final path = Path();
      var first = true;
      for (final point in trace) {
        final o = p.toScreen(point);
        if (first) {
          path.moveTo(o.dx, o.dy);
          first = false;
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      paths.add(path);
    }

    final scale = math.max(0.35, p.pixelsForMeters(90) / 6.0);
    final passes = <List<double>>[
      <double>[26 * scale, 16, 0.035],
      <double>[13 * scale, 8, 0.05],
      <double>[6.5 * scale, 3.5, 0.07],
      <double>[2.6 * scale, 0, 0.13],
    ];
    const colors = <Color>[
      Color(0xFF1B3FA8),
      Color(0xFF2F7BFF),
      Color(0xFF2FE8FF),
      Color(0xFF6FF7E6),
    ];

    for (var i = 0; i < passes.length; i++) {
      final spec = passes[i];
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = spec[0]
        ..blendMode = BlendMode.plus
        ..color = colors[i].withValues(alpha: spec[2]);
      if (spec[1] > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, spec[1]);
      }
      for (final path in paths) {
        canvas.drawPath(path, paint);
      }
    }

    final emberPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.4 * scale
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4)
      ..color = Spectrum.amber.withValues(alpha: 0.03);
    for (final path in paths) {
      canvas.drawPath(path, emberPaint);
    }
  }

  void _drawGhost(Canvas canvas, MapProjection p, TrailLine line) {
    final path = _pathFor(p, line.path, 0, line.path.length);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = line.width
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..color = Spectrum.blue.withValues(alpha: 0.18 * line.opacity),
    );
  }

  void _drawTrail(Canvas canvas, MapProjection p, TrailLine line) {
    final points = line.path.map(p.toScreen).toList(growable: false);
    final total = points.length;
    final travelled = (total * line.progress)
        .clamp(2.0, total.toDouble())
        .round();

    if (travelled < total) {
      final ahead = _pathFor(p, line.path, travelled - 1, total);
      canvas.drawPath(
        ahead,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = line.width * 1.05
          ..color = const Color(
            0xFF27406E,
          ).withValues(alpha: 0.95 * line.opacity),
      );
    }

    const chunks = 44;
    final ember = line.style == TrailStyle.ember;
    final step = math.max(1, (travelled / chunks).ceil());
    final span = line.progress.clamp(0.04, 1.0);

    void pass(double width, double blur, double alpha, bool useGradient) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width;
      if (blur > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      }
      for (var i = 0; i < travelled - 1; i += step) {
        final end = math.min(i + step + 1, travelled);
        final raw = total <= 1 ? 0.0 : (i + step / 2) / (total - 1);
        final t = (raw / span).clamp(0.0, 1.0);
        final color = useGradient
            ? _trailColor(t, ember)
            : (ember ? Spectrum.ember : Spectrum.blue);
        paint.color = color.withValues(alpha: alpha * line.opacity);
        final sub = Path();
        sub.moveTo(points[i].dx, points[i].dy);
        for (var j = i + 1; j < end; j++) {
          sub.lineTo(points[j].dx, points[j].dy);
        }
        canvas.drawPath(sub, paint);
      }
    }

    pass(line.width * 5.6, 13, 0.26, true);
    pass(line.width * 2.6, 6, 0.40, true);
    pass(line.width, 0, 1.0, true);
    pass(line.width * 0.34, 0, 0.6, false);
  }

  Color _trailColor(double t, bool ember) {
    final colors = ember
        ? const <Color>[
            Spectrum.deep,
            Spectrum.blue,
            Spectrum.amber,
            Spectrum.ember,
          ]
        : const <Color>[
            Spectrum.deep,
            Spectrum.blue,
            Spectrum.sky,
            Spectrum.cyan,
            Spectrum.teal,
          ];
    final clamped = t.clamp(0.0, 0.9999);
    final scaled = clamped * (colors.length - 1);
    final index = scaled.floor();
    return Color.lerp(colors[index], colors[index + 1], scaled - index)!;
  }

  Path _pathFor(MapProjection p, List<LatLng> points, int from, int to) {
    final path = Path();
    final start = math.max(0, from);
    for (var i = start; i < to; i++) {
      final o = p.toScreen(points[i]);
      if (i == start) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    return path;
  }

  void _drawMarker(Canvas canvas, MapProjection p, MapMarker marker) {
    final o = p.toScreen(marker.position);
    switch (marker.kind) {
      case MarkerKind.start:
        _ring(canvas, o, 7, Spectrum.teal);
      case MarkerKind.finish:
        _ring(canvas, o, 7, Spectrum.amber);
      case MarkerKind.pin:
        _ring(canvas, o, 5.5, Spectrum.sky);
      case MarkerKind.runner:
        _puck(canvas, o);
    }
  }

  void _ring(Canvas canvas, Offset o, double radius, Color color) {
    canvas.drawCircle(
      o,
      radius * 2.6,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(o, radius, Paint()..color = Night.abyss);
    canvas.drawCircle(
      o,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = color,
    );
    canvas.drawCircle(o, radius * 0.34, Paint()..color = color);
  }

  void _puck(Canvas canvas, Offset o) {
    final wave = 0.5 + 0.5 * math.sin(pulse * math.pi * 2);
    canvas.drawCircle(
      o,
      16 + wave * 16,
      Paint()..color = Spectrum.cyan.withValues(alpha: 0.16 * (1 - wave)),
    );
    canvas.drawCircle(
      o,
      22,
      Paint()
        ..color = Spectrum.cyan.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(o, 8.5, Paint()..color = Colors.white);
    canvas.drawCircle(
      o,
      8.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = Spectrum.cyan,
    );
  }

  @override
  bool shouldRepaint(TrailPainter old) => true;
}
