import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trailglow/data/mock/city_grid.dart';
import 'package:trailglow/data/mock/routes.dart';
import 'package:trailglow/services/painted_map/map_projection.dart';
import 'package:trailglow/utils/geo.dart';

void main() {
  test('the Manhattan grid lands on the real corners of Central Park', () {
    const tolerance = 50.0;
    expect(
      distanceMeters(CityGrid.at(59, 0), const LatLng(40.7681, -73.9819)),
      lessThan(tolerance),
    );
    expect(
      distanceMeters(CityGrid.at(110, 0), const LatLng(40.8006, -73.9580)),
      lessThan(tolerance),
    );
    expect(
      distanceMeters(CityGrid.at(110, 810), const LatLng(40.7969, -73.9496)),
      lessThan(tolerance),
    );
    expect(
      distanceMeters(CityGrid.at(59, 810), const LatLng(40.7645, -73.9740)),
      lessThan(tolerance),
    );
  });

  test('route distances match the drawn geometry', () {
    expect(MockRoutes.riversideLoop.distanceKm, closeTo(8.43, 0.05));
    for (final route in MockRoutes.all) {
      expect(route.distanceKm, greaterThan(2.0));
      expect(route.elevationGain, greaterThan(10));
      expect(route.positions.length, greaterThan(80));
    }
  });

  test('a fitted camera frames the route inside the padded box', () {
    const size = Size(393, 852);
    const padding = EdgeInsets.fromLTRB(36, 150, 36, 380);
    final route = MockRoutes.riversideLoop;
    final camera = MapProjection.fit(route.bounds, size, padding, bearing: -18);
    final projection = MapProjection(camera, size);

    for (final point in route.positions) {
      final offset = projection.toScreen(point);
      expect(offset.dx, inInclusiveRange(padding.left - 2, size.width - 34));
      expect(offset.dy, inInclusiveRange(padding.top - 2, size.height - 378));
    }
  });
}
