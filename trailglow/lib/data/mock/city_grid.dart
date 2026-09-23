import 'dart:math' as math;

import '../../utils/geo.dart';

enum RoadRank { avenue, street, park, highway }

class Road {
  const Road(this.name, this.rank, this.path);

  final String name;
  final RoadRank rank;
  final List<LatLng> path;
}

class CityGrid {
  CityGrid._();

  static const LatLng origin = LatLng(40.7681, -73.9819);
  static const double _bearingRad = 29.0 * math.pi / 180.0;
  static const double blockMeters = 80.5;
  static const double baseStreet = 59.0;

  static final double _sin = math.sin(_bearingRad);
  static final double _cos = math.cos(_bearingRad);
  static final double _mPerLng = metersPerDegreeLng(origin.lat);

  static LatLng local(double uptownMeters, double eastMeters) {
    final east = uptownMeters * _sin + eastMeters * _cos;
    final north = uptownMeters * _cos - eastMeters * _sin;
    return LatLng(origin.lat + north / 111320.0, origin.lng + east / _mPerLng);
  }

  static LatLng at(double street, double avenue) =>
      local((street - baseStreet) * blockMeters, avenue);

  static List<LatLng> line(List<List<double>> pairs) =>
      pairs.map((p) => at(p[0], p[1])).toList(growable: false);

  static const double riverside = -600;
  static const double westEnd = -450;
  static const double amsterdam = -300;
  static const double columbus = -150;
  static const double centralParkWest = 0;
  static const double fifth = 810;
  static const double madison = 940;
  static const double park = 1110;
  static const double lexington = 1240;
  static const double third = 1415;
  static const double second = 1615;
  static const double first = 1815;
  static const double york = 1990;

  static const double parkWestDrive = 75;
  static const double parkEastDrive = 735;

  static const Map<String, double> avenueOffsets = <String, double>{
    'Riverside Dr': riverside,
    'West End Ave': westEnd,
    'Amsterdam Ave': amsterdam,
    'Columbus Ave': columbus,
    'Central Park West': centralParkWest,
    'Fifth Ave': fifth,
    'Madison Ave': madison,
    'Park Ave': park,
    'Lexington Ave': lexington,
    'Third Ave': third,
    'Second Ave': second,
    'First Ave': first,
    'York Ave': york,
  };

  static List<LatLng> get parkOutline => line(<List<double>>[
    [59, 0],
    [59, 810],
    [110, 810],
    [110, 0],
    [59, 0],
  ]);

  static List<LatLng> get reservoirOutline {
    const cx = 91.0;
    const cy = 405.0;
    const rStreet = 5.6;
    const rAvenue = 250.0;
    return List<LatLng>.generate(48, (i) {
      final a = i / 48 * 2 * math.pi;
      return at(cx + rStreet * math.cos(a), cy + rAvenue * math.sin(a));
    });
  }

  static List<LatLng> get greatLawnOutline {
    const cx = 82.0;
    const cy = 380.0;
    return List<LatLng>.generate(32, (i) {
      final a = i / 32 * 2 * math.pi;
      return at(cx + 2.6 * math.cos(a), cy + 150.0 * math.sin(a));
    });
  }

  static List<LatLng> get hudsonShore => line(<List<double>>[
    [50, -880],
    [60, -900],
    [72, -915],
    [86, -930],
    [100, -945],
    [116, -965],
    [128, -1000],
  ]);

  static List<LatLng> get eastShore => line(<List<double>>[
    [50, 2060],
    [60, 2105],
    [72, 2150],
    [84, 2170],
    [96, 2160],
    [110, 2120],
    [124, 2040],
  ]);

  static List<LatLng> get broadway => line(<List<double>>[
    [55, 15],
    [64, -70],
    [72, -150],
    [82, -235],
    [94, -320],
    [108, -395],
    [122, -455],
  ]);

  static List<Road> roads() {
    final roads = <Road>[];
    avenueOffsets.forEach((name, offset) {
      final crossesPark = offset > 0 && offset < fifth;
      if (crossesPark) return;
      roads.add(
        Road(
          name,
          RoadRank.avenue,
          line(<List<double>>[
            [44, offset],
            [126, offset],
          ]),
        ),
      );
    });
    roads.add(Road('Broadway', RoadRank.avenue, broadway));
    roads.add(
      Road(
        'Henry Hudson Pkwy',
        RoadRank.highway,
        line(<List<double>>[
          [46, -780],
          [126, -800],
        ]),
      ),
    );
    roads.add(
      Road(
        'FDR Drive',
        RoadRank.highway,
        line(<List<double>>[
          [46, 1990],
          [64, 2040],
          [80, 2090],
          [96, 2090],
          [112, 2050],
          [126, 1975],
        ]),
      ),
    );

    const transverses = <double>[65, 79, 86, 97];
    for (var s = 44; s <= 126; s++) {
      final inPark = s > 59 && s < 110;
      if (!inPark) {
        roads.add(
          Road(
            'E ${s}th St',
            RoadRank.street,
            line(<List<double>>[
              [s.toDouble(), -640],
              [s.toDouble(), 2060],
            ]),
          ),
        );
      } else {
        roads.add(
          Road(
            'W ${s}th St',
            RoadRank.street,
            line(<List<double>>[
              [s.toDouble(), -640],
              [s.toDouble(), centralParkWest],
            ]),
          ),
        );
        roads.add(
          Road(
            'E ${s}th St',
            RoadRank.street,
            line(<List<double>>[
              [s.toDouble(), fifth],
              [s.toDouble(), 2060],
            ]),
          ),
        );
        if (transverses.contains(s.toDouble())) {
          roads.add(
            Road(
              '${s}th St Transverse',
              RoadRank.park,
              line(<List<double>>[
                [s.toDouble(), centralParkWest],
                [s.toDouble(), fifth],
              ]),
            ),
          );
        }
      }
    }

    roads.add(Road('West Drive', RoadRank.park, parkDrive(west: true)));
    roads.add(Road('East Drive', RoadRank.park, parkDrive(west: false)));
    return roads;
  }

  static List<LatLng> parkDrive({required bool west}) {
    final v = west ? parkWestDrive : parkEastDrive;
    return line(<List<double>>[
      [60.5, v],
      [109, v],
    ]);
  }

  static List<LatLng> get parkLoop => smoothPath(
    line(<List<double>>[
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
    ]),
    passes: 2,
  );

  static List<LatLng> get reservoirLoop => smoothPath(
    line(<List<double>>[
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
    ]),
    passes: 2,
  );

  static LatLng get columbusCircle => at(59, -40);
  static LatLng get bethesdaTerrace => at(72, 420);
}
