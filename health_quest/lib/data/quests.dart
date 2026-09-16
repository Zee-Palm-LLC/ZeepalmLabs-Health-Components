import 'package:flutter/widgets.dart';

import '../core/palette.dart';
import '../widgets/painters/quest_icons.dart';

@immutable
class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.blurb,
    required this.glyph,
    required this.tone,
    required this.xp,
    required this.progress,
    required this.unit,
    required this.current,
    required this.target,
    required this.cheer,
    required this.milestones,
    required this.nextReward,
  });

  final String id;
  final String title;
  final String blurb;
  final QuestGlyph glyph;
  final Color tone;
  final int xp;

  final double progress;

  final String unit;
  final int current;
  final int target;

  final String cheer;

  final List<int> milestones;
  final String nextReward;

  bool get done => progress >= 1;
  int get percent => (progress * 100).round();

  static const List<Quest> today = <Quest>[
    Quest(
      id: 'water',
      title: 'Drink 2L Water',
      blurb: 'Stay hydrated!',
      glyph: QuestGlyph.drop,
      tone: Quests.blue,
      xp: 50,
      progress: 0.70,
      unit: 'ML',
      current: 1400,
      target: 2000,
      cheer: 'Keep sipping, Warrior!',
      milestones: <int>[500, 1000, 1500, 2000],
      nextReward: 'Hydro Hero',
    ),
    Quest(
      id: 'steps',
      title: 'Walk 5,000 Steps',
      blurb: 'Keep moving!',
      glyph: QuestGlyph.footprints,
      tone: Quests.green,
      xp: 75,
      progress: 0.76,
      unit: 'STEPS',
      current: 3842,
      target: 5000,
      cheer: 'Keep moving, Warrior!',
      milestones: <int>[2500, 5000, 10000, 15000],
      nextReward: 'Step Master',
    ),
    Quest(
      id: 'meditation',
      title: '10 Min Meditation',
      blurb: 'Calm your mind',
      glyph: QuestGlyph.lotus,
      tone: Quests.purple,
      xp: 30,
      progress: 1.0,
      unit: 'MIN',
      current: 10,
      target: 10,
      cheer: 'Beautifully done, Warrior!',
      milestones: <int>[5, 10, 20, 30],
      nextReward: 'Still Mind',
    ),
  ];

  static int get completed => today.where((Quest q) => q.done).length;
}

@immutable
class Reward {
  const Reward({
    required this.name,
    required this.blurb,
    required this.glyph,
    required this.tone,
    required this.cost,
    required this.owned,
    this.unlocksAtLevel,
  });

  final String name;
  final String blurb;
  final QuestGlyph glyph;
  final Color tone;

  final int cost;
  final bool owned;

  final int? unlocksAtLevel;

  static const List<Reward> all = <Reward>[
    Reward(
      name: 'Step Master',
      blurb: 'Walk 5,000 steps seven days running.',
      glyph: QuestGlyph.trophy,
      tone: Quests.gold,
      cost: 500,
      owned: true,
    ),
    Reward(
      name: 'Hydro Hero',
      blurb: 'Hit your water goal ten times.',
      glyph: QuestGlyph.drop,
      tone: Quests.blue,
      cost: 750,
      owned: true,
    ),
    Reward(
      name: 'Still Mind',
      blurb: 'Meditate every morning for a week.',
      glyph: QuestGlyph.lotus,
      tone: Quests.purple,
      cost: 1200,
      owned: false,
    ),
    Reward(
      name: 'Night Owl Cure',
      blurb: 'Sleep before midnight five nights.',
      glyph: QuestGlyph.moon,
      tone: Quests.blueBright,
      cost: 1800,
      owned: false,
    ),
    Reward(
      name: 'Iron Streak',
      blurb: 'Thirty days without missing a quest.',
      glyph: QuestGlyph.flame,
      tone: Quests.rose,
      cost: 2500,
      owned: false,
      unlocksAtLevel: 15,
    ),
    Reward(
      name: 'Ascendant',
      blurb: 'Reach level twenty. The rarest badge.',
      glyph: QuestGlyph.crown,
      tone: Quests.goldBright,
      cost: 5000,
      owned: false,
      unlocksAtLevel: 20,
    ),
  ];
}

@immutable
class Player {
  const Player({
    required this.name,
    required this.title,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.streakDays,
    required this.multiplier,
    required this.healthScore,
  });

  final String name;
  final String title;
  final int level;
  final int xp;
  final int xpToNext;
  final int streakDays;
  final int multiplier;
  final int healthScore;

  double get xpFraction => (xp / xpToNext).clamp(0.0, 1.0);

  int get balance => xp;

  static const Player you = Player(
    name: 'PLAYER!',
    title: 'WELLNESS WARRIOR',
    level: 12,
    xp: 2840,
    xpToNext: 4000,
    streakDays: 7,
    multiplier: 2,
    healthScore: 87,
  );
}

String grouped(int value) {
  final s = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}
