import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ante/core/motion.dart';
import 'package:ante/features/create/create_pool_screen.dart';
import 'package:ante/features/home/home_screen.dart';
import 'package:ante/features/onboarding/onboarding_screen.dart';
import 'package:ante/features/pool/pool_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  final screens = <String, Widget Function()>{
    'd_onboarding': () => const OnboardingScreen(),
    'd_home': () => const HomeScreen(),
    'd_create': () => const CreatePoolScreen(),
    'd_pool': () => const PoolScreen(),
  };
  for (final entry in screens.entries) {
    testWidgets(entry.key, (tester) async {
      phone(tester, width: 393, height: 852, top: 59, bottom: 34);
      Clock.frozen = true;
      await mount(tester, entry.value());
      await run(tester, 100);
      await shoot(tester, entry.key, ratio: 1);
      Clock.frozen = false;
      done(tester);
    });
    testWidgets('${entry.key}_android', (tester) async {
      phone(tester, width: 412, height: 915, top: 32, bottom: 24);
      Clock.frozen = true;
      await mount(tester, entry.value());
      await run(tester, 100);
      await shoot(tester, '${entry.key}_android', ratio: 1);
      Clock.frozen = false;
      done(tester);
    });
  }
}
