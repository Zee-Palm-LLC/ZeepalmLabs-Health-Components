class RunSplit {
  const RunSplit({
    required this.kilometre,
    required this.paceSeconds,
    required this.heartRate,
    required this.elevation,
  });

  final int kilometre;
  final int paceSeconds;
  final int heartRate;
  final double elevation;
}

class RunStats {
  const RunStats({
    required this.distanceKm,
    required this.durationSeconds,
    required this.avgPaceSeconds,
    required this.heartRate,
    required this.maxHeartRate,
    required this.calories,
    required this.elevationMeters,
    required this.cadence,
    required this.splits,
  });

  final double distanceKm;
  final int durationSeconds;
  final int avgPaceSeconds;
  final int heartRate;
  final int maxHeartRate;
  final int calories;
  final double elevationMeters;
  final int cadence;
  final List<RunSplit> splits;

  RunSplit get fastestSplit =>
      splits.reduce((a, b) => a.paceSeconds <= b.paceSeconds ? a : b);

  int get slowestPace =>
      splits.map((s) => s.paceSeconds).reduce((a, b) => a > b ? a : b);

  int get fastestPace => fastestSplit.paceSeconds;
}

class LifetimeStats {
  const LifetimeStats({
    required this.distanceKm,
    required this.runs,
    required this.hours,
    required this.elevationMeters,
    required this.longestRunKm,
    required this.bestPaceSeconds,
    required this.monthly,
  });

  final double distanceKm;
  final int runs;
  final double hours;
  final int elevationMeters;
  final double longestRunKm;
  final int bestPaceSeconds;
  final List<double> monthly;
}
