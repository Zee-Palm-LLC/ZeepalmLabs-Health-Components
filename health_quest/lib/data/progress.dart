import 'package:flutter/widgets.dart';

import '../core/palette.dart';
import '../widgets/painters/quest_icons.dart';
import 'stats.dart';

@immutable
class StatStanding {
  const StatStanding({
    required this.stat,
    required this.level,
    required this.progress,
    required this.weekGain,
  });

  final Stat stat;
  final int level;

  final double progress;

  final int weekGain;

  static const int cap = 20;

  static final List<StatStanding> all = <StatStanding>[
    StatStanding(stat: Stat.all[0], level: 14, progress: 0.62, weekGain: 640),
    StatStanding(stat: Stat.all[1], level: 9, progress: 0.35, weekGain: 280),
    StatStanding(stat: Stat.all[2], level: 11, progress: 0.81, weekGain: 450),
    StatStanding(stat: Stat.all[3], level: 16, progress: 0.18, weekGain: 720),
  ];

  static int get power =>
      all.fold<int>(0, (int sum, StatStanding s) => sum + s.level);
}

enum Period { week, month }

@immutable
class XpHistory {
  const XpHistory._(this.period, this.values);

  final Period period;
  final List<int> values;

  static const XpHistory week = XpHistory._(Period.week, <int>[
    320,
    410,
    180,
    520,
    460,
    610,
    240,
  ]);
  static const XpHistory month = XpHistory._(Period.month, <int>[
    1840,
    2210,
    1960,
    2750,
  ]);

  static XpHistory of(Period p) => p == Period.week ? week : month;

  int get total => values.fold<int>(0, (int a, int b) => a + b);
  int get best => values.reduce((int a, int b) => a > b ? a : b);
  int get average => (total / values.length).round();

  List<String> labels(DateTime now) {
    if (period == Period.month) {
      return <String>['W1', 'W2', 'W3', 'NOW'];
    }
    const days = <String>['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return <String>[
      for (var i = values.length - 1; i >= 0; i--)
        i == 0 ? 'TODAY' : days[(now.weekday - 1 - i) % 7],
    ];
  }
}

@immutable
class PersonalRecord {
  const PersonalRecord({
    required this.label,
    required this.value,
    required this.unit,
    required this.glyph,
    required this.tone,
  });

  final String label;
  final String value;
  final String unit;
  final QuestGlyph glyph;
  final Color tone;

  static const List<PersonalRecord> all = <PersonalRecord>[
    PersonalRecord(
      label: 'BEST STREAK',
      value: '21',
      unit: 'DAYS',
      glyph: QuestGlyph.flame,
      tone: Quests.gold,
    ),
    PersonalRecord(
      label: 'QUESTS DONE',
      value: '148',
      unit: 'TOTAL',
      glyph: QuestGlyph.swords,
      tone: Quests.purple,
    ),
    PersonalRecord(
      label: 'STEPS',
      value: '38,420',
      unit: 'THIS WEEK',
      glyph: QuestGlyph.footprints,
      tone: Quests.green,
    ),
    PersonalRecord(
      label: 'WATER',
      value: '12.6',
      unit: 'LITRES',
      glyph: QuestGlyph.drop,
      tone: Quests.blue,
    ),
  ];
}

@immutable
class Achievement {
  const Achievement({
    required this.name,
    required this.blurb,
    required this.glyph,
    required this.tone,
    required this.current,
    required this.target,
  });

  final String name;
  final String blurb;
  final QuestGlyph glyph;
  final Color tone;
  final int current;
  final int target;

  bool get done => current >= target;
  double get progress => (current / target).clamp(0.0, 1.0);

  static const List<Achievement> all = <Achievement>[
    Achievement(
      name: 'First Blood',
      blurb: 'Finish your first quest',
      glyph: QuestGlyph.swords,
      tone: Quests.green,
      current: 1,
      target: 1,
    ),
    Achievement(
      name: 'Tidal Force',
      blurb: 'Hit the water goal 10 days',
      glyph: QuestGlyph.drop,
      tone: Quests.blue,
      current: 10,
      target: 10,
    ),
    Achievement(
      name: 'Early Riser',
      blurb: 'Meditate before 8am, 5 times',
      glyph: QuestGlyph.lotus,
      tone: Quests.purple,
      current: 3,
      target: 5,
    ),
    Achievement(
      name: 'Marathoner',
      blurb: 'Walk 42,195 steps in a week',
      glyph: QuestGlyph.footprints,
      tone: Quests.gold,
      current: 38420,
      target: 42195,
    ),
  ];
}

const List<int> activityGrid = <int>[
  1,
  2,
  0,
  3,
  2,
  4,
  1,
  2,
  3,
  3,
  1,
  0,
  2,
  4,
  3,
  4,
  2,
  4,
  3,
  1,
  2,
  4,
  3,
  4,
  4,
  2,
  3,
  4,
  4,
  4,
  3,
  4,
  4,
  4,
  2,
];
