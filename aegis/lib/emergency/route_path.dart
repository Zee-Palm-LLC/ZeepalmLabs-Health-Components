import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// A polyline measured by distance, so a vehicle can be placed a fraction of
/// the way along it rather than a fraction of the way through its points.
///
/// Segments are treated as straight on an equirectangular projection. Over a
/// city-scale route that is well inside the width of the marker.
class RoutePath {
  RoutePath(List<LatLng> points)
      : assert(points.length >= 2, 'a route needs at least two points'),
        points = List.unmodifiable(points) {
    var total = 0.0;
    _cumulative = [0];
    for (var i = 1; i < this.points.length; i++) {
      total += _metres(this.points[i - 1], this.points[i]);
      _cumulative.add(total);
    }
  }

  final List<LatLng> points;

  /// Distance from the first point to each point, in metres.
  late final List<double> _cumulative;

  /// Total length in metres. Zero only for a degenerate route.
  double get length => _cumulative.last;

  /// The position [t] of the way along the route, [t] in 0..1.
  LatLng pointAt(double t) {
    final (index, local) = _locate(t);
    if (index >= points.length - 1) return points.last;
    return _lerp(points[index], points[index + 1], local);
  }

  /// Compass bearing in degrees of the segment under [t]. Used to point the
  /// vehicle the way it is travelling.
  double bearingAt(double t) {
    final (index, _) = _locate(t);
    final from = points[math.min(index, points.length - 2)];
    final to = points[math.min(index + 1, points.length - 1)];
    return _bearing(from, to);
  }

  /// The stretch of route between two fractions, with the ends interpolated so
  /// a partial segment still draws to exactly the right place.
  List<LatLng> slice(double from, double to) {
    final start = from.clamp(0.0, 1.0);
    final end = to.clamp(0.0, 1.0);
    if (end <= start) return [pointAt(start)];

    final (startIndex, _) = _locate(start);
    final (endIndex, _) = _locate(end);

    return [
      pointAt(start),
      for (var i = startIndex + 1; i <= endIndex; i++) points[i],
      pointAt(end),
    ];
  }

  /// Fraction along the route of the point at [index].
  double fractionOfPoint(int index) => length == 0
      ? 0
      : _cumulative[index.clamp(0, points.length - 1)] / length;

  /// Fraction along the route of [point], or null when it is not one of the
  /// route's own points.
  double? fractionOf(LatLng point) {
    final index = points.indexWhere(
      (p) => p.latitude == point.latitude && p.longitude == point.longitude,
    );
    return index < 0 ? null : fractionOfPoint(index);
  }

  /// Segment index containing [t], plus how far into that segment it sits.
  (int, double) _locate(double t) {
    if (length == 0) return (0, 0);
    final target = t.clamp(0.0, 1.0) * length;

    for (var i = 1; i < _cumulative.length; i++) {
      if (target > _cumulative[i]) continue;
      final span = _cumulative[i] - _cumulative[i - 1];
      final local = span == 0 ? 0.0 : (target - _cumulative[i - 1]) / span;
      return (i - 1, local);
    }
    return (points.length - 2, 1);
  }

  static LatLng _lerp(LatLng a, LatLng b, double t) => LatLng(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      );

  static double _metres(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _radians(b.latitude - a.latitude);
    final dLon = _radians(b.longitude - a.longitude);
    final meanLat = _radians((a.latitude + b.latitude) / 2);
    final x = dLon * math.cos(meanLat);
    return earthRadius * math.sqrt(dLat * dLat + x * x);
  }

  static double _bearing(LatLng a, LatLng b) {
    final lat1 = _radians(a.latitude);
    final lat2 = _radians(b.latitude);
    final dLon = _radians(b.longitude - a.longitude);
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
