import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../app/theme/palette.dart';
import '../../data/mock/city_grid.dart';
import '../../utils/geo.dart';
import '../map_scene.dart';
import 'city_geometry.dart';
import 'map_projection.dart';

class CityPainter extends CustomPainter {
  CityPainter({required this.camera, required this.dim});

  final MapCamera camera;
  final double dim;

  static final CityGeometry _geo = CityGeometry.instance;
  static final Map<String, TextPainter> _labelCache = <String, TextPainter>{};

  @override
  void paint(Canvas canvas, Size size) {
    final p = MapProjection(camera, size);
    final bounds = p.visibleBounds();
    final rect = Offset.zero & size;

    canvas.drawRect(rect, Paint()..color = MapTone.land);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          const <Color>[Color(0xFF0A0F1B), Color(0xFF05070D)],
          const <double>[0.0, 1.0],
        ),
    );

    _drawPolygon(canvas, p, _geo.hudson, MapTone.water);
    _drawPolygon(canvas, p, _geo.eastRiver, MapTone.water);
    _drawWaterSheen(canvas, p, size);

    _drawPolygon(canvas, p, _geo.park, MapTone.park);
    _drawPolygon(canvas, p, _geo.greatLawn, const Color(0xFF09170F));
    _drawPolygon(canvas, p, _geo.reservoir, const Color(0xFF05101B));

    _drawGlowPools(canvas, p, bounds);
    _drawBlocks(canvas, p, bounds);
    _drawRoads(canvas, p, bounds);
    _drawLabels(canvas, p, bounds);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          size.longestSide * 0.62,
          const <Color>[
            Color(0x00000000),
            Color(0x66000000),
            Color(0xAA000308),
          ],
          const <double>[0.0, 0.72, 1.0],
        ),
    );

    if (dim > 0) {
      canvas.drawRect(
        rect,
        Paint()..color = Colors.black.withValues(alpha: dim),
      );
    }
  }

  void _drawWaterSheen(Canvas canvas, MapProjection p, Size size) {
    final paint = Paint()
      ..color = const Color(0x140F2A55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    final path = Path();
    for (final shore in <List<LatLng>>[
      CityGrid.hudsonShore,
      CityGrid.eastShore,
    ]) {
      var first = true;
      for (final point in shore) {
        final o = p.toScreen(point);
        if (first) {
          path.moveTo(o.dx, o.dy);
          first = false;
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
    }
    canvas.drawPath(
      path,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(6.0, p.pixelsForMeters(120)),
    );
  }

  void _drawGlowPools(Canvas canvas, MapProjection p, GeoBounds bounds) {
    final radius = math.max(90.0, p.pixelsForMeters(1100));
    for (final pool in _geo.glowPools) {
      if (!_inside(pool, bounds)) continue;
      final o = p.toScreen(pool);
      canvas.drawCircle(
        o,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            o,
            radius,
            const <Color>[
              Color(0x2213325E),
              Color(0x0C0C1F3C),
              Color(0x00000000),
            ],
            const <double>[0.0, 0.5, 1.0],
          ),
      );
    }
  }

  void _drawBlocks(Canvas canvas, MapProjection p, GeoBounds bounds) {
    final lift = p.pixelsForMeters(1) * 0.34;
    if (lift < 0.05) return;
    final tops = <Path>[Path(), Path(), Path()];
    final walls = Path();
    var drawn = 0;

    for (final block in _geo.blocks) {
      if (!_inside(block.corners.first, bounds)) continue;
      drawn++;
      final base = block.corners.map(p.toScreen).toList(growable: false);
      final rise = block.height * lift;
      final offset = Offset(rise * 0.2, -rise);
      final top = base.map((o) => o + offset).toList(growable: false);

      walls.addPolygon(<Offset>[base[0], base[1], top[1], top[0]], true);
      walls.addPolygon(<Offset>[base[1], base[2], top[2], top[1]], true);
      walls.addPolygon(<Offset>[base[3], base[0], top[0], top[3]], true);
      tops[block.tier].addPolygon(top, true);
    }
    if (drawn == 0) return;

    canvas.drawPath(walls, Paint()..color = MapTone.block);
    const tierColors = <Color>[
      Color(0xFF0E1423),
      Color(0xFF121A2B),
      Color(0xFF182136),
    ];
    for (var i = 0; i < tops.length; i++) {
      canvas.drawPath(tops[i], Paint()..color = tierColors[i]);
    }
    canvas.drawPath(
      tops[2],
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = const Color(0x2233507F),
    );
  }

  void _drawRoads(Canvas canvas, MapProjection p, GeoBounds bounds) {
    final paths = <RoadRank, Path>{
      RoadRank.street: Path(),
      RoadRank.avenue: Path(),
      RoadRank.highway: Path(),
      RoadRank.park: Path(),
    };

    for (final road in _geo.roads) {
      if (!_segmentVisible(road.path, bounds)) continue;
      final path = paths[road.rank]!;
      var first = true;
      for (final point in road.path) {
        final o = p.toScreen(point);
        if (first) {
          path.moveTo(o.dx, o.dy);
          first = false;
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
    }

    final avenueWidth = math.max(1.0, p.pixelsForMeters(24));
    canvas.drawPath(
      paths[RoadRank.avenue]!,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = avenueWidth * 3.4
        ..color = MapTone.roadGlow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    void stroke(RoadRank rank, double meters, Color color) {
      canvas.drawPath(
        paths[rank]!,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = math.max(0.5, p.pixelsForMeters(meters))
          ..color = color,
      );
    }

    stroke(RoadRank.street, 13, const Color(0xFF0C1220));
    stroke(RoadRank.street, 9, MapTone.roadMinor);
    stroke(RoadRank.park, 9, const Color(0xFF0A1A14));
    stroke(RoadRank.park, 6, const Color(0xFF163026));
    stroke(RoadRank.highway, 28, const Color(0xFF10182A));
    stroke(RoadRank.highway, 22, const Color(0xFF1B2437));
    stroke(RoadRank.avenue, 27, const Color(0xFF0E1526));
    stroke(RoadRank.avenue, 21, MapTone.roadMajor);
  }

  void _drawLabels(Canvas canvas, MapProjection p, GeoBounds bounds) {
    if (camera.zoom < 11.2 || camera.zoom > 15.4) return;
    final fade =
        ((camera.zoom - 11.2) / 1.0).clamp(0.0, 1.0) *
        ((15.4 - camera.zoom) / 0.8).clamp(0.0, 1.0);
    if (fade <= 0.02) return;
    final placed = <Rect>[];
    for (final label in _geo.labels) {
      if (!_inside(label.position, bounds)) continue;
      final painter = _labelPainter(
        label.text,
        label.size,
        label.spacing,
        fade,
      );
      final o = p.toScreen(label.position);
      final rect = Rect.fromCenter(
        center: o,
        width: painter.width + 18,
        height: painter.height + 14,
      );
      if (placed.any((r) => r.overlaps(rect))) continue;
      placed.add(rect);
      painter.paint(
        canvas,
        Offset(o.dx - painter.width / 2, o.dy - painter.height / 2),
      );
    }
  }

  TextPainter _labelPainter(
    String text,
    double size,
    double spacing,
    double fade,
  ) {
    final key = '$text|${fade.toStringAsFixed(2)}';
    return _labelCache.putIfAbsent(key, () {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: size,
            letterSpacing: spacing,
            fontWeight: FontWeight.w600,
            color: MapTone.label.withValues(alpha: 0.85 * fade),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return painter;
    });
  }

  void _drawPolygon(
    Canvas canvas,
    MapProjection p,
    List<LatLng> points,
    Color color,
  ) {
    if (points.length < 3) return;
    final path = Path();
    final first = p.toScreen(points.first);
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < points.length; i++) {
      final o = p.toScreen(points[i]);
      path.lineTo(o.dx, o.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  static bool _inside(LatLng p, GeoBounds b) =>
      p.lat >= b.south &&
      p.lat <= b.north &&
      p.lng >= b.west &&
      p.lng <= b.east;

  static bool _segmentVisible(List<LatLng> path, GeoBounds b) {
    final pb = GeoBounds.of(path);
    return pb.south <= b.north &&
        pb.north >= b.south &&
        pb.west <= b.east &&
        pb.east >= b.west;
  }

  @override
  bool shouldRepaint(CityPainter old) =>
      !old.camera.closeTo(camera) || old.dim != dim;
}
