import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer_onboarding/core/painting/world_dot_map.dart';

double _u(int column) => (column + 0.5) / WorldLandmask.columns;
double _v(int row) => (row + 0.5) / WorldLandmask.rows;

void main() {
  group('WorldLandmask', () {
    test('marks continents as land', () {
      expect(WorldLandmask.isLand(_u(56), _v(21)), isTrue, reason: 'Australia');
      expect(WorldLandmask.isLand(_u(22), _v(18)), isTrue, reason: 'South America');
      expect(WorldLandmask.isLand(_u(35), _v(12)), isTrue, reason: 'Africa');
    });

    test('marks oceans as water', () {
      expect(WorldLandmask.isLand(_u(3), _v(16)), isFalse, reason: 'Pacific');
      expect(WorldLandmask.isLand(_u(27), _v(14)), isFalse, reason: 'Atlantic');
    });

    test('treats coordinates outside the mask as water', () {
      expect(WorldLandmask.isLand(0.5, -0.1), isFalse);
      expect(WorldLandmask.isLand(0.5, 1.2), isFalse);
    });
  });
}
