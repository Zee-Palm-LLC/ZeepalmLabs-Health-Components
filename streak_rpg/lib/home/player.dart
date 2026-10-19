import 'package:flutter/widgets.dart';

/// A daily quest row.
class Quest {
  Quest({required this.title, required this.goal, required this.progress, required this.xp, required this.unit});

  final String title;
  final int goal;
  int progress;
  final int xp;

  /// How the counter reads: `fraction` ("1 / 2") or `steps` ("3,240 / 8,000").
  final String unit;

  bool get done => progress >= goal;
}

/// All the mock's numbers in one place, live so screens react to each other:
/// opening the gift or finishing a set really fills the level bar.
class Player extends ChangeNotifier {
  int level = 12;
  int xp = 720;
  int xpGoal = 1000;
  int streak = 12;
  int workouts = 18;
  int minutes = 7 * 60 + 24;
  int calories = 2840;

  int reps = 8;
  int repGoal = 20;
  int sets = 1;
  int setGoal = 3;
  int burn = 48;
  bool chestOpened = false;
  int combo = 0;
  int coins = 1250;
  int stamina = 86;
  int focus = 64;

  /// Tutorial chapters already played this session.
  final seen = <String>{};

  final quests = [
    Quest(title: 'Drink 2L Water', goal: 2, progress: 1, xp: 100, unit: 'fraction'),
    Quest(title: 'Walk 8,000 Steps', goal: 8000, progress: 3240, xp: 150, unit: 'steps'),
    Quest(title: 'Do a 15 Min Workout', goal: 1, progress: 0, xp: 200, unit: 'fraction'),
    Quest(title: 'Stretch for 10 Min', goal: 1, progress: 0, xp: 80, unit: 'fraction'),
  ];

  /// Returns true when this gain crossed a level.
  bool gainXp(int amount) {
    xp += amount;
    var up = false;
    while (xp >= xpGoal) {
      xp -= xpGoal;
      level++;
      up = true;
    }
    notifyListeners();
    return up;
  }

  void rep() {
    if (reps >= repGoal) return;
    reps++;
    combo++;
    burn += 2;
    calories += 2;
    notifyListeners();
  }

  void resetCombo() {
    if (combo == 0) return;
    combo = 0;
    notifyListeners();
  }

  void completeSet() {
    sets = sets >= setGoal ? setGoal : sets + 1;
    notifyListeners();
  }

  void advance(Quest q, int by) {
    q.progress = (q.progress + by).clamp(0, q.goal);
    notifyListeners();
  }

  static Player of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<PlayerScope>()!.notifier!;

  static Player read(BuildContext context) => context.getInheritedWidgetOfExactType<PlayerScope>()!.notifier!;
}

class PlayerScope extends InheritedNotifier<Player> {
  const PlayerScope({super.key, required Player player, required super.child}) : super(notifier: player);
}
