import 'package:aegis/emergency/formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coordinates carry hemisphere and four decimals', () {
    expect(formatLatitude(33.68441), '33.6844° N');
    expect(formatLatitude(-12.5), '12.5000° S');
    expect(formatLongitude(73.0479), '73.0479° E');
    expect(formatLongitude(-0.1276), '0.1276° W');
  });

  test('distance switches to kilometres at 1000 m', () {
    expect(formatDistance(5), '5 m');
    expect(formatDistance(999.4), '999 m');
    expect(formatDistance(1800), '1.8 km');
  });

  test('ETA never shows zero minutes', () {
    expect(etaMinutes(Duration.zero), 1);
    expect(etaMinutes(const Duration(seconds: 45)), 1);
    expect(etaMinutes(const Duration(minutes: 4)), 4);
    expect(etaMinutes(const Duration(minutes: 4, seconds: 40)), 5);
  });
}
