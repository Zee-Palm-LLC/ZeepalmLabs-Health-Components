import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_rpg/app.dart';

import 'support.dart';

/// Runs the whole flow on short, mock-sized and tall phones and fails on any
/// exception. With SNAP_DIR set it also writes each screen per size.
void main() {
  const sizes = [(360.0, 640.0, 24.0, 0.0), (393.0, 852.0, 59.0, 34.0), (430.0, 932.0, 59.0, 34.0)];
  for (final (w, h, top, bottom) in sizes) {
    testWidgets('flow at ${w.toInt()}x${h.toInt()}', (tester) async {
      await loadFonts();
      phone(tester, width: w, height: h, top: top, bottom: bottom);
      await tester.pumpWidget(const RepaintBoundary(key: ValueKey('shot'), child: StreakApp()));
      await warm(tester);
      await run(tester, 120);
      final tag = '${w.toInt()}x${h.toInt()}';
      await shoot(tester, 'z_${tag}_s1', ratio: 2);
      await tester.tap(find.text('Get Started'));
      await run(tester, 140);
      await shoot(tester, 'z_${tag}_s2', ratio: 2);
      await tester.tap(find.text('Next'));
      await run(tester, 80);
      await shoot(tester, 'z_${tag}_s3', ratio: 2);
      await run(tester, 120);
      await shoot(tester, 'z_${tag}_tut', ratio: 2);
      await tester.tap(find.text('Skip tutorial'));
      await run(tester, 30);
      await tester.tap(find.text('Start Workout'));
      await run(tester, 170);
      await tester.tap(find.text('Skip tutorial'));
      await run(tester, 30);
      await shoot(tester, 'z_${tag}_s4', ratio: 2);
      Navigator.of(tester.element(find.text('Workout'))).pop();
      await run(tester, 60);
      await tester.tap(find.text('Quests').last);
      await run(tester, 150);
      await tester.tap(find.text('Skip tutorial'));
      await run(tester, 30);
      await shoot(tester, 'z_${tag}_s5', ratio: 2);
      await tester.tap(find.text('Friends'));
      await run(tester, 60);
      expect(tester.takeException(), isNull);
      done(tester);
    });
  }
}
