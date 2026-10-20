import 'dart:math' as math;

/// Demo data for Tue, Oct 27 2026. Every screen reads from here so the same
/// 62 bpm shows up everywhere.
abstract final class Demo {
  static final today = DateTime(2026, 10, 27);
  static const updated = '7:42';

  static const restingHr = 62;
  static const restingAvg = 65;
  static const rangeLow = 61;
  static const rangeHigh = 66;

  static const rhr30 = [66, 65, 66, 64, 65, 66, 65, 64, 66, 66, 68, 66, 65, 64, 65, 66, 66, 67, 65, 64, 65, 66, 65, 67, 64, 63, 63, 62, 63, 62];

  static final List<int> rhr90 = [
    for (var i = 0; i < 60; i++) (65 + 1.4 * math.sin(i * 0.71) + 0.7 * math.sin(i * 1.93)).round().clamp(63, 67),
    ...rhr30,
  ];

  static List<int> rhr(int days) => switch (days) {
    7 => rhr30.sublist(23),
    30 => rhr30,
    _ => rhr90,
  };

  static const notes = {'Oct 21': 'after a late workout', 'Oct 15': 'travel day', 'Oct 8': 'short sleep'};

  static const hrv = 48;
  static const hrvAvg = 44;
  static const hrvLow = 40;
  static const hrv30 = [42, 44, 41, 45, 43, 40, 44, 46, 43, 41, 38, 45, 44, 42, 40, 39, 43, 45, 46, 44, 47, 44, 46, 41, 45, 48, 47, 46, 49, 48];

  static const sleepMinutes = 432;
  static const sleepNeed = 508;

  /// Last 7 nights, oldest first: deep, REM, light, awake (minutes).
  static const nights = [
    [58, 72, 250, 34],
    [70, 96, 262, 22],
    [76, 102, 270, 18],
    [64, 88, 244, 26],
    [82, 110, 284, 16],
    [74, 98, 266, 20],
    [72, 94, 266, 21],
  ];

  static const steps = 6840;
  static const stepGoal = 8000;
  static const respiratory = 14.2;

  static const meds = [
    Med('08:00', 'Metformin', '500 mg', taken: '08:12'),
    Med('20:00', 'Atorvastatin', '10 mg'),
  ];

  static DateTime dayOf(int index, int count) => today.subtract(Duration(days: count - 1 - index));

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static String label(DateTime d) => '${_months[d.month - 1]} ${d.day}';
  static String weekday(DateTime d) => _weekdays[d.weekday - 1];

  static String hm(int minutes) {
    final h = minutes ~/ 60, m = minutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  static String thousands(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  static int average(List<int> xs) => (xs.reduce((a, b) => a + b) / xs.length).round();
}

class Med {
  const Med(this.time, this.name, this.dose, {this.taken});

  final String time;
  final String name;
  final String dose;
  final String? taken;
}
