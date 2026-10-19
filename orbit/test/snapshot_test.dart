import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/app.dart';
import 'package:orbit/core/motion.dart';
import 'package:orbit/screens/race_screen.dart';
import 'package:orbit/screens/splash_screen.dart';
import 'package:orbit/screens/world_screen.dart';

import 'support.dart';

Future<void> screen(
  WidgetTester tester,
  String name,
  Widget home, {
  int frames = 90,
}) async {
  phone(tester);
  Clock.frozen = true;
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('shot'),
      child: OrbitApp(home: home),
    ),
  );
  await warm(tester);
  await run(tester, frames);
  await shoot(tester, name);
}

void main() {
  setUpAll(loadFonts);

  testWidgets('splash', (tester) async {
    await screen(tester, 'splash', SplashScreen(onStart: () {}));
    done(tester);
  });

  testWidgets('world', (tester) async {
    await screen(tester, 'world', WorldScreen(onOpen: (_) {}));
    final g = await tester.startGesture(const Offset(209, 486));
    for (var i = 0; i < 8; i++) {
      await g.moveBy(const Offset(14, 3));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await shoot(tester, 'world_spin', settle: false);
    await g.up();
    await run(tester, 120);
    await shoot(tester, 'world_rest', settle: false);
    done(tester);
  });

  testWidgets('race', (tester) async {
    await screen(tester, 'race', RaceScreen(onBack: () {}), frames: 100);
    done(tester);
  });
}
