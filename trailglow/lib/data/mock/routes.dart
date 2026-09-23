import 'dart:math' as math;

import '../../utils/geo.dart';
import '../models/route_point.dart';
import 'city_grid.dart';

RunRoute _build(
  String id,
  String name,
  String area,
  List<List<double>> pairs, {
  double baseElevation = 12,
  double relief = 18,
  int seed = 1,
  bool smooth = true,
}) {
  final raw = CityGrid.line(pairs);
  final shaped = smooth ? smoothPath(raw, passes: 2) : raw;
  final path = resamplePath(shaped, 22);
  final cum = cumulativeMeters(path);
  final total = cum.last;
  final rnd = math.Random(seed);
  final phases = List<double>.generate(
    4,
    (_) => rnd.nextDouble() * math.pi * 2,
  );
  final points = <RoutePoint>[];
  for (var i = 0; i < path.length; i++) {
    final t = total <= 0 ? 0.0 : cum[i] / total;
    var e = baseElevation;
    e += relief * 0.55 * math.sin(t * math.pi * 2 + phases[0]);
    e += relief * 0.28 * math.sin(t * math.pi * 6 + phases[1]);
    e += relief * 0.12 * math.sin(t * math.pi * 13 + phases[2]);
    e += relief * 0.05 * math.sin(t * math.pi * 27 + phases[3]);
    points.add(RoutePoint(path[i], e));
  }
  return RunRoute(id: id, name: name, area: area, points: points);
}

class MockRoutes {
  MockRoutes._();

  static final RunRoute riversideLoop = _build(
    'riverside_loop',
    'Riverside Loop',
    'Upper West Side',
    const <List<double>>[
      [59, -40],
      [59, -180],
      [59.4, -330],
      [59.8, -470],
      [60.4, -600],
      [62, -650],
      [66, -668],
      [71, -690],
      [76, -672],
      [81, -690],
      [86, -706],
      [91, -690],
      [96, -700],
      [100, -688],
      [104.4, -660],
      [104.8, -520],
      [104.6, -380],
      [104.4, -230],
      [104.6, -90],
      [104.8, 0],
      [98, 8],
      [92, 4],
      [86, 10],
      [80, 6],
      [74, 12],
      [68, 6],
      [62, 10],
      [59.2, 0],
      [59, -40],
    ],
    baseElevation: 16,
    relief: 30,
    seed: 7,
  );

  static final RunRoute parkLoop = _build(
    'park_loop',
    'Central Park Loop',
    'Central Park',
    const <List<double>>[
      [61.5, 190],
      [60.6, 320],
      [60.4, 500],
      [61.2, 650],
      [62.6, 720],
      [70, 738],
      [80, 742],
      [90, 745],
      [100, 742],
      [107.4, 730],
      [108.8, 660],
      [109.3, 520],
      [109.1, 330],
      [108.2, 190],
      [106.4, 120],
      [98, 92],
      [88, 80],
      [78, 78],
      [68, 86],
      [62.8, 120],
      [61.5, 190],
    ],
    baseElevation: 22,
    relief: 34,
    seed: 3,
  );

  static final RunRoute reservoirDash = _build(
    'reservoir_dash',
    'Reservoir Dash',
    'Central Park North',
    const <List<double>>[
      [85, 90],
      [85.4, 200],
      [85.6, 400],
      [86.2, 300],
      [87.6, 220],
      [90, 178],
      [93, 190],
      [95.2, 250],
      [96.2, 360],
      [96.4, 470],
      [95.4, 560],
      [93.2, 620],
      [90.4, 640],
      [87.8, 600],
      [86.2, 520],
      [85.6, 400],
      [85.2, 300],
      [85, 150],
      [85, 90],
    ],
    baseElevation: 28,
    relief: 16,
    seed: 11,
  );

  static final RunRoute midtownGrid = _build(
    'midtown_grid',
    'Midtown Sprints',
    'Midtown West',
    const <List<double>>[
      [58, -40],
      [52, -34],
      [52, 300],
      [46, 306],
      [46, 640],
      [50, 646],
      [50, 940],
      [56, 934],
      [56, 620],
      [58, 614],
      [58, 300],
      [57.6, 120],
      [58, -40],
    ],
    baseElevation: 9,
    relief: 11,
    seed: 5,
  );

  static final RunRoute eastRiverTempo = _build(
    'east_river_tempo',
    'East River Tempo',
    'Upper East Side',
    const <List<double>>[
      [60, 1815],
      [64, 1960],
      [70, 2010],
      [76, 2050],
      [82, 2080],
      [88, 2076],
      [94, 2062],
      [100, 2030],
      [106, 1990],
      [110, 1930],
      [110.4, 1700],
      [110.2, 1420],
      [110, 1160],
      [104, 1152],
      [96, 1160],
      [88, 1152],
      [80, 1160],
      [72, 1150],
      [64, 1158],
      [60.2, 1150],
      [60, 1400],
      [60, 1640],
      [60, 1815],
    ],
    baseElevation: 7,
    relief: 13,
    seed: 17,
  );

  static final RunRoute harlemHills = _build(
    'harlem_hills',
    'Harlem Hills',
    'North Woods',
    const <List<double>>[
      [100, 120],
      [103, 180],
      [105, 300],
      [106.8, 430],
      [108.4, 560],
      [109, 690],
      [106, 730],
      [101, 700],
      [98, 620],
      [96.4, 500],
      [95.6, 360],
      [96, 230],
      [98, 150],
      [100, 120],
    ],
    baseElevation: 34,
    relief: 24,
    seed: 23,
  );

  static final List<RunRoute> all = <RunRoute>[
    riversideLoop,
    parkLoop,
    reservoirDash,
    eastRiverTempo,
    midtownGrid,
    harlemHills,
  ];

  static RunRoute byId(String id) => all.firstWhere((r) => r.id == id);
}
