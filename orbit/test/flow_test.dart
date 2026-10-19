import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/app.dart';
import 'package:orbit/game/run_page.dart';
import 'package:orbit/screens/world_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  const sizes = [(360.0, 640.0, 24.0, 0.0), (360.0, 740.0, 24.0, 16.0), (393.0, 852.0, 59.0, 34.0), (402.0, 874.0, 62.0, 34.0), (430.0, 932.0, 59.0, 34.0)];
  for (final (w, h, top, bottom) in sizes) {
    testWidgets('full flow at ${w.toInt()}x${h.toInt()}', (tester) async {
      phone(tester, width: w, height: h, top: top, bottom: bottom);
      await tester.pumpWidget(const OrbitApp());
      await run(tester, 80);
      await tester.tap(find.text('Start my planet'));
      await run(tester, 70);
      expect(find.byType(WorldScreen), findsOneWidget);

      final world = tester.state<WorldScreenState>(find.byType(WorldScreen));
      world.tap(Hub.sprout);
      world.tap(Hub.moon);
      await run(tester, 40);
      await tester.dragFrom(tester.getCenter(find.byType(WorldScreen)) + const Offset(0, 40), const Offset(120, 10));
      await run(tester, 90);

      world.tap(Hub.heart);
      await run(tester, 40);
      expect(find.byType(RunPage), findsOneWidget);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
      await run(tester, 120);
      Navigator.of(tester.element(find.byType(RunPage))).pop();
      await run(tester, 30);

      world.tap(Hub.star);
      await run(tester, 80);
      await tester.tap(find.text('Challenge a friend'));
      await run(tester, 90);
      Navigator.of(tester.element(find.text('Challenge a friend'))).pop();
      await run(tester, 30);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await run(tester, 5);
      done(tester);
    });
  }
}
