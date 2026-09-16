import 'package:flutter/widgets.dart';

import '../core/palette.dart';
import '../widgets/painters/quest_icons.dart';

enum MainQuest {
  move(
    'MOVE MORE',
    'Walks, runs and stretches',
    'Starter quest: walk 5,000 steps',
    QuestGlyph.footprints,
    Quests.green,
  ),
  hydrate(
    'HYDRATE',
    'Water goals that build a habit',
    'Starter quest: drink 2L of water',
    QuestGlyph.drop,
    Quests.blue,
  ),
  calm(
    'CALM MIND',
    'Breathing, focus and meditation',
    'Starter quest: 10 minutes of stillness',
    QuestGlyph.lotus,
    Quests.purple,
  ),
  sleep(
    'SLEEP WELL',
    'Wind-downs and steady bedtimes',
    'Starter quest: lights out by 11pm',
    QuestGlyph.moon,
    Quests.blueBright,
  );

  const MainQuest(this.label, this.blurb, this.starter, this.glyph, this.tone);

  final String label;
  final String blurb;
  final String starter;
  final QuestGlyph glyph;
  final Color tone;
}

enum Difficulty {
  casual('CASUAL', '2 quests a day', 1),
  warrior('WARRIOR', '3 quests a day', 2),
  legend('LEGEND', '5 quests a day', 3);

  const Difficulty(this.label, this.blurb, this.stars);

  final String label;
  final String blurb;
  final int stars;
}
