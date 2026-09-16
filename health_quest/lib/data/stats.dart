import 'package:flutter/foundation.dart';

import '../core/palette.dart';
import '../widgets/painters/stat_icons.dart';

@immutable
class Stat {
  const Stat({
    required this.id,
    required this.label,
    required this.glyph,
    required this.tone,
    required this.blurb,
    this.level = 1,
  });

  final String id;
  final String label;
  final StatGlyph glyph;
  final StatTone tone;

  final String blurb;
  final int level;

  String get levelLabel => 'Lv. ${level.toString().padLeft(2, '0')}';

  static const List<Stat> all = <Stat>[
    Stat(
      id: 'physical',
      label: 'PHYSICAL',
      glyph: StatGlyph.heart,
      tone: StatTone.physical,
      blurb: 'Move, stretch, and rest. Every session earns XP.',
    ),
    Stat(
      id: 'mental',
      label: 'MENTAL',
      glyph: StatGlyph.brain,
      tone: StatTone.mental,
      blurb: 'Breathe, focus, and wind down. Calm is a skill.',
    ),
    Stat(
      id: 'energy',
      label: 'ENERGY',
      glyph: StatGlyph.bolt,
      tone: StatTone.energy,
      blurb: 'Sleep and fuel well. Energy powers every stat.',
    ),
    Stat(
      id: 'hydration',
      label: 'HYDRATION',
      glyph: StatGlyph.drop,
      tone: StatTone.hydration,
      blurb: 'Two litres a day. The easiest XP in the game.',
    ),
  ];
}
