import 'route_point.dart';
import 'run_stats.dart';

class RunModel {
  const RunModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startedAt,
    required this.route,
    required this.stats,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime startedAt;
  final RunRoute route;
  final RunStats stats;
}

class PlannedRun {
  const PlannedRun({
    required this.route,
    required this.label,
    required this.note,
    required this.targetPaceSeconds,
    required this.estimatedSeconds,
    required this.lastRunDaysAgo,
  });

  final RunRoute route;
  final String label;
  final String note;
  final int targetPaceSeconds;
  final int estimatedSeconds;
  final int lastRunDaysAgo;
}
