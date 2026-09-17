enum PillShape { capsule, tablet }

class Medication {
  const Medication({
    required this.name,
    required this.strength,
    required this.category,
    required this.instruction,
    required this.timing,
    required this.supply,
    required this.dose,
    required this.frequency,
    required this.time,
    required this.count,
    this.shape = PillShape.capsule,
  });

  final String name;
  final String strength;
  final String category;
  final String instruction;
  final String timing;
  final String supply;
  final String dose;
  final String frequency;
  final String time;
  final String count;
  final PillShape shape;

  String get title => '$name - $strength';
}

abstract final class Cabinet {
  static const amlodipine = Medication(
    name: 'Amlodipine',
    strength: '5mg',
    category: 'Blood pressure',
    instruction: '1 tablet once a day',
    timing: 'Before Meals',
    supply: '30/month',
    dose: '1 tablet',
    frequency: 'Daily',
    time: '10:00AM',
    count: '1 Pill',
  );

  static const amoxicillin = Medication(
    name: 'Amoxicillin',
    strength: '500mg',
    category: 'Antibiotic',
    instruction: '1 tablet /8 hours',
    timing: 'Before Meals',
    supply: '6/month',
    dose: '1 tablet',
    frequency: 'Daily',
    time: '02:00PM',
    count: '1 Pill',
  );

  static const vitaminD = Medication(
    name: 'Vitamin D',
    strength: '1000IU',
    category: 'Supplement',
    instruction: '1 softgel /day',
    timing: 'With Dinner',
    supply: '30/month',
    dose: '1 softgel',
    frequency: 'Daily',
    time: '08:30PM',
    count: '1 Softgel',
    shape: PillShape.tablet,
  );

  static const metformin = Medication(
    name: 'Metformin',
    strength: '850mg',
    category: 'Diabetes',
    instruction: '1 tablet /12 hours',
    timing: 'After Meals',
    supply: '60/month',
    dose: '1 tablet',
    frequency: 'Twice',
    time: '08:00AM',
    count: '1 Pill',
    shape: PillShape.tablet,
  );

  static const atorvastatin = Medication(
    name: 'Atorvastatin',
    strength: '20mg',
    category: 'Cholesterol',
    instruction: '1 tablet at bedtime',
    timing: 'Before Bed',
    supply: '30/month',
    dose: '1 tablet',
    frequency: 'Nightly',
    time: '09:30PM',
    count: '1 Pill',
  );

  static const omeprazole = Medication(
    name: 'Omeprazole',
    strength: '20mg',
    category: 'Stomach',
    instruction: '1 capsule before breakfast',
    timing: 'Before Meals',
    supply: '30/month',
    dose: '1 capsule',
    frequency: 'Daily',
    time: '07:30AM',
    count: '1 Capsule',
  );

  static const lisinopril = Medication(
    name: 'Lisinopril',
    strength: '10mg',
    category: 'Heart',
    instruction: '1 tablet in the morning',
    timing: 'After Meals',
    supply: '30/month',
    dose: '1 tablet',
    frequency: 'Daily',
    time: '11:00AM',
    count: '1 Pill',
    shape: PillShape.tablet,
  );

  static const rotation = [amlodipine, metformin, amoxicillin, omeprazole, lisinopril, atorvastatin, vitaminD];

  static const schedule = [amoxicillin, vitaminD, metformin, atorvastatin];
}

class WeekPlan {
  WeekPlan(DateTime now)
    : today = DateTime(now.year, now.month, now.day),
      start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday % 7));

  final DateTime today;
  final DateTime start;

  int get todayIndex => today.difference(start).inDays;

  DateTime day(int index) => start.add(Duration(days: index));

  Medication doseFor(int index) {
    final offset = (index - todayIndex) % Cabinet.rotation.length;
    return Cabinet.rotation[offset];
  }

  static const letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
}

String greetingFor(DateTime time) {
  if (time.hour < 12) return 'Good morning';
  if (time.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
