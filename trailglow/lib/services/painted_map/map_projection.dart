import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart' show EdgeInsets;

import '../../utils/geo.dart';
import '../map_scene.dart';

class MapProjection {
  MapProjection(this.camera, this.size)
    : _scale = Mercator.scaleForZoom(camera.zoom),
      _cos = math.cos(camera.bearing * math.pi / 180),
      _sin = math.sin(camera.bearing * math.pi / 180) {
    _cx = Mercator.xOf(camera.center.lng) * _scale;
    _cy = Mercator.yOf(camera.center.lat) * _scale;
  }

  final MapCamera camera;
  final Size size;
  final double _scale;
  final double _cos;
  final double _sin;
  late final double _cx;
  late final double _cy;

  double get metersPerPixel {
    final worldMeters =
        40075016.686 * math.cos(camera.center.lat * math.pi / 180);
    return worldMeters / (512 * _scale);
  }

  double pixelsForMeters(double meters) => meters / metersPerPixel;

  Offset toScreen(LatLng p) {
    final dx = Mercator.xOf(p.lng) * _scale - _cx;
    final dy = Mercator.yOf(p.lat) * _scale - _cy;
    return Offset(
      size.width / 2 + dx * _cos + dy * _sin,
      size.height / 2 - dx * _sin + dy * _cos,
    );
  }

  LatLng toLatLng(Offset o) {
    final rx = o.dx - size.width / 2;
    final ry = o.dy - size.height / 2;
    final dx = rx * _cos - ry * _sin;
    final dy = rx * _sin + ry * _cos;
    return LatLng(
      Mercator.latOf((_cy + dy) / _scale),
      Mercator.lngOf((_cx + dx) / _scale),
    );
  }

  GeoBounds visibleBounds({double pad = 0.12}) {
    final corners = <LatLng>[
      toLatLng(Offset.zero),
      toLatLng(Offset(size.width, 0)),
      toLatLng(Offset(0, size.height)),
      toLatLng(Offset(size.width, size.height)),
    ];
    return GeoBounds.of(corners).padded(pad);
  }

  static MapCamera fit(
    GeoBounds bounds,
    Size size,
    EdgeInsets padding, {
    double bearing = 0,
    double minZoom = 9.5,
    double maxZoom = 16.6,
  }) {
    final cos = math.cos(bearing * math.pi / 180);
    final sin = math.sin(bearing * math.pi / 180);
    final corners = <Offset>[
      Offset(Mercator.xOf(bounds.west), Mercator.yOf(bounds.north)),
      Offset(Mercator.xOf(bounds.east), Mercator.yOf(bounds.north)),
      Offset(Mercator.xOf(bounds.west), Mercator.yOf(bounds.south)),
      Offset(Mercator.xOf(bounds.east), Mercator.yOf(bounds.south)),
    ];
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final c in corners) {
      final rx = c.dx * cos + c.dy * sin;
      final ry = -c.dx * sin + c.dy * cos;
      minX = math.min(minX, rx);
      maxX = math.max(maxX, rx);
      minY = math.min(minY, ry);
      maxY = math.max(maxY, ry);
    }
    final availableW = math.max(40.0, size.width - padding.horizontal);
    final availableH = math.max(40.0, size.height - padding.vertical);
    final spanX = math.max(1e-6, maxX - minX);
    final spanY = math.max(1e-6, maxY - minY);
    final zoom = math.min(
      math.log(availableW / spanX) / math.ln2,
      math.log(availableH / spanY) / math.ln2,
    );

    final worldPerPixel = 1 / math.pow(2, zoom);
    final centerRx =
        (minX + maxX) / 2 - (padding.left - padding.right) / 2 * worldPerPixel;
    final centerRy =
        (minY + maxY) / 2 - (padding.top - padding.bottom) / 2 * worldPerPixel;
    final wx = centerRx * cos - centerRy * sin;
    final wy = centerRx * sin + centerRy * cos;

    return MapCamera(
      center: LatLng(Mercator.latOf(wy), Mercator.lngOf(wx)),
      zoom: zoom.clamp(minZoom, maxZoom),
      bearing: bearing,
    );
  }
}
