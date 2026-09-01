import 'package:get/get.dart';

enum ScanPeriod { day, week, month }

class ScanRecord {
  const ScanRecord({
    required this.title,
    required this.score,
    required this.timeLabel,
    required this.dateLabel,
  });

  final String title;
  final int score;
  final String timeLabel;
  final String dateLabel;
}

class ScanInsight {
  const ScanInsight({
    required this.title,
    required this.detail,
    required this.level,
  });

  final String title;
  final String detail;
  final String level;
}

class ScanController extends GetxController {
  final period = ScanPeriod.week.obs;
  final healthScore = 92.obs;

  static const weekBars = [68.0, 74.0, 82.0, 92.0, 88.0, 85.0, 90.0, 86.0];
  static const dayBars = [84.0, 86.0, 88.0, 90.0, 91.0, 92.0, 90.0, 92.0];
  static const monthBars = [72.0, 78.0, 82.0, 85.0, 88.0, 90.0, 91.0, 92.0];

  static const recentScans = [
    ScanRecord(
      title: 'Full Body Scan',
      score: 92,
      timeLabel: '2:14 PM',
      dateLabel: 'Today',
    ),
    ScanRecord(
      title: 'Skin Analysis',
      score: 88,
      timeLabel: '11:40 AM',
      dateLabel: 'Today',
    ),
    ScanRecord(
      title: 'Vitals Check',
      score: 85,
      timeLabel: '9:05 AM',
      dateLabel: 'Yesterday',
    ),
  ];

  static const insights = [
    ScanInsight(
      title: 'Skin Health',
      detail: 'Hydration levels are optimal',
      level: 'Good',
    ),
    ScanInsight(
      title: 'Posture',
      detail: 'Slight forward neck tilt detected',
      level: 'Watch',
    ),
    ScanInsight(
      title: 'Eye Strain',
      detail: 'Screen time fatigue is moderate',
      level: 'Fair',
    ),
    ScanInsight(
      title: 'Recovery',
      detail: 'Rest quality improved this week',
      level: 'Good',
    ),
  ];

  List<double> get chartBars => switch (period.value) {
        ScanPeriod.day => dayBars,
        ScanPeriod.week => weekBars,
        ScanPeriod.month => monthBars,
      };

  int get averageScore => switch (period.value) {
        ScanPeriod.day => 90,
        ScanPeriod.week => 88,
        ScanPeriod.month => 86,
      };

  int get aiConfidence => switch (period.value) {
        ScanPeriod.day => 97,
        ScanPeriod.week => 95,
        ScanPeriod.month => 93,
      };

  void setPeriod(ScanPeriod value) => period.value = value;

  String get periodLabel => switch (period.value) {
        ScanPeriod.day => 'March 26',
        ScanPeriod.week => 'March 20 - March 27',
        ScanPeriod.month => 'March 2026',
      };
}
