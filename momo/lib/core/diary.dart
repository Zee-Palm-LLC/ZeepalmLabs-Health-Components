import 'package:flutter/widgets.dart';

import 'art.dart';

enum Course { breakfast, lunch, dinner, snack }

extension CourseName on Course {
  String get title => switch (this) {
    Course.breakfast => 'Breakfast',
    Course.lunch => 'Lunch',
    Course.dinner => 'Dinner',
    Course.snack => 'Snack',
  };

  String get art => switch (this) {
    Course.breakfast => Art.breakfast,
    Course.lunch => Art.lunch,
    Course.dinner => Art.dinner,
    Course.snack => Art.snack,
  };
}

class Meal {
  const Meal({required this.course, required this.name, required this.kcal, required this.art, required this.protein, this.photo = false});

  final Course course;
  final String name;
  final int kcal;
  final String art;
  final int protein;
  final bool photo;
}

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class Diary extends ChangeNotifier {
  Diary({DateTime? now}) : now = now ?? DateTime.now(), today = dayOnly(now ?? DateTime.now());

  final DateTime now;
  final DateTime today;
  static const guide = 2000;
  static const streak = 10;

  static const supper = Meal(course: Course.dinner, name: 'Spaghetti bolognese', kcal: 940, art: Art.spaghetti, protein: 38, photo: true);

  final List<Meal> _logged = [];

  DateTime get started => today.subtract(const Duration(days: streak));

  List<Meal> get todayMeals => [
    const Meal(course: Course.breakfast, name: 'Avocado toast', kcal: 480, art: Art.toast, protein: 16, photo: true),
    const Meal(course: Course.lunch, name: 'Buddha bowl', kcal: 640, art: Art.bowl, protein: 24, photo: true),
    ..._logged,
  ];

  bool get hasSupper => _logged.isNotEmpty;

  void log(Meal meal) {
    _logged
      ..clear()
      ..add(meal);
    notifyListeners();
  }

  void reset() {
    _logged.clear();
    notifyListeners();
  }

  int get proteinToday => todayMeals.fold(0, (sum, m) => sum + m.protein);

  bool isLogged(DateTime day) => !day.isBefore(started) && !day.isAfter(today);

  List<Meal> mealsOn(DateTime day) {
    final d = dayOnly(day);
    if (d == today) return todayMeals;
    if (!isLogged(d)) return const [];
    final seed = d.year * 372 + d.month * 31 + d.day;
    int pick(int salt, int lo, int hi) => lo + ((seed * 7919 + salt * 104729) % (hi - lo + 1));
    final morning = seed % 3 == 0 ? Art.croissant : Art.breakfast;
    final breakfast = (pick(1, 38, 52) * 10);
    final lunch = (pick(2, 56, 70) * 10);
    final dinner = (pick(3, 62, 78) * 10);
    return [
      Meal(course: Course.breakfast, name: 'Breakfast', kcal: breakfast, art: morning, protein: pick(4, 12, 22)),
      Meal(course: Course.lunch, name: 'Lunch', kcal: lunch, art: Art.lunch, protein: pick(5, 18, 30)),
      Meal(course: Course.dinner, name: 'Dinner', kcal: dinner, art: Art.dinner, protein: pick(6, 26, 40)),
    ];
  }

  int totalOn(DateTime day) => mealsOn(day).fold(0, (sum, m) => sum + m.kcal);

  String iconOn(DateTime day) {
    final meals = mealsOn(day);
    if (meals.isEmpty) return '';
    if (dayOnly(day) == today) return meals.last.art;
    final seed = day.day + day.month * 3;
    return meals[seed % meals.length].art;
  }
}

class DiaryScope extends InheritedNotifier<Diary> {
  const DiaryScope({super.key, required Diary diary, required super.child}) : super(notifier: diary);

  static Diary of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DiaryScope>()!.notifier!;

  static Diary read(BuildContext context) => context.getInheritedWidgetOfExactType<DiaryScope>()!.notifier!;
}
