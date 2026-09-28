import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chef/core/motion.dart';
import 'package:pocket_chef/features/detail/detail_screen.dart';
import 'package:pocket_chef/features/shell/shell.dart';
import 'package:pocket_chef/features/splash/splash_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  testWidgets('splash', (tester) async {
    phone(tester, height: 903.8);
    Clock.frozen = true;
    await mount(tester, const SplashScreen());
    await run(tester, 14);
    await shoot(tester, 'splash_mid', ratio: 1);
    await run(tester, 100);
    await shoot(tester, 'splash');
    Clock.frozen = false;
    done(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home', (tester) async {
    phone(tester, height: 892.9);
    Clock.frozen = true;
    await mount(tester, const Shell());
    await run(tester, 18);
    await shoot(tester, 'home_mid', ratio: 1);
    await run(tester, 100);
    await shoot(tester, 'home');
    Clock.frozen = false;
    done(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail', (tester) async {
    phone(tester, height: 890.05);
    Clock.frozen = true;
    await mount(tester, const DetailScreen());
    await run(tester, 16);
    await shoot(tester, 'detail_mid', ratio: 1);
    await run(tester, 100);
    await shoot(tester, 'detail');
    Clock.frozen = false;
    done(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile', (tester) async {
    phone(tester, height: 900.2);
    Clock.frozen = true;
    await mount(tester, const Shell(initial: 3));
    await run(tester, 18);
    await shoot(tester, 'profile_mid', ratio: 1);
    await run(tester, 100);
    await shoot(tester, 'profile');
    Clock.frozen = false;
    done(tester);
    expect(tester.takeException(), isNull);
  });
}
