import 'package:flutter/foundation.dart';

import '../core/palette.dart';

class Entry {
  const Entry({
    required this.mood,
    required this.time,
    required this.title,
    required this.body,
    this.day = 17,
  });

  final int mood;
  final String time;
  final String title;
  final String body;
  final int day;

  Mood get tone => Mood.all[mood];
}

const _seed = [
  Entry(
    mood: 2,
    time: '9:36 AM',
    title: 'Three things I am grateful for today',
    body:
        '1. The quiet morning moments\n'
        'I really appreciated the time I took to sit with my coffee this morning, '
        'without rushing anywhere. It felt grounding to just be present.',
  ),
  Entry(
    mood: 1,
    time: '4:15 PM',
    title: "A thought I couldn't ignore",
    body:
        'I spent part of the day trying to understand why something small kept bothering me. '
        "It's rarely about the small thing itself, letting myself sit with it helped more than "
        'arguing with it.',
  ),
];

class JournalStore extends ChangeNotifier {
  final List<Entry> _entries = List.of(_seed);

  int selectedDay = 19;
  int? highlighted;

  List<Entry> get entries => List.unmodifiable(_entries);

  String get dayLabel {
    const names = {
      15: 'Sunday, March 15',
      16: 'Monday, March 16',
      17: 'Tuesday, March 17',
      18: 'Wednesday, March 18',
      19: 'Thursday, March 19',
      20: 'Friday, March 20',
      21: 'Saturday, March 21',
    };
    return names[selectedDay] ?? 'Tuesday, March 17';
  }

  String get summary {
    final n = _entries.length;
    if (n == 0) return 'nothing written yet';
    final moods = _entries.map((e) => e.mood).toSet();
    final tone = moods.length > 1 ? 'mixed mood' : Mood.all[moods.first].name.toLowerCase();
    return '$n ${n == 1 ? 'entry' : 'entries'} · $tone';
  }

  void selectDay(int day) {
    if (selectedDay == day) return;
    selectedDay = day;
    notifyListeners();
  }

  void add(Entry entry) {
    _entries.insert(0, entry);
    highlighted = 0;
    notifyListeners();
  }

  void clearHighlight() {
    if (highlighted == null) return;
    highlighted = null;
    notifyListeners();
  }
}

String clockLabel(DateTime at) {
  final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
  final m = at.minute.toString().padLeft(2, '0');
  return '$h:$m ${at.hour < 12 ? 'AM' : 'PM'}';
}

String dateLabel(DateTime at) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return 'Today, ${months[at.month - 1]} ${at.day}';
}
