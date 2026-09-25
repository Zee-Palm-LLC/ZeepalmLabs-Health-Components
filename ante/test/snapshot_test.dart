import 'package:flutter_test/flutter_test.dart';

import 'package:ante/core/motion.dart';
import 'package:ante/features/create/create_pool_screen.dart';
import 'package:ante/features/home/home_screen.dart';
import 'package:ante/features/onboarding/onboarding_screen.dart';
import 'package:ante/features/pool/pool_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  testWidgets('onboarding', (tester) async {
    phone(tester);
    Clock.frozen = true;
    await mount(tester, const OnboardingScreen());
    await run(tester, 12);
    await shoot(tester, 'onboard_early', ratio: 1);
    await run(tester, 20);
    await shoot(tester, 'onboard_mid', ratio: 1);
    await run(tester, 90);
    await shoot(tester, 'onboard');
    Clock.frozen = false;
    done(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home', (tester) async {
    phone(tester, height: 932.4, bottom: 9.9);
    Clock.frozen = true;
    await mount(tester, const HomeScreen());
    await run(tester, 14);
    await shoot(tester, 'home_mid', ratio: 1);
    await run(tester, 90);
    await shoot(tester, 'home');
    Clock.frozen = false;
    done(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('create', (tester) async {
    phone(tester, height: 932.9, bottom: 11.7);
    Clock.frozen = true;
    await mount(tester, const CreatePoolScreen());
    await run(tester, 14);
    await shoot(tester, 'create_mid', ratio: 1);
    await run(tester, 90);
    await shoot(tester, 'create');
    Clock.frozen = false;
    done(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pool', (tester) async {
    phone(tester, height: 922.4, bottom: 11.8);
    Clock.frozen = true;
    await mount(tester, const PoolScreen());
    await run(tester, 14);
    await shoot(tester, 'pool_mid', ratio: 1);
    await run(tester, 90);
    await shoot(tester, 'pool');
    Clock.frozen = false;
    done(tester);
    expect(tester.takeException(), isNull);
  });
}
