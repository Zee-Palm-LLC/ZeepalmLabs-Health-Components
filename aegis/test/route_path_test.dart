import 'package:aegis/emergency/route_path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  // An L, drawn far enough north that a degree of longitude is worth about
  // half a degree of latitude on the ground. The two legs therefore differ in
  // length even though they are the same span in degrees, which is what makes
  // "a fraction of the length" distinguishable from "a fraction of the points".
  final bent = RoutePath(const [
    LatLng(60, 0),
    LatLng(61, 0),
    LatLng(61, 1),
  ]);

  final straight = RoutePath(const [LatLng(0, 0), LatLng(0, 2)]);

  test('rejects a route that cannot be travelled', () {
    expect(() => RoutePath(const [LatLng(0, 0)]), throwsAssertionError);
  });

  test('ends sit exactly on the first and last point', () {
    expect(straight.pointAt(0), const LatLng(0, 0));
    expect(straight.pointAt(1), const LatLng(0, 2));
  });

  test('clamps fractions outside the route', () {
    expect(straight.pointAt(-3), const LatLng(0, 0));
    expect(straight.pointAt(9), const LatLng(0, 2));
  });

  test('interpolates inside a segment', () {
    final midpoint = straight.pointAt(0.5);
    expect(midpoint.latitude, closeTo(0, 1e-9));
    expect(midpoint.longitude, closeTo(1, 1e-9));
  });

  test('measures by distance, not by point count', () {
    // Halfway by point count would land on the corner. Halfway by distance is
    // still short of it, because the northward leg is the longer of the two.
    final halfway = bent.pointAt(0.5);
    expect(halfway.longitude, 0, reason: 'still on the northward leg');
    expect(halfway.latitude, greaterThan(60));
    expect(halfway.latitude, lessThan(61));
  });

  test('bearing follows the leg under the fraction', () {
    expect(bent.bearingAt(0.1), closeTo(0, 0.5)); // due north
    // The great-circle bearing of an eastward leg at this latitude leans north
    // of 90; what matters is that it points broadly east, not north.
    expect(bent.bearingAt(0.95), closeTo(90, 30));
  });

  group('slice', () {
    test('covers the whole route', () {
      expect(straight.slice(0, 1).first, const LatLng(0, 0));
      expect(straight.slice(0, 1).last, const LatLng(0, 2));
    });

    test('keeps the corners between its ends', () {
      final middle = bent.slice(0.2, 0.9);
      expect(middle.length, 3, reason: 'two cut ends plus the corner');
      expect(middle[1], const LatLng(61, 0));
    });

    test('collapses to a single point when empty', () {
      expect(bent.slice(0.4, 0.4), hasLength(1));
      expect(bent.slice(0.9, 0.1), hasLength(1));
    });
  });

  group('fractionOf', () {
    test('locates a point on the route', () {
      expect(bent.fractionOf(const LatLng(60, 0)), 0);
      expect(bent.fractionOf(const LatLng(61, 1)), 1);
      // The corner is past the midpoint, the longer leg having come first.
      expect(bent.fractionOf(const LatLng(61, 0)), greaterThan(0.5));
    });

    test('is null for a point that is not on the route', () {
      expect(bent.fractionOf(const LatLng(42, 42)), isNull);
    });
  });
}
