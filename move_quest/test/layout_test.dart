import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:move_quest/app.dart';
import 'package:move_quest/core/motion.dart';
import 'package:move_quest/features/home_screen.dart';
import 'package:move_quest/features/onboarding_screen.dart';
import 'package:move_quest/features/route_screen.dart';
import 'package:move_quest/features/splash_screen.dart';

import 'fonts.dart';

void main() {
  setUpAll(loadCabin);

  const phones = [
    (Size(360, 640), 24.0, 0.0),
    (Size(360, 740), 24.0, 48.0),
    (Size(393, 852), 59.0, 34.0),
    (Size(412, 915), 32.0, 24.0),
    (Size(430, 932), 59.0, 34.0),
  ];

  final screens = <String, Widget>{
    'splash': const SplashScreen(),
    'onboarding': const OnboardingScreen(),
    'home': const HomeScreen(),
    'route': const RouteScreen(),
  };

  for (final (size, top, bottom) in phones) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
        tester.view.viewPadding = FakeViewPadding(top: top, bottom: bottom);
        addTearDown(tester.view.reset);
        Clock.frozen = true;
        await tester.pumpWidget(MoveQuestApp(home: entry.value));
        for (var i = 0; i < 120; i++) {
          await tester.pump(const Duration(milliseconds: 34));
        }
        expect(tester.takeException(), isNull);
        Clock.frozen = false;
      });
    }
  }
}
