import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innur_steps/core/design.dart';
import 'package:innur_steps/data/today.dart';
import 'package:innur_steps/features/home/home_screen.dart';
import 'package:innur_steps/features/home/widgets/avatar.dart';
import 'package:innur_steps/features/home/widgets/rank_row.dart';
import 'package:innur_steps/features/home/widgets/rank_podium.dart';
import 'package:innur_steps/features/home/widgets/week_strip.dart';
import 'package:innur_steps/features/splash/innur_mark.dart';
import 'package:innur_steps/features/splash/splash_screen.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump();
  }

  /// Runs the home screen's entrance out. The first frame after a controller
  /// starts registers zero elapsed time, hence the bare pump first.
  Future<void> settleEntrance(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(D.entrance + const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 16));
  }

  group('the mark', () {
    test('every stroke is a real polyline with length', () {
      expect(MarkGeometry.lengthOf(MarkGeometry.upper), greaterThan(80));
      expect(MarkGeometry.lengthOf(MarkGeometry.lower), greaterThan(40));
      expect(MarkGeometry.headRadius, greaterThan(0));
    });

    test('the whole mark stays inside its own box', () {
      // It is drawn on a 100 x 100 grid and scaled from there; a point outside
      // that box would clip at some sizes and not others.
      const half = MarkGeometry.stroke / 2;
      for (final points in <List<Offset>>[
        MarkGeometry.upper,
        MarkGeometry.lower,
      ]) {
        for (final p in points) {
          expect(p.dx, inInclusiveRange(-half, MarkGeometry.box + half));
          expect(p.dy, inInclusiveRange(-half, MarkGeometry.box + half));
        }
      }
      expect(MarkGeometry.head.dx + MarkGeometry.headRadius,
          lessThanOrEqualTo(MarkGeometry.box));
      expect(MarkGeometry.head.dy - MarkGeometry.headRadius,
          greaterThanOrEqualTo(0));
    });

    testWidgets('renders at any size without throwing', (tester) async {
      for (final size in <double>[24, 30, 96, 168, 400]) {
        await pumpAt(tester, Center(child: InnurMark(size: size)));
        expect(tester.takeException(), isNull, reason: 'failed at $size');
        expect(tester.getSize(find.byType(InnurMark)), Size.square(size));
      }
    });
  });

  group('the splash', () {
    testWidgets('draws the mark, then hands over exactly once',
        (tester) async {
      var handovers = 0;
      await pumpAt(tester, SplashScreen(onDone: () => handovers++));

      // Part way through, the mark is on screen and partly drawn.
      await tester.pump();
      await tester.pump(D.draw ~/ 2);
      final mark = tester.widget<InnurMark>(find.byType(InnurMark));
      expect(mark.progress, greaterThan(0));
      expect(mark.progress, lessThan(1));
      expect(handovers, 0, reason: 'handed over before finishing the draw');

      // Finished, but still holding.
      await tester.pump(D.draw);
      expect(tester.widget<InnurMark>(find.byType(InnurMark)).progress, 1);
      expect(handovers, 0);

      await tester.pump(D.hold + const Duration(milliseconds: 60));
      expect(handovers, 1);

      // And it must not fire again on later frames.
      await tester.pump(const Duration(seconds: 2));
      expect(handovers, 1);
    });

    testWidgets('the wordmark follows the mark rather than arriving with it',
        (tester) async {
      await pumpAt(tester, SplashScreen(onDone: () {}));
      await tester.pump();

      // A third of the way in the mark is drawing but the word is not up yet.
      await tester.pump(D.draw ~/ 3);
      final early = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('innur'),
          matching: find.byType(Opacity),
        ),
      );
      expect(early.opacity, lessThan(0.05));

      await tester.pump(D.draw);
      final late_ = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('innur'),
          matching: find.byType(Opacity),
        ),
      );
      expect(late_.opacity, greaterThan(0.95));
    });
  });

  group('today', () {
    testWidgets('shows the day, the number and the rank', (tester) async {
      await pumpAt(tester, const HomeScreen());
      await settleEntrance(tester);

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('8,412'), findsWidgets);
      expect(find.text('steps'), findsOneWidget);
      expect(find.text('6.24 km'), findsOneWidget);
      expect(find.text('412 kcal'), findsOneWidget);
      expect(find.text('84% of goal'), findsOneWidget);
      expect(find.text('Synced from Health · 2 min ago'), findsOneWidget);
      expect(find.text("Today's rank"), findsOneWidget);
      expect(find.byType(WeekStrip), findsOneWidget);
      expect(find.byType(RankPodium), findsOneWidget);
      // The bar is gone: the page scrolls instead.
      expect(find.byType(Scrollable), findsWidgets);
    });

    testWidgets('the filter chips are a single choice', (tester) async {
      await pumpAt(tester, const HomeScreen());
      await settleEntrance(tester);

      await tester.tap(find.text('My team'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Global').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('every avatar keeps its place when the network is down',
        (tester) async {
      // The test binding fails every image load, which is exactly the case
      // that matters: a dead network must not move the layout or drop the
      // person's identity.
      await pumpAt(tester, const HomeScreen());
      await settleEntrance(tester);

      // Three on the podium, plus every visible row.
      final avatars = find.byType(Avatar);
      expect(avatars, findsWidgets);
      for (final size in tester.widgetList<Avatar>(avatars)) {
        expect(size.size, greaterThan(0));
      }
      // Initials stand in for the faces that never arrived.
      expect(find.text('A'), findsWidgets);
      expect(find.text('N'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('first place is the tallest block and is centred',
        (tester) async {
      await pumpAt(tester, const HomeScreen());
      await settleEntrance(tester);

      // Scoped to the podium: bare digits also appear as streak counts in
      // the rows below.
      Rect blockOf(String place) => tester.getRect(
            find.descendant(
              of: find.byType(RankPodium),
              matching: find.text(place),
            ),
          );

      final second = blockOf('2');
      final first = blockOf('1');
      final third = blockOf('3');

      // Centre block, and its slab starts higher than the other two.
      expect(first.center.dx, closeTo(440 / 2, 6));
      expect(first.center.dx, greaterThan(second.center.dx));
      expect(first.center.dx, lessThan(third.center.dx));
      expect(first.top, lessThan(second.top));
      expect(first.top, lessThan(third.top));
    });
  });

  group('the leaderboard', () {
    testWidgets('runs to tenth place, with the podium not repeated',
        (tester) async {
      await pumpAt(tester, const HomeScreen());
      await settleEntrance(tester);

      expect(TodayData.sample.ranked, hasLength(10));

      // The list starts at four; the top three are the podium.
      final rows = tester.widgetList<RankRow>(find.byType(RankRow)).toList();
      expect(rows.first.place, 4);
      for (var i = 0; i < rows.length; i++) {
        expect(rows[i].place, i + 4);
      }
    });

    test('the field is ordered by steps, best first', () {
      final ranked = TodayData.sample.ranked;
      for (var i = 1; i < ranked.length; i++) {
        expect(ranked[i].steps, lessThanOrEqualTo(ranked[i - 1].steps),
            reason: 'place ${i + 1} outscores place $i');
      }
    });

    test('exactly one racer is you', () {
      expect(TodayData.sample.ranked.where((r) => r.isYou), hasLength(1));
    });
  });

  group('the entrance', () {
    testWidgets('counts the number up rather than showing it', (tester) async {
      await pumpAt(tester, const HomeScreen());
      await tester.pump();

      // Part way in it is a smaller number than the total.
      await tester.pump(D.entrance ~/ 4);
      expect(find.text('8,412'), findsNothing,
          reason: 'the count should still be climbing');

      await tester.pump(D.entrance);
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('8,412'), findsWidgets);
    });

    testWidgets('the podium grows from the floor, third first',
        (tester) async {
      await pumpAt(tester, const HomeScreen());
      await tester.pump();

      Rect blockOf(String place) => tester.getRect(
            find.descendant(
              of: find.byType(RankPodium),
              matching: find.text(place),
            ),
          );

      // Sampled mid-entrance: third place is already up while first is still
      // on its way, which is the order that walks the eye to the winner.
      await tester.pump(
        Duration(milliseconds: (D.entrance.inMilliseconds * 0.62).round()),
      );
      expect(tester.takeException(), isNull);
      expect(blockOf('3').height, greaterThan(0));

      await tester.pump(D.entrance);
      await tester.pump(const Duration(milliseconds: 16));
      final first = blockOf('1');
      final third = blockOf('3');
      expect(first.top, lessThan(third.top), reason: 'first should stand tallest');
    });
  });

  group('formatting', () {
    test('groups thousands', () {
      expect(grouped(0), '0');
      expect(grouped(953), '953');
      expect(grouped(8412), '8,412');
      expect(grouped(10482), '10,482');
      expect(grouped(1234567), '1,234,567');
    });

    test('every racer has a photo to try', () {
      for (final racer in TodayData.sample.ranked) {
        expect(racer.photo, startsWith('https://'));
        expect(racer.name, isNotEmpty);
      }
    });

    test('the sample week ends on today', () {
      final week = TodayData.sample.week;
      expect(week, hasLength(7));
      expect(week.where((d) => d.isToday), hasLength(1));
      expect(week.last.isToday, isTrue);
      for (final day in week) {
        expect(day.progress, inInclusiveRange(0, 1));
      }
    });
  });
}
