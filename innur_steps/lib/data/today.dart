import 'package:flutter/widgets.dart';

/// One day in the week strip.
@immutable
class DayRing {
  const DayRing({
    required this.letter,
    required this.day,
    required this.progress,
    this.isToday = false,
  });

  /// Single-letter weekday label.
  final String letter;
  final int day;

  /// 0..1 of the daily move goal.
  final double progress;

  final bool isToday;
}

/// A person on the leaderboard.
///
/// The names and faces here are placeholders — the reference recording was
/// somebody's real leaderboard, and none of those people are reproduced.
@immutable
class Racer {
  const Racer({
    required this.name,
    required this.steps,
    required this.photo,
    required this.tint,
    this.streak,
    this.isYou = false,
  });

  final String name;
  final int steps;

  /// Remote avatar. [tint] is what shows while it loads, and if it never does.
  ///
  /// Served from a host that sends `Access-Control-Allow-Origin`, which matters
  /// only on web — CanvasKit fetches image bytes over XHR, so an image host
  /// without CORS headers loads fine on Android and iOS and fails silently in
  /// a browser.
  final String photo;
  final Color tint;

  /// Day streak, when they have one running.
  final int? streak;

  final bool isYou;
}

/// Everything the today screen shows, in one place so the screen itself stays
/// a layout and nothing else.
@immutable
class TodayData {
  const TodayData({
    required this.week,
    required this.steps,
    required this.kilometres,
    required this.kcal,
    required this.goalPercent,
    required this.standing,
    required this.field,
    required this.podium,
    required this.rest,
    required this.streak,
    required this.syncNote,
  });

  final List<DayRing> week;
  final int steps;
  final double kilometres;
  final int kcal;
  final int goalPercent;

  /// Your position, and how many are in the group.
  final int standing;
  final int field;

  /// Second, first, third — in the order they are laid out.
  final List<Racer> podium;

  /// Fourth place down. The podium covers the top three; everyone else is a
  /// row, and the user's own row is marked so it can be found at a glance.
  final List<Racer> rest;

  final int streak;

  /// Where the numbers came from. Worth saying on a health screen: the user
  /// should never have to wonder whether what they are looking at is live.
  final String syncNote;

  static const TodayData sample = TodayData(
    week: <DayRing>[
      DayRing(letter: 'M', day: 29, progress: 0.62),
      DayRing(letter: 'T', day: 30, progress: 0.88),
      DayRing(letter: 'W', day: 31, progress: 0.45),
      DayRing(letter: 'T', day: 1, progress: 1),
      DayRing(letter: 'F', day: 2, progress: 0.71),
      DayRing(letter: 'S', day: 3, progress: 0.28),
      DayRing(letter: 'S', day: 4, progress: 0.84, isToday: true),
    ],
    steps: 8412,
    kilometres: 6.24,
    kcal: 412,
    goalPercent: 84,
    standing: 3,
    field: 12,
    streak: 6,
    syncNote: 'Synced from Health · 2 min ago',
    podium: <Racer>[
      Racer(
        name: 'Amara Okafor',
        steps: 9155,
        photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240&h=240&fit=crop&crop=faces&q=70',
        tint: Color(0xFF4C5A73),
      ),
      Racer(
        name: 'Noah Feldman',
        steps: 12740,
        photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=240&h=240&fit=crop&crop=faces&q=70',
        tint: Color(0xFF6B5230),
        streak: 14,
      ),
      Racer(
        name: 'You',
        steps: 8412,
        photo: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=240&h=240&fit=crop&crop=faces&q=70',
        tint: Color(0xFF5A4A6B),
        isYou: true,
      ),
    ],
    rest: <Racer>[
      Racer(
        name: 'Leo Marchetti',
        steps: 7980,
        photo:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=faces&q=70',
        tint: Color(0xFF3E5166),
      ),
      Racer(
        name: 'Sofia Ramos',
        steps: 7412,
        photo:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=160&h=160&fit=crop&crop=faces&q=70',
        tint: Color(0xFF5C4A5E),
        streak: 3,
      ),
      Racer(
        name: 'Kenji Watanabe',
        steps: 6890,
        photo:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=160&h=160&fit=crop&crop=faces&q=70',
        tint: Color(0xFF3F5C52),
      ),
      Racer(
        name: 'Hannah Reid',
        steps: 6355,
        photo:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=160&h=160&fit=crop&crop=faces&q=70',
        tint: Color(0xFF6A4B4B),
      ),
      Racer(
        name: 'Tomas Novak',
        steps: 5902,
        photo:
            'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?w=160&h=160&fit=crop&crop=faces&q=70',
        tint: Color(0xFF44506B),
        streak: 2,
      ),
      Racer(
        name: 'Ava Lindqvist',
        steps: 5140,
        photo:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=160&h=160&fit=crop&crop=faces&q=70',
        tint: Color(0xFF5B5570),
      ),
      Racer(
        name: 'Idris Bello',
        steps: 4688,
        photo:
            'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=160&h=160&fit=crop&crop=faces&q=70',
        tint: Color(0xFF4E5B44),
      ),
    ],
  );
}

extension Standings on TodayData {
  /// The whole field in finishing order: the podium re-ordered to 1-2-3, then
  /// everyone else. [podium] is stored in *layout* order (2, 1, 3), which is
  /// not the order anybody ranks in.
  List<Racer> get ranked => <Racer>[
        podium[1],
        podium[0],
        podium[2],
        ...rest,
      ];
}

/// 8412 -> 8,412.
String grouped(int value) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}
