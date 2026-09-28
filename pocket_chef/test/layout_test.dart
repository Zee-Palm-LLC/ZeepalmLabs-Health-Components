import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chef/core/motion.dart';
import 'package:pocket_chef/features/detail/detail_screen.dart';
import 'package:pocket_chef/features/shell/shell.dart';
import 'package:pocket_chef/features/splash/splash_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  const phones = [
    (360.0, 640.0, 24.0, 0.0),
    (360.0, 740.0, 28.0, 16.0),
    (393.0, 852.0, 59.0, 34.0),
    (412.0, 915.0, 32.0, 48.0),
    (430.0, 932.0, 59.0, 34.0),
  ];

  final screens = <String, Widget>{
    'splash': const SplashScreen(),
    'home': const Shell(),
    'recipes': const Shell(initial: 1),
    'favorites': const Shell(initial: 2),
    'profile': const Shell(initial: 3),
    'detail': const DetailScreen(),
  };

  for (final (w, h, top, bottom) in phones) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} fits ${w.toInt()}x${h.toInt()}', (tester) async {
        phone(tester, width: w, height: h, top: top, bottom: bottom);
        Clock.frozen = true;
        await mount(tester, entry.value);
        await run(tester, 90);
        await shoot(tester, 'fit_${entry.key}_${w.toInt()}x${h.toInt()}', ratio: 1);
        Clock.frozen = false;
        done(tester);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
