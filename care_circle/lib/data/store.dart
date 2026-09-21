import 'package:flutter/widgets.dart';

import '../core/glyphs.dart';
import '../core/theme.dart';

enum Mood { good, watch, nudge }

class Member {
  const Member({
    required this.id,
    required this.name,
    required this.title,
    required this.relation,
    required this.age,
    required this.halo,
    required this.mood,
    required this.angle,
  });

  final String id;
  final String name;
  final String title;
  final String relation;
  final int age;
  final Color halo;
  final Mood mood;
  final double angle;

  String get photo => 'assets/people/$id.webp';
  String get heroTag => 'avatar-$id';
}

enum Dose { taken, missed, upcoming }

class Slot {
  Slot(this.label, this.time, this.glyph, this.dose);

  final String label;
  final String time;
  final Glyph glyph;
  Dose dose;
}

class Moment {
  Moment({
    required this.time,
    required this.title,
    required this.glyph,
    required this.tone,
    required this.by,
    this.detail,
    this.thumb = false,
    this.liked = false,
  });

  final String time;
  final String title;
  final String? detail;
  final Glyph glyph;
  Color tone;
  final String by;
  final bool thumb;
  bool liked;
}

class CareStore extends ChangeNotifier {
  CareStore._();

  static final CareStore instance = CareStore._();

  static const members = [
    Member(
      id: 'joe',
      name: 'Grandpa Joe',
      title: 'Grandpa Joe',
      relation: "Dad's father",
      age: 78,
      halo: Hue.coral,
      mood: Mood.nudge,
      angle: -90,
    ),
    Member(
      id: 'mom',
      name: 'Mom',
      title: 'Emma',
      relation: 'Your mom',
      age: 52,
      halo: Hue.sage,
      mood: Mood.good,
      angle: -12,
    ),
    Member(
      id: 'leo',
      name: 'Leo',
      title: 'Leo',
      relation: 'Your brother',
      age: 9,
      halo: Hue.honey,
      mood: Mood.watch,
      angle: 58,
    ),
    Member(
      id: 'dad',
      name: 'Dad',
      title: 'Ryan',
      relation: 'Your dad',
      age: 54,
      halo: Hue.sage,
      mood: Mood.good,
      angle: 122,
    ),
    Member(
      id: 'rose',
      name: 'Nana Rose',
      title: 'Nana Rose',
      relation: "Mom's mother",
      age: 75,
      halo: Hue.sage,
      mood: Mood.good,
      angle: 192,
    ),
  ];

  static Member byId(String id) => members.firstWhere((m) => m.id == id);

  final slots = [
    Slot('Morning', '9:00', Glyph.sun, Dose.missed),
    Slot('Afternoon', '2:00', Glyph.sunSoft, Dose.upcoming),
    Slot('Evening', '8:00', Glyph.moon, Dose.upcoming),
  ];

  late final moments = [
    Moment(time: '8:00 AM', title: 'Breakfast logged', glyph: Glyph.coffee, tone: Hue.sage, by: 'mom', liked: true),
    Moment(time: '9:00 AM', title: 'Metformin 500mg', detail: 'missed', glyph: Glyph.pill, tone: Hue.coral, by: 'mom', thumb: true),
    Moment(time: '11:30 AM', title: 'Morning walk 18 min', glyph: Glyph.walk, tone: Hue.sage, by: 'leo', liked: true),
    Moment(time: '2:00 PM', title: 'Call with Mom', glyph: Glyph.phone, tone: Hue.iris, by: 'mom', liked: true),
    Moment(time: 'Thu 10:00 AM', title: 'Cardiology · Dr. Patel', glyph: Glyph.calendar, tone: Hue.honey, by: 'patel', thumb: true),
  ];

  bool nudged = false;
  String assignee = 'dad';
  bool reminderSent = false;

  bool get morningTaken => slots.first.dose == Dose.taken;
  int get medsTaken => morningTaken ? 12 : 11;
  int get doingWell => morningTaken ? 5 : 4;

  void markTaken() {
    if (morningTaken) return;
    slots.first.dose = Dose.taken;
    moments[1].tone = Hue.sage;
    notifyListeners();
  }

  void nudge() {
    nudged = true;
    notifyListeners();
  }

  void assign(String id) {
    assignee = id;
    reminderSent = false;
    notifyListeners();
  }

  void sendReminder() {
    reminderSent = true;
    notifyListeners();
  }

  void toggleLike(Moment moment) {
    moment.liked = !moment.liked;
    notifyListeners();
  }

  void reset() {
    slots[0].dose = Dose.missed;
    slots[1].dose = Dose.upcoming;
    slots[2].dose = Dose.upcoming;
    moments[1].tone = Hue.coral;
    nudged = false;
    assignee = 'dad';
    reminderSent = false;
    notifyListeners();
  }
}
