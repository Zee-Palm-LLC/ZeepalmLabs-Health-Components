import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Phase {
  const Phase({
    required this.name,
    required this.firstDay,
    required this.days,
    required this.colour,
    required this.tail,
    required this.note,
  });

  final String name;
  final int firstDay;
  final int days;
  final Color colour;
  final Color tail;
  final String note;

  int get lastDay => firstDay + days - 1;

  double get startAngle => -math.pi / 2 + (firstDay - 1) / 28 * math.pi * 2;

  double get sweep => days / 28 * math.pi * 2;
}

const phaseTable = [
  Phase(
    name: 'Menstrual',
    firstDay: 1,
    days: 5,
    colour: Color(0xFFF4685A),
    tail: Color(0xFFF7836F),
    note: 'Rest and refill. Gentle movement helps cramps settle.',
  ),
  Phase(
    name: 'Follicular',
    firstDay: 6,
    days: 7,
    colour: Color(0xFF6FA88F),
    tail: Color(0xFF7FB79C),
    note: 'Energy is climbing. A good week to start something new.',
  ),
  Phase(
    name: 'Ovulation',
    firstDay: 13,
    days: 5,
    colour: Color(0xFFEE9C33),
    tail: Color(0xFFF3AE45),
    note: 'Ovulation is your natural high point. You may feel more social and confident.',
  ),
  Phase(
    name: 'Luteal',
    firstDay: 18,
    days: 11,
    colour: Color(0xFF9056B4),
    tail: Color(0xFFCB8FA6),
    note: 'Wind down. Steady meals and sleep keep the dip away.',
  ),
];

enum Flow { none, light, medium, heavy }

const flowLabels = ['None', 'Light', 'Medium', 'Heavy'];

const symptoms = [
  'Cramps',
  'Headache',
  'Bloating',
  'Tender Breasts',
  'Fatigue',
  'Backache',
  'Cravings',
  'Acne',
  'Nausea',
];

class Cycle extends ChangeNotifier {
  int day = 14;
  final int length = 28;

  int flow = 2;
  int mood = 4;
  double energy = 0.72;
  final Set<String> picked = {'Cramps', 'Bloating', 'Cravings', 'Acne'};
  String notes = '';
  bool saved = false;

  List<Phase> get phases => phaseTable;

  Phase get phase => phaseOfDay(day);

  Phase phaseOfDay(int value) {
    final wrapped = ((value - 1) % length) + 1;
    return phaseTable.lastWhere((p) => wrapped >= p.firstDay, orElse: () => phaseTable.first);
  }

  double angleOfDay(double value) => -math.pi / 2 + (value - 1) / length * math.pi * 2;

  int get untilPeriod => length - day + 1;

  String get dateLabel => 'May ${day}, 2024';

  List<int> get weekDays => [for (var i = 6; i >= 0; i--) day - i];

  static const weekInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void select(int value) {
    final next = value.clamp(1, length);
    if (next == day) return;
    day = next;
    notifyListeners();
  }

  void setFlow(int value) {
    if (flow == value) return;
    flow = value;
    saved = false;
    notifyListeners();
  }

  void setMood(int value) {
    if (mood == value) return;
    mood = value;
    saved = false;
    notifyListeners();
  }

  void setEnergy(double value) {
    final next = value.clamp(0.0, 1.0);
    if ((next - energy).abs() < 0.001) return;
    energy = next;
    saved = false;
    notifyListeners();
  }

  void toggle(String symptom) {
    if (!picked.remove(symptom)) picked.add(symptom);
    saved = false;
    notifyListeners();
  }

  void setNotes(String value) {
    notes = value;
    saved = false;
    notifyListeners();
  }

  void save() {
    saved = true;
    notifyListeners();
  }

  int get loggedCount => picked.length;
}

class Insight {
  const Insight(this.label, this.spread);

  final String label;
  final List<double> spread;
}

const symptomPatterns = [
  Insight('Cramps', [0.52, 0.0, 0.22, 0.26]),
  Insight('Bloating', [0.0, 0.24, 0.3, 0.46]),
  Insight('Headache', [0.0, 0.24, 0.28, 0.48]),
  Insight('Fatigue', [0.0, 0.26, 0.3, 0.44]),
];

const cycleLengths = [27.0, 29.0, 31.0, 31.0, 30.0, 26.5, 28.5, 25.0];

const predictions = [
  ('May 15 – Jun 12', [0.18, 0.28, 0.18, 0.36]),
  ('Jun 13 – Jul 10', [0.18, 0.28, 0.18, 0.36]),
  ('Jul 11 – Aug 7', [0.18, 0.28, 0.18, 0.36]),
];

List<Color> get phaseColours => [for (final p in phaseTable) p.colour];
