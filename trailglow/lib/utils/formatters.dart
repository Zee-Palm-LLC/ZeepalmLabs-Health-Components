String two(int value) => value.toString().padLeft(2, '0');

String formatDuration(int seconds) {
  final total = seconds.abs();
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final secs = total % 60;
  if (hours > 0) return '$hours:${two(minutes)}:${two(secs)}';
  return '${two(minutes)}:${two(secs)}';
}

String formatClock(int seconds) {
  final total = seconds.abs();
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final secs = total % 60;
  if (hours > 0) return '$hours:${two(minutes)}:${two(secs)}';
  return '${two(minutes)}:${two(secs)}';
}

String formatPace(num secondsPerKm) {
  if (secondsPerKm.isNaN || secondsPerKm.isInfinite || secondsPerKm <= 0) {
    return '--:--';
  }
  final value = secondsPerKm.round();
  return '${value ~/ 60}:${two(value % 60)}';
}

String formatDistance(double km, {int digits = 2}) =>
    km.toStringAsFixed(digits);

String formatThousands(num value) {
  final text = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}

String formatDate(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final day = days[(date.weekday - 1) % 7];
  return '$day, ${date.day} ${months[date.month - 1]}';
}

String formatTimeOfDay(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${two(date.minute)} $suffix';
}
