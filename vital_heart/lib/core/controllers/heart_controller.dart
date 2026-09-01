import 'dart:async';

import 'package:get/get.dart';

enum HeartPeriod { day, week, month }

class HeartRecord {
  const HeartRecord({
    required this.bpm,
    required this.timeLabel,
    required this.dateLabel,
  });

  final int bpm;
  final String timeLabel;
  final String dateLabel;
}

class HeartController extends GetxController {
  final period = HeartPeriod.week.obs;
  final liveBpm = 72.obs;

  Timer? _pulseTimer;
  var _tick = 0;

  static const weekBars = [42.0, 58.0, 72.0, 110.0, 95.0, 68.0, 52.0, 88.0];
  static const dayBars = [62.0, 68.0, 72.0, 70.0, 66.0, 74.0, 69.0, 71.0];
  static const monthBars = [58.0, 64.0, 68.0, 72.0, 75.0, 70.0, 66.0, 80.0];

  static const history = [
    HeartRecord(bpm: 72, timeLabel: '12:00 PM', dateLabel: '26 March 2021'),
    HeartRecord(bpm: 68, timeLabel: '11:30 AM', dateLabel: '26 March 2021'),
    HeartRecord(bpm: 75, timeLabel: '11:00 AM', dateLabel: '26 March 2021'),
    HeartRecord(bpm: 70, timeLabel: '10:30 AM', dateLabel: '26 March 2021'),
  ];

  @override
  void onInit() {
    super.onInit();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      _tick++;
      final wave = [72, 74, 71, 73, 70, 72, 69, 71];
      liveBpm.value = wave[_tick % wave.length];
    });
  }

  @override
  void onClose() {
    _pulseTimer?.cancel();
    super.onClose();
  }

  List<double> get chartBars => switch (period.value) {
        HeartPeriod.day => dayBars,
        HeartPeriod.week => weekBars,
        HeartPeriod.month => monthBars,
      };

  int get averageBpm => switch (period.value) {
        HeartPeriod.day => 69,
        HeartPeriod.week => 68,
        HeartPeriod.month => 70,
      };

  int get maxBpm => switch (period.value) {
        HeartPeriod.day => 74,
        HeartPeriod.week => 110,
        HeartPeriod.month => 95,
      };

  void setPeriod(HeartPeriod value) => period.value = value;

  String get periodLabel => switch (period.value) {
        HeartPeriod.day => 'March 26',
        HeartPeriod.week => 'March 20 - March 27',
        HeartPeriod.month => 'March 2021',
      };
}
