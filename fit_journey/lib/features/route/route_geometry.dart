import 'dart:ui';

import '../../data/route_path.dart';

class RouteGeometry {
  RouteGeometry._() {
    north = _smooth(RoutePath.north);
    south = _smooth(RoutePath.south);
    _northMetric = north.computeMetrics().first;
    _southMetric = south.computeMetrics().first;
    loop = Path()
      ..addPath(north, Offset.zero)
      ..extendWithPath(_reverse(RoutePath.south), Offset.zero);
    _loopMetric = loop.computeMetrics().first;
  }

  static final instance = RouteGeometry._();

  late final Path north;
  late final Path south;
  late final Path loop;
  late final PathMetric _northMetric;
  late final PathMetric _southMetric;
  late final PathMetric _loopMetric;

  double get northLength => _northMetric.length;

  double get southLength => _southMetric.length;

  double get loopLength => _loopMetric.length;

  Path northPart(double t) => _northMetric.extractPath(0, northLength * t.clamp(0.0, 1.0));

  Path southPart(double t) => _southMetric.extractPath(0, southLength * t.clamp(0.0, 1.0));

  Path loopPart(double t) => _loopMetric.extractPath(0, loopLength * t.clamp(0.0, 1.0));

  Offset northAt(double distance) => _northMetric.getTangentForOffset(distance.clamp(0.0, northLength))!.position;

  Offset southAt(double distance) => _southMetric.getTangentForOffset(distance.clamp(0.0, southLength))!.position;

  Tangent loopAt(double t) => _loopMetric.getTangentForOffset(loopLength * t.clamp(0.0, 1.0))!;

  static Path _smooth(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final mid = Offset.lerp(points[i], points[i + 1], 0.5)!;
      path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  static Path _reverse(List<Offset> points) => _smooth(points.reversed.toList());
}
