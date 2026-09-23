import '../../utils/geo.dart';
import 'run_stats.dart';

enum HeatmapRange { week, month, year, all }

extension HeatmapRangeLabel on HeatmapRange {
  String get label => switch (this) {
    HeatmapRange.week => 'WEEK',
    HeatmapRange.month => 'MONTH',
    HeatmapRange.year => 'YEAR',
    HeatmapRange.all => 'ALL',
  };
}

class HeatmapPoint {
  const HeatmapPoint(this.position, this.weight);

  final LatLng position;
  final double weight;
}

class HeatmapData {
  const HeatmapData({
    required this.range,
    required this.points,
    required this.traces,
    required this.stats,
  });

  final HeatmapRange range;
  final List<HeatmapPoint> points;
  final List<List<LatLng>> traces;
  final LifetimeStats stats;
}
