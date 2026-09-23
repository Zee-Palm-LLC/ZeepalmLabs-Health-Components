import 'dart:math' as math;

import '../../data/mock/city_grid.dart';
import '../../utils/geo.dart';

class CityBlock {
  const CityBlock(this.corners, this.height, this.tier);

  final List<LatLng> corners;
  final double height;
  final int tier;
}

class CityLabel {
  const CityLabel(this.text, this.position, this.size, this.spacing);

  final String text;
  final LatLng position;
  final double size;
  final double spacing;
}

class CityGeometry {
  CityGeometry._();

  static final CityGeometry instance = CityGeometry._();

  static const List<double> _westAvenues = <double>[
    CityGrid.riverside,
    CityGrid.westEnd,
    CityGrid.amsterdam,
    CityGrid.columbus,
    CityGrid.centralParkWest,
  ];
  static const List<double> _midtownAvenues = <double>[0, 270, 540, 810];
  static const List<double> _eastAvenues = <double>[
    CityGrid.fifth,
    CityGrid.madison,
    CityGrid.park,
    CityGrid.lexington,
    CityGrid.third,
    CityGrid.second,
    CityGrid.first,
    CityGrid.york,
  ];

  late final List<Road> roads = _buildRoads();
  late final List<CityBlock> blocks = _buildBlocks();
  late final List<LatLng> hudson = _river(CityGrid.hudsonShore, -1600);
  late final List<LatLng> eastRiver = _river(CityGrid.eastShore, 1400);
  late final List<LatLng> park = CityGrid.parkOutline;
  late final List<LatLng> reservoir = CityGrid.reservoirOutline;
  late final List<LatLng> greatLawn = CityGrid.greatLawnOutline;

  late final List<CityLabel> labels = <CityLabel>[
    CityLabel('CENTRAL PARK', CityGrid.at(84, 405), 13, 3.4),
    CityLabel('UPPER WEST SIDE', CityGrid.at(80, -330), 11, 2.8),
    CityLabel('UPPER EAST SIDE', CityGrid.at(80, 1320), 11, 2.8),

    CityLabel('HARLEM', CityGrid.at(118, 420), 11, 2.8),
    CityLabel('MIDTOWN', CityGrid.at(50, 430), 11, 2.8),

    CityLabel('HUDSON RIVER', CityGrid.at(76, -1120), 10, 3.0),
    CityLabel('EAST RIVER', CityGrid.at(88, 2340), 10, 3.0),
  ];

  late final List<LatLng> glowPools = <LatLng>[
    CityGrid.at(50, 430),
    CityGrid.at(56, -60),
    CityGrid.at(66, 1000),
    CityGrid.at(96, -400),
    CityGrid.at(112, 500),
    CityGrid.at(74, 1700),
  ];

  static List<Road> _buildRoads() {
    final roads = CityGrid.roads();
    roads.add(
      Road(
        'Seventh Ave',
        RoadRank.avenue,
        CityGrid.line(<List<double>>[
          [44, 270],
          [59, 270],
        ]),
      ),
    );
    roads.add(
      Road(
        'Sixth Ave',
        RoadRank.avenue,
        CityGrid.line(<List<double>>[
          [44, 540],
          [59, 540],
        ]),
      ),
    );
    return roads;
  }

  static List<CityBlock> _buildBlocks() {
    final blocks = <CityBlock>[];
    final rnd = math.Random(20260923);

    void addRow(double street, List<double> avenues) {
      for (var i = 0; i < avenues.length - 1; i++) {
        final left = avenues[i] + 11;
        final right = avenues[i + 1] - 11;
        if (right - left < 24) continue;
        final south = street + 0.16;
        final north = street + 0.84;
        final roll = rnd.nextDouble();
        final midtown = street < 60 && street > 40;
        final density = midtown ? 1.0 : (street < 96 ? 0.72 : 0.5);
        final height = (18 + roll * roll * 190 * density).toDouble();
        final tier = height > 110 ? 2 : (height > 52 ? 1 : 0);
        blocks.add(
          CityBlock(
            <LatLng>[
              CityGrid.at(south, left),
              CityGrid.at(south, right),
              CityGrid.at(north, right),
              CityGrid.at(north, left),
            ],
            height,
            tier,
          ),
        );
      }
    }

    for (var s = 44; s <= 125; s++) {
      final street = s.toDouble();
      addRow(street, _westAvenues);
      addRow(street, _eastAvenues);
      if (street < 59) addRow(street, _midtownAvenues);
    }
    return blocks;
  }

  static List<LatLng> _river(List<LatLng> shore, double offsetMeters) {
    final far = <LatLng>[];
    for (var i = shore.length - 1; i >= 0; i--) {
      final p = shore[i];
      final dLng = offsetMeters / metersPerDegreeLng(p.lat);
      far.add(LatLng(p.lat, p.lng + dLng));
    }
    final head = shore.first;
    final tail = shore.last;
    return <LatLng>[
      LatLng(head.lat - 0.06, head.lng),
      ...shore,
      LatLng(tail.lat + 0.06, tail.lng),
      LatLng(
        tail.lat + 0.06,
        tail.lng + offsetMeters / metersPerDegreeLng(tail.lat),
      ),
      ...far,
      LatLng(
        head.lat - 0.06,
        head.lng + offsetMeters / metersPerDegreeLng(head.lat),
      ),
    ];
  }
}
