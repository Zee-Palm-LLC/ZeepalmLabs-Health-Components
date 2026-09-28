import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitzi/features/onboarding/onboarding_screen.dart';
import 'package:fitzi/features/shell/shell.dart';
import 'package:fitzi/features/workout/player.dart';
import 'package:fitzi/features/workout/workout_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  const sizes = [(360.0, 640.0, 24.0, 16.0), (360.0, 740.0, 24.0, 16.0), (393.0, 852.0, 59.0, 34.0), (412.0, 915.0, 32.0, 24.0), (430.0, 932.0, 59.0, 48.0)];
  final screens = <String, Widget Function()>{
    'onboarding': () => const OnboardingScreen(),
    'home': () => const Shell(initial: 0),
    'library': () => const Shell(initial: 1),
    'progress': () => const Shell(initial: 2),
    'profile': () => const Shell(initial: 3),
    'workout': () => const WorkoutScreen(),
    'player': () => const PlayerScreen(),
  };
  for (final s in sizes) {
    for (final e in screens.entries) {
      testWidgets('${e.key} ${s.$1.toInt()}x${s.$2.toInt()}', (tester) async {
        phone(tester, width: s.$1, height: s.$2, top: s.$3, bottom: s.$4);
        await mount(tester, e.value());
        await run(tester, 90);
        await shoot(tester, 'l_${e.key}_${s.$1.toInt()}x${s.$2.toInt()}', ratio: 1);
        done(tester);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
