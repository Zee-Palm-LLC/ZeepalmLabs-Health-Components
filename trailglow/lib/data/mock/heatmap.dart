import 'dart:math' as math;

import '../../utils/geo.dart';
import '../models/heatmap_data.dart';
import '../models/run_stats.dart';
import 'city_grid.dart';
import 'routes.dart';

class MockHeatmap {
  MockHeatmap._();

  static final Map<HeatmapRange, HeatmapData> _cache =
      <HeatmapRange, HeatmapData>{};

  static const Map<HeatmapRange, int> runCounts = <HeatmapRange, int>{
    HeatmapRange.week: 4,
    HeatmapRange.month: 15,
    HeatmapRange.year: 46,
    HeatmapRange.all: 51,
  };

  static const Map<HeatmapRange, LifetimeStats> _stats =
      <HeatmapRange, LifetimeStats>{
        HeatmapRange.week: LifetimeStats(
          distanceKm: 34.2,
          runs: 4,
          hours: 3.1,
          elevationMeters: 186,
          longestRunKm: 12.4,
          bestPaceSeconds: 291,
          monthly: <double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 6.2, 8.4, 19.6],
        ),
        HeatmapRange.month: LifetimeStats(
          distanceKm: 132.6,
          runs: 15,
          hours: 12.4,
          elevationMeters: 604,
          longestRunKm: 16.8,
          bestPaceSeconds: 288,
          monthly: <double>[0, 0, 0, 0, 0, 0, 0, 0, 28.4, 31.6, 36.2, 36.4],
        ),
        HeatmapRange.year: LifetimeStats(
          distanceKm: 386.4,
          runs: 46,
          hours: 38.2,
          elevationMeters: 1648,
          longestRunKm: 21.1,
          bestPaceSeconds: 284,
          monthly: <double>[
            18.4,
            24.2,
            29.6,
            33.8,
            37.2,
            31.4,
            26.8,
            30.2,
            35.6,
            38.4,
            40.2,
            40.6,
          ],
        ),
        HeatmapRange.all: LifetimeStats(
          distanceKm: 428.0,
          runs: 51,
          hours: 42.0,
          elevationMeters: 1842,
          longestRunKm: 21.1,
          bestPaceSeconds: 282,
          monthly: <double>[
            21.6,
            26.4,
            31.2,
            35.4,
            39.8,
            34.2,
            28.6,
            32.8,
            38.2,
            41.6,
            44.8,
            53.4,
          ],
        ),
      };

  static HeatmapData forRange(HeatmapRange range) =>
      _cache.putIfAbsent(range, () => _generate(range));

  static HeatmapData _generate(HeatmapRange range) {
    final count = runCounts[range]!;
    final rnd = math.Random(4200 + range.index);
    final traces = <List<LatLng>>[];
    final weights = <double>[];

    final core = <List<LatLng>>[
      MockRoutes.riversideLoop.positions,
      MockRoutes.parkLoop.positions,
      MockRoutes.reservoirDash.positions,
      MockRoutes.eastRiverTempo.positions,
      MockRoutes.midtownGrid.positions,
      MockRoutes.harlemHills.positions,
    ];

    for (var i = 0; i < count; i++) {
      if (i % 3 != 2 || i < 4) {
        final index = i < 4 ? i % 2 : rnd.nextInt(core.length);
        traces.add(core[index]);
        weights.add(1.0);
      } else {
        traces.add(_gridLoop(rnd));
        weights.add(0.7);
      }
    }

    final points = <HeatmapPoint>[];
    for (var i = 0; i < traces.length; i++) {
      final sampled = resamplePath(traces[i], 95);
      for (final p in sampled) {
        points.add(HeatmapPoint(p, weights[i]));
      }
    }

    return HeatmapData(
      range: range,
      points: points,
      traces: traces,
      stats: _stats[range]!,
    );
  }

  static List<LatLng> _gridLoop(math.Random rnd) {
    const westAvenues = <double>[
      CityGrid.riverside,
      CityGrid.westEnd,
      CityGrid.amsterdam,
      CityGrid.columbus,
      CityGrid.centralParkWest,
    ];
    const eastAvenues = <double>[
      CityGrid.fifth,
      CityGrid.madison,
      CityGrid.park,
      CityGrid.lexington,
      CityGrid.third,
      CityGrid.second,
      CityGrid.first,
      CityGrid.york,
    ];

    final east = rnd.nextBool();
    final avenues = east ? eastAvenues : westAvenues;
    var a = rnd.nextInt(avenues.length);
    var b = rnd.nextInt(avenues.length);
    if (a == b) b = (b + 1 + rnd.nextInt(avenues.length - 1)) % avenues.length;
    final left = math.min(avenues[a], avenues[b]);
    final right = math.max(avenues[a], avenues[b]);

    final south = 60 + rnd.nextInt(36).toDouble();
    final north = south + 6 + rnd.nextInt(24);

    return smoothPath(
      CityGrid.line(<List<double>>[
        [south, left],
        [south, right],
        [north, right],
        [north, left],
        [south, left],
      ]),
      passes: 1,
    );
  }

  static GeoBounds get cityBounds => GeoBounds.of(<LatLng>[
    CityGrid.at(48, -900),
    CityGrid.at(48, 2100),
    CityGrid.at(122, -900),
    CityGrid.at(122, 2100),
  ]);
}
