import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_rpg/app.dart';

import 'support.dart';

/// Walks the whole app, including the tutorial chapters, and writes 3x renders
/// of every screen and key animation frames with `--dart-define=SNAP_DIR=<folder>`.
void main() {
  testWidgets('flow snapshots', (tester) async {
    await loadFonts();
    phone(tester);
    await tester.pumpWidget(const RepaintBoundary(key: ValueKey('shot'), child: StreakApp()));
    await warm(tester);
    await run(tester, 14);
    await shoot(tester, 'a1_slam', settle: false);
    await run(tester, 120);
    await shoot(tester, 's1');

    await tester.tap(find.text('Get Started'));
    await run(tester, 18);
    await shoot(tester, 'a2_portal', settle: false);
    await run(tester, 140);
    await shoot(tester, 's2');

    await tester.tap(find.text('Next'));
    await run(tester, 14);
    await shoot(tester, 'a3_warp', settle: false);
    await run(tester, 70);
    await shoot(tester, 's3');

    // Home tutorial: banner, then step through the spotlights.
    await run(tester, 26);
    await shoot(tester, 't1_banner', settle: false);
    await run(tester, 60);
    await shoot(tester, 't2_hero');
    Future<void> next() async {
      await run(tester, 90);
      await tester.tapAt(const Offset(201, 400));
      await run(tester, 10);
    }

    await next();
    await next();
    await shoot(tester, 't3_level');
    await next();
    await next();
    await next();
    await run(tester, 90);
    await shoot(tester, 't4_gift');
    await tester.tapAt(const Offset(200, 300));
    await run(tester, 8);
    await shoot(tester, 't5_nudge', settle: false);
    await run(tester, 20);
    await tester.tapAt(const Offset(356, 553));
    await run(tester, 90);
    await shoot(tester, 't6_nav');
    await next();
    await run(tester, 80);
    await shoot(tester, 't7_start');
    await tester.tapAt(const Offset(202, 640));
    await run(tester, 22);
    await shoot(tester, 't8_done', settle: false);
    await run(tester, 120);
    await shoot(tester, 't9_workout');
    await tester.tap(find.text('Skip tutorial'));
    await run(tester, 40);
    await shoot(tester, 's4');

    await tester.tap(find.text('Complete Set'));
    await run(tester, 26);
    await shoot(tester, 'a4_set', settle: false);
    await run(tester, 40);
    Navigator.of(tester.element(find.text('Workout'))).pop();
    await run(tester, 60);

    await tester.tap(find.text('Quests').last);
    await run(tester, 18);
    await shoot(tester, 'a6_dock', settle: false);
    await run(tester, 110);
    await shoot(tester, 't10_quests');
    await tester.tap(find.text('Skip tutorial'));
    await run(tester, 40);
    await shoot(tester, 's5');
    await tester.tap(find.text('Drink 2L Water'));
    await run(tester, 30);
    await shoot(tester, 'a5_quest', settle: false);
    await run(tester, 60);
    expect(tester.takeException(), isNull);
    done(tester);
  });
}
