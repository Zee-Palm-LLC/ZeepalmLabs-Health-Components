import 'dart:math' as math;

import '../models/run_model.dart';
import '../models/run_stats.dart';
import 'routes.dart';

class HeartRateZone {
  const HeartRateZone(this.tag, this.name, this.share, this.seconds);

  final String tag;
  final String name;
  final double share;
  final int seconds;
}

class MockRuns {
  MockRuns._();

  static const List<int> _summarySplitPaces = <int>[
    336,
    325,
    322,
    313,
    308,
    320,
    316,
    312,
  ];

  static const List<int> _summarySplitHr = <int>[
    138,
    146,
    151,
    156,
    159,
    157,
    161,
    166,
  ];

  static final RunStats summaryStats = RunStats(
    distanceKm: 8.42,
    durationSeconds: 2681,
    avgPaceSeconds: 318,
    heartRate: 154,
    maxHeartRate: 171,
    calories: 612,
    elevationMeters: 84,
    cadence: 178,
    splits: List<RunSplit>.generate(
      _summarySplitPaces.length,
      (i) => RunSplit(
        kilometre: i + 1,
        paceSeconds: _summarySplitPaces[i],
        heartRate: _summarySplitHr[i],
        elevation: MockRoutes.riversideLoop.elevationAt(
          (i + 1) / MockRoutes.riversideLoop.distanceKm,
        ),
      ),
    ),
  );

  static final RunModel completedRun = RunModel(
    id: 'run_riverside_0426',
    title: 'Riverside Loop',
    subtitle: 'Evening Run',
    startedAt: DateTime(2026, 4, 26, 19, 12),
    route: MockRoutes.riversideLoop,
    stats: summaryStats,
  );

  static const List<HeartRateZone> zones = <HeartRateZone>[
    HeartRateZone('Z5', 'Anaerobic', 0.07, 188),
    HeartRateZone('Z4', 'Threshold', 0.18, 482),
    HeartRateZone('Z3', 'Tempo', 0.36, 965),
    HeartRateZone('Z2', 'Aerobic', 0.28, 751),
    HeartRateZone('Z1', 'Easy', 0.11, 295),
  ];

  static final PlannedRun plannedRun = PlannedRun(
    route: MockRoutes.riversideLoop,
    label: 'Tonight',
    note: 'Your usual evening route',
    targetPaceSeconds: 318,
    estimatedSeconds: 2640,
    lastRunDaysAgo: 3,
  );

  static PlannedRun planFor(int index) {
    final route = MockRoutes.all[index % MockRoutes.all.length];
    const notes = <String>[
      'Your usual evening route',
      'Six loops of city quiet',
      'Short, fast, and flat out',
      'Long river tempo, wind at your back',
      'Grid sprints between the lights',
      'The hills that make the rest easy',
    ];
    const paces = <int>[318, 312, 296, 306, 288, 330];
    final pace = paces[index % paces.length];
    return PlannedRun(
      route: route,
      label: 'Tonight',
      note: notes[index % notes.length],
      targetPaceSeconds: pace,
      estimatedSeconds: (route.distanceKm * pace).round(),
      lastRunDaysAgo: 2 + index * 3,
    );
  }

  static double paceFactorAt(double progress) {
    final warmup = 1.10 - 0.10 * math.min(1.0, progress / 0.12);
    final drift = 0.03 * math.sin(progress * math.pi * 5.0);
    final finish = progress > 0.86 ? -0.05 * (progress - 0.86) / 0.14 : 0.0;
    return warmup + drift + finish;
  }

  static int heartRateAt(double progress, {int base = 118, int peak = 171}) {
    final ramp = math.min(1.0, progress / 0.18);
    final wave = 0.06 * math.sin(progress * math.pi * 7.3);
    final value = base + (peak - base) * (0.78 * ramp + 0.22 * progress + wave);
    return value.round().clamp(base, peak);
  }
}
