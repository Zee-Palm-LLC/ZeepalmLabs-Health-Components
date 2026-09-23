import '../../utils/geo.dart';

class RoutePoint {
  const RoutePoint(this.position, this.elevation);

  final LatLng position;
  final double elevation;

  double get lat => position.lat;
  double get lng => position.lng;
}

class RunRoute {
  RunRoute({
    required this.id,
    required this.name,
    required this.area,
    required this.points,
  }) : _cumulative = cumulativeMeters(points.map((p) => p.position).toList()),
       positions = points.map((p) => p.position).toList(growable: false);

  final String id;
  final String name;
  final String area;
  final List<RoutePoint> points;
  final List<LatLng> positions;
  final List<double> _cumulative;

  double get distanceMeters => _cumulative.last;

  double get distanceKm => distanceMeters / 1000;

  double get elevationGain {
    var gain = 0.0;
    for (var i = 1; i < points.length; i++) {
      final delta = points[i].elevation - points[i - 1].elevation;
      if (delta > 0) gain += delta;
    }
    return gain;
  }

  GeoBounds get bounds => GeoBounds.of(positions);

  LatLng get start => positions.first;

  PathSample sampleAt(double progress) =>
      sampleAlong(positions, _cumulative, progress);

  double elevationAt(double progress) {
    final target = distanceMeters * progress.clamp(0.0, 1.0);
    var i = 1;
    while (i < _cumulative.length - 1 && _cumulative[i] < target) {
      i++;
    }
    final span = _cumulative[i] - _cumulative[i - 1];
    final local = span <= 0 ? 0.0 : (target - _cumulative[i - 1]) / span;
    final a = points[i - 1].elevation;
    final b = points[i].elevation;
    return a + (b - a) * local;
  }

  List<LatLng> sliceTo(double progress) {
    final target = distanceMeters * progress.clamp(0.0, 1.0);
    final out = <LatLng>[positions.first];
    for (var i = 1; i < positions.length; i++) {
      if (_cumulative[i] >= target) {
        out.add(sampleAt(progress).position);
        break;
      }
      out.add(positions[i]);
    }
    return out;
  }
}
