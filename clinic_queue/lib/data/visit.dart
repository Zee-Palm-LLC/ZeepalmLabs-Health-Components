import 'package:flutter/foundation.dart';

class QueueSim extends ChangeNotifier {
  static const you = 27;
  static const start = 23;

  int serving = start;
  int delay = 0;

  int get rank => you - serving;
  int get wait => 6 + (rank - 1) * 4;
  double get fill => (1 - rank * 0.104).clamp(0.05, 0.97);
  bool get next => rank <= 1;
  bool get almost => rank <= 2;

  String get turnTime {
    final total = 10 * 60 + 42 + delay;
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }

  void advance() {
    if (next) return;
    serving++;
    notifyListeners();
  }

  void moveBack(int places) {
    serving -= places;
    delay += places * 4;
    notifyListeners();
  }

  void reset() {
    serving = start;
    delay = 0;
    notifyListeners();
  }
}

class Visit extends ChangeNotifier {
  final sim = QueueSim();

  bool hasToken = false;
  bool enRoute = false;
  String department = 'General';

  void choose(String value) {
    if (department == value) return;
    department = value;
    notifyListeners();
  }

  void take() {
    hasToken = true;
    enRoute = false;
    sim.reset();
    notifyListeners();
  }

  void leave() {
    enRoute = true;
    notifyListeners();
  }

  void finish() {
    hasToken = false;
    enRoute = false;
    sim.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    sim.dispose();
    super.dispose();
  }
}

String ordinal(int n) => '$n${suffix(n)}';

String suffix(int n) {
  return switch (n) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}
