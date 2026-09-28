import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitzi/core/motion.dart';
import 'package:fitzi/features/home/home_screen.dart';
import 'package:fitzi/features/onboarding/onboarding_screen.dart';
import 'package:fitzi/features/shell/shell.dart';
import 'package:fitzi/features/workout/workout_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  final screens = <String, (double, Widget Function())>{
    'onboarding': (895.8, () => const OnboardingScreen()),
    'home': (891.4, () => const Shell(initial: 0)),
    'workout': (895.2, () => const WorkoutScreen()),
    'progress': (888.1, () => const Shell(initial: 2)),
  };
  for (final e in screens.entries) {
    testWidgets(e.key, (tester) async {
      phone(tester, height: e.value.$1, top: 54, bottom: 34);
      Clock.frozen = true;
      await mount(tester, e.value.$2());
      await run(tester, 10);
      await shoot(tester, '${e.key}_early', ratio: 1);
      await run(tester, 20);
      await shoot(tester, '${e.key}_mid', ratio: 1);
      await run(tester, 100);
      await shoot(tester, e.key, ratio: 3);
      Clock.frozen = false;
      done(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('home_only', (tester) async {
    phone(tester, height: 891.4, top: 54, bottom: 34);
    await mount(tester, const HomeScreen());
    await run(tester, 90);
    done(tester);
    expect(tester.takeException(), isNull);
  });
}
