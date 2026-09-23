import 'dart:math' as math;

class LatLng {
  const LatLng(this.lat, this.lng);

  final double lat;
  final double lng;

  LatLng lerpTo(LatLng other, double t) =>
      LatLng(lat + (other.lat - lat) * t, lng + (other.lng - lng) * t);

  @override
  String toString() => '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}

class GeoBounds {
  GeoBounds(this.south, this.west, this.north, this.east);

  final double south;
  final double west;
  final double north;
  final double east;

  factory GeoBounds.of(Iterable<LatLng> points) {
    var s = 90.0, n = -90.0, w = 180.0, e = -180.0;
    for (final p in points) {
      if (p.lat < s) s = p.lat;
      if (p.lat > n) n = p.lat;
      if (p.lng < w) w = p.lng;
      if (p.lng > e) e = p.lng;
    }
    return GeoBounds(s, w, n, e);
  }

  LatLng get center => LatLng((south + north) / 2, (west + east) / 2);

  GeoBounds padded(double fraction) {
    final dy = (north - south) * fraction;
    final dx = (east - west) * fraction;
    return GeoBounds(south - dy, west - dx, north + dy, east + dx);
  }
}

const double _metersPerDegreeLat = 111320.0;

double metersPerDegreeLng(double lat) =>
    _metersPerDegreeLat * math.cos(lat * math.pi / 180.0);

double distanceMeters(LatLng a, LatLng b) {
  final mid = (a.lat + b.lat) / 2;
  final dy = (b.lat - a.lat) * _metersPerDegreeLat;
  final dx = (b.lng - a.lng) * metersPerDegreeLng(mid);
  return math.sqrt(dx * dx + dy * dy);
}

double pathLengthMeters(List<LatLng> path) {
  var total = 0.0;
  for (var i = 1; i < path.length; i++) {
    total += distanceMeters(path[i - 1], path[i]);
  }
  return total;
}

List<double> cumulativeMeters(List<LatLng> path) {
  final out = <double>[0];
  for (var i = 1; i < path.length; i++) {
    out.add(out[i - 1] + distanceMeters(path[i - 1], path[i]));
  }
  return out;
}

class PathSample {
  const PathSample(this.position, this.bearing);

  final LatLng position;
  final double bearing;
}

PathSample sampleAlong(List<LatLng> path, List<double> cumulative, double t) {
  if (path.length < 2) return PathSample(path.first, 0);
  final target = cumulative.last * t.clamp(0.0, 1.0);
  var i = 1;
  while (i < cumulative.length - 1 && cumulative[i] < target) {
    i++;
  }
  final span = cumulative[i] - cumulative[i - 1];
  final local = span <= 0 ? 0.0 : (target - cumulative[i - 1]) / span;
  final a = path[i - 1];
  final b = path[i];
  return PathSample(a.lerpTo(b, local), bearingBetween(a, b));
}

double bearingBetween(LatLng a, LatLng b) {
  final dy = (b.lat - a.lat) * _metersPerDegreeLat;
  final dx = (b.lng - a.lng) * metersPerDegreeLng((a.lat + b.lat) / 2);
  return (math.atan2(dx, dy) * 180 / math.pi + 360) % 360;
}

List<LatLng> smoothPath(List<LatLng> path, {int passes = 2}) {
  var current = path;
  for (var p = 0; p < passes; p++) {
    if (current.length < 3) return current;
    final next = <LatLng>[current.first];
    for (var i = 0; i < current.length - 1; i++) {
      final a = current[i];
      final b = current[i + 1];
      next.add(a.lerpTo(b, 0.25));
      next.add(a.lerpTo(b, 0.75));
    }
    next.add(current.last);
    current = next;
  }
  return current;
}

List<LatLng> resamplePath(List<LatLng> path, double stepMeters) {
  final cum = cumulativeMeters(path);
  final total = cum.last;
  if (total <= 0) return path;
  final count = math.max(2, (total / stepMeters).round());
  return List<LatLng>.generate(
    count + 1,
    (i) => sampleAlong(path, cum, i / count).position,
  );
}

class Mercator {
  static const double _worldSize = 512.0;

  static double xOf(double lng) => (lng + 180.0) / 360.0 * _worldSize;

  static double yOf(double lat) {
    final s = math.sin(lat * math.pi / 180.0).clamp(-0.9999, 0.9999);
    return (0.5 - math.log((1 + s) / (1 - s)) / (4 * math.pi)) * _worldSize;
  }

  static double lngOf(double x) => x / _worldSize * 360.0 - 180.0;

  static double latOf(double y) {
    final n = math.pi * (1 - 2 * y / _worldSize);
    return math.atan(_sinh(n)) * 180.0 / math.pi;
  }

  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;

  static double scaleForZoom(double zoom) => math.pow(2.0, zoom).toDouble();
}
