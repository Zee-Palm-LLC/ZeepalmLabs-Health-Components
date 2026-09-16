import 'package:flutter/widgets.dart';

import '../core/palette.dart';
import '../widgets/painters/quest_icons.dart';

@immutable
class Rival {
  const Rival({
    required this.name,
    required this.title,
    required this.level,
    required this.weeklyXp,
    required this.tone,
    this.isYou = false,
  });

  final String name;
  final String title;
  final int level;
  final int weeklyXp;
  final Color tone;
  final bool isYou;

  String get initials => isYou ? 'YOU' : name.substring(0, 2).toUpperCase();

  static const List<Rival> friends = <Rival>[
    Rival(
      name: 'Nova',
      title: 'Iron Monk',
      level: 18,
      weeklyXp: 3420,
      tone: Quests.gold,
    ),
    Rival(
      name: 'Kai',
      title: 'Trail Runner',
      level: 15,
      weeklyXp: 3105,
      tone: Quests.blue,
    ),
    Rival(
      name: 'Mira',
      title: 'Zen Keeper',
      level: 14,
      weeklyXp: 2890,
      tone: Quests.rose,
    ),
    Rival(
      name: 'PLAYER!',
      title: 'Wellness Warrior',
      level: 12,
      weeklyXp: 2740,
      tone: Quests.purple,
      isYou: true,
    ),
    Rival(
      name: 'Theo',
      title: 'Hydro Knight',
      level: 11,
      weeklyXp: 2310,
      tone: Quests.green,
    ),
    Rival(
      name: 'Ivy',
      title: 'Dawn Walker',
      level: 10,
      weeklyXp: 1985,
      tone: Quests.blueBright,
    ),
    Rival(
      name: 'Rex',
      title: 'Couch Escapee',
      level: 7,
      weeklyXp: 1240,
      tone: Quests.goldBright,
    ),
  ];

  static const List<Rival> global = <Rival>[
    Rival(
      name: 'Aurora',
      title: 'Ascendant',
      level: 42,
      weeklyXp: 9860,
      tone: Quests.gold,
    ),
    Rival(
      name: 'Blaze',
      title: 'Marathon Lord',
      level: 39,
      weeklyXp: 9410,
      tone: Quests.rose,
    ),
    Rival(
      name: 'Sage',
      title: 'Mind Master',
      level: 37,
      weeklyXp: 9025,
      tone: Quests.purple,
    ),
    Rival(
      name: 'Orion',
      title: 'Iron Streak',
      level: 35,
      weeklyXp: 8760,
      tone: Quests.blue,
    ),
    Rival(
      name: 'Luna',
      title: 'Night Owl Cure',
      level: 33,
      weeklyXp: 8420,
      tone: Quests.blueBright,
    ),
    Rival(
      name: 'Jett',
      title: 'Step Master',
      level: 31,
      weeklyXp: 8105,
      tone: Quests.green,
    ),
    Rival(
      name: 'PLAYER!',
      title: 'Wellness Warrior',
      level: 12,
      weeklyXp: 2740,
      tone: Quests.purple,
      isYou: true,
    ),
  ];

  static int rankIn(List<Rival> board) => identical(board, global)
      ? 1284
      : board.indexWhere((Rival r) => r.isYou) + 1;
}

enum NotificationKind { quest, level, badge, streak, social }

@immutable
class GameNotification {
  const GameNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    required this.today,
    this.unread = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String time;
  final bool today;
  final bool unread;

  QuestGlyph get glyph => switch (kind) {
    NotificationKind.quest => QuestGlyph.check,
    NotificationKind.level => QuestGlyph.shield,
    NotificationKind.badge => QuestGlyph.trophy,
    NotificationKind.streak => QuestGlyph.flame,
    NotificationKind.social => QuestGlyph.swords,
  };

  Color get tone => switch (kind) {
    NotificationKind.quest => Quests.green,
    NotificationKind.level => Quests.purple,
    NotificationKind.badge => Quests.gold,
    NotificationKind.streak => Quests.rose,
    NotificationKind.social => Quests.blue,
  };

  static const List<GameNotification> all = <GameNotification>[
    GameNotification(
      id: 'n1',
      kind: NotificationKind.quest,
      title: 'Quest complete',
      body: '10 Min Meditation is done. Claim your XP before midnight.',
      time: '8 min ago',
      today: true,
      unread: true,
    ),
    GameNotification(
      id: 'n2',
      kind: NotificationKind.social,
      title: 'Kai overtook you',
      body: 'Kai is 365 XP ahead on the friends board. Take the spot back.',
      time: '1 h ago',
      today: true,
      unread: true,
    ),
    GameNotification(
      id: 'n3',
      kind: NotificationKind.streak,
      title: 'Streak on the line',
      body: 'Finish one more quest today to make it 8 days.',
      time: '3 h ago',
      today: true,
      unread: true,
    ),
    GameNotification(
      id: 'n4',
      kind: NotificationKind.badge,
      title: 'Badge unlocked: Hydro Hero',
      body: 'Ten days of hitting your water goal. It is on your profile now.',
      time: 'Yesterday',
      today: false,
    ),
    GameNotification(
      id: 'n5',
      kind: NotificationKind.level,
      title: 'Level 12 reached',
      body: 'New title: Wellness Warrior. Global league unlocked.',
      time: '2 days ago',
      today: false,
    ),
    GameNotification(
      id: 'n6',
      kind: NotificationKind.quest,
      title: 'Weekly quest cleared',
      body: 'Walk 35,000 steps in a week. +300 XP banked.',
      time: '4 days ago',
      today: false,
    ),
  ];
}
