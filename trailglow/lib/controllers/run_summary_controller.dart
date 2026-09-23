import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/mock/routes.dart';
import '../data/mock/runs.dart';
import '../data/models/route_point.dart';
import '../data/models/run_model.dart';
import '../data/models/run_stats.dart';
import 'map_controller.dart';

class RunSummaryController extends GetxController {
  RunSummaryController({
    RunRoute? route,
    double progress = 1.0,
    int? elapsedSeconds,
    this.paceTarget = 318,
  }) : route = route ?? MockRoutes.riversideLoop,
       progress = progress.clamp(0.02, 1.0),
       _elapsed = elapsedSeconds;

  final MapController map = Get.find<MapController>();

  final RunRoute route;
  final double progress;
  final int? _elapsed;
  final int paceTarget;

  late final RunModel run = _buildRun();

  RunStats get stats => run.stats;

  bool get isReferenceRun =>
      progress >= 0.995 && route.id == MockRoutes.riversideLoop.id;

  @override
  void onReady() {
    super.onReady();
    map.showSummary(route, progress);
  }

  void setHeroGap(double gap, double topInset) {
    final next = EdgeInsets.fromLTRB(46, topInset + 62, 46, gap);
    if ((map.summaryPadding.bottom - next.bottom).abs() < 6) return;
    map.summaryPadding = next;
    map.setOrnamentInset(gap - 40);
    map.showSummary(route, progress);
  }

  RunModel _buildRun() {
    if (isReferenceRun) return MockRuns.completedRun;

    final distance = route.distanceKm * progress;
    final fullKm = math.max(1, distance.floor());
    final splits = List<RunSplit>.generate(fullKm, (i) {
      final mid = (i + 0.5) / route.distanceKm;
      final pace = paceTarget * MockRuns.paceFactorAt(mid);
      return RunSplit(
        kilometre: i + 1,
        paceSeconds: pace.round(),
        heartRate: MockRuns.heartRateAt(mid),
        elevation: route.elevationAt(math.min(1.0, mid)),
      );
    });

    final duration =
        _elapsed ??
        splits.fold<int>(0, (sum, s) => sum + s.paceSeconds) +
            ((distance - fullKm) * paceTarget).round();
    final avgPace = distance <= 0 ? paceTarget : (duration / distance).round();

    return RunModel(
      id: 'run_${route.id}',
      title: route.name,
      subtitle: _timeOfDayLabel(),
      startedAt: DateTime.now(),
      route: route,
      stats: RunStats(
        distanceKm: distance,
        durationSeconds: duration,
        avgPaceSeconds: avgPace,
        heartRate: MockRuns.heartRateAt(progress * 0.7),
        maxHeartRate: MockRuns.heartRateAt(progress),
        calories: (distance * 72.7).round(),
        elevationMeters: route.elevationGain * progress,
        cadence: 176,
        splits: splits,
      ),
    );
  }

  String _timeOfDayLabel() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Morning Run';
    if (hour < 16) return 'Afternoon Run';
    if (hour < 21) return 'Evening Run';
    return 'Night Run';
  }

  List<HeartRateZone> get zones {
    if (isReferenceRun) return MockRuns.zones;
    final total = stats.durationSeconds;
    return MockRuns.zones
        .map(
          (z) =>
              HeartRateZone(z.tag, z.name, z.share, (total * z.share).round()),
        )
        .toList(growable: false);
  }
}
