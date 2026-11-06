import 'package:flutter/material.dart';

import '../theme.dart';

class Session {
  const Session({
    required this.tag,
    required this.icon,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.menuLabel,
    required this.count,
    required this.mood,
    required this.blob,
    required this.cues,
  });

  final String tag;
  final IconData icon;
  final String time;
  final String title;
  final String subtitle;

  /// Label and count shown once the carousel has folded into the top menu.
  final String menuLabel;
  final String count;

  final Mood mood;

  /// The colour of the soft blob at the top of the card.
  final Color blob;
  final List<String> cues;
}

const sessions = <Session>[
  Session(
    tag: 'Run',
    icon: Icons.directions_run_rounded,
    time: '6:30 am',
    title: 'Easy 5K.',
    subtitle: 'Zone 2, keep it chatty',
    menuLabel: 'Run',
    count: '5',
    mood: Mood.sky,
    blob: Color(0xFF7FA7EE),
    cues: ['Warm up', 'Pace 6:10', 'Cool down'],
  ),
  Session(
    tag: 'Yoga',
    icon: Icons.self_improvement_rounded,
    time: '8:00 am',
    title: 'Open the hips.',
    subtitle: 'Slow flow and deep stretch',
    menuLabel: 'Yoga',
    count: '20',
    mood: Mood.lilac,
    blob: Color(0xFFA48BEF),
    cues: ['Flow', 'Hold 60s', 'Rest'],
  ),
  Session(
    tag: 'Strength',
    icon: Icons.fitness_center_rounded,
    time: '6:00 pm',
    title: 'Upper body push.',
    subtitle: 'Bench, press and dips, 45 min',
    menuLabel: 'Strength',
    count: '45',
    mood: Mood.orange,
    blob: Color(0xFFEF5F22),
    cues: ['Bench 4x8', 'Press 3x10', 'Dips 3x12'],
  ),
  Session(
    tag: 'Cycle',
    icon: Icons.directions_bike_rounded,
    time: '7:15 am',
    title: 'River loop.',
    subtitle: 'Twelve flat kilometres',
    menuLabel: 'Cycle',
    count: '12',
    mood: Mood.green,
    blob: Color(0xFF93C46C),
    cues: ['Spin up', 'Cadence 90', 'Coast'],
  ),
  Session(
    tag: 'Recovery',
    icon: Icons.spa_rounded,
    time: '9:00 pm',
    title: 'Roll it out.',
    subtitle: 'Foam roller and mobility',
    menuLabel: 'Recover',
    count: '15',
    mood: Mood.rose,
    blob: Color(0xFFEE8AA8),
    cues: ['Calves', 'Quads', 'Back'],
  ),
];
