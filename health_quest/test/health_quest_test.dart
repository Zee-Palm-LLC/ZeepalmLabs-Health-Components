import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_quest/core/design.dart';
import 'package:health_quest/data/quests.dart';
import 'package:health_quest/data/stats.dart';
import 'package:health_quest/features/home/home_screen.dart';
import 'package:health_quest/features/onboarding/onboarding_screen.dart';
import 'package:health_quest/features/onboarding/widgets/hero_stage.dart';
import 'package:health_quest/features/onboarding/widgets/stat_badge.dart';
import 'package:health_quest/features/quest/quest_screen.dart';
import 'package:health_quest/features/rewards/rewards_screen.dart';
import 'package:health_quest/features/shell/app_shell.dart';
import 'package:health_quest/widgets/nav_bar.dart';
import 'package:health_quest/widgets/painters/polygon.dart';

/// A phone-shaped surface. The layout was measured against 393 x 852, and the
/// default 800 x 600 test window is both wider and far shorter.
void phone(WidgetTester tester, {Size size = const Size(393, 852)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Wraps a screen in just enough app for it to build.
Widget host(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: Scaffold(backgroundColor: const Color(0xFF05060C), body: child),
    );

/// Runs an entrance out.
///
/// Never `pumpAndSettle`: every screen keeps a free-running Ticker for the
/// breathing, the glows and the sheen, so "settled" never arrives.
Future<void> settle(WidgetTester tester,
    [Duration d = const Duration(milliseconds: 2700)]) async {
  await tester.pump();
  await tester.pump(d);
  await tester.pump(const Duration(milliseconds: 16));
}

void main() {
  group('data', () {
    test('four stats, each with its own tone and a level label', () {
      expect(Stat.all.length, 4);
      expect(
        Stat.all.map((Stat s) => s.label).toList(),
        <String>['PHYSICAL', 'MENTAL', 'ENERGY', 'HYDRATION'],
      );
      expect(Stat.all.map((Stat s) => s.tone.core).toSet().length, 4);
      for (final s in Stat.all) {
        expect(s.levelLabel, 'Lv. 01');
        expect(s.blurb, isNotEmpty);
      }
    });

    test('three quests, one of them finished', () {
      expect(Quest.today.length, 3);
      expect(Quest.completed, 1);
      expect(Quest.today.last.done, isTrue);
      for (final q in Quest.today) {
        expect(q.progress, inInclusiveRange(0, 1));
        expect(q.milestones.length, 4);
      }
    });

    test('grouped() puts separators in the right places', () {
      expect(grouped(0), '0');
      expect(grouped(842), '842');
      expect(grouped(3842), '3,842');
      expect(grouped(2840), '2,840');
      expect(grouped(1234567), '1,234,567');
    });

    test('the player is partway through the level', () {
      expect(Player.you.xpFraction, closeTo(0.71, 0.01));
    });
  });

  group('polygon', () {
    test('a hexagon fills the box it is given', () {
      const size = Size(52, 60);
      final b = polygonPath(size, sides: 6, cornerRadius: 6).getBounds();
      // Rounded corners pull the bounds in a little, never out.
      expect(b.width, lessThanOrEqualTo(size.width + 0.01));
      expect(b.height, lessThanOrEqualTo(size.height + 0.01));
      expect(b.width, greaterThan(size.width * 0.93));
      expect(b.height, greaterThan(size.height * 0.93));
    });

    test('so does an octagon, with the same call', () {
      const size = Size(46, 64);
      final b = polygonPath(size, sides: 8, cornerRadius: 4).getBounds();
      expect(b.width, greaterThan(size.width * 0.93));
      expect(b.height, greaterThan(size.height * 0.93));
    });
  });

  group('onboarding', () {
    testWidgets('renders every line of the reference', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const OnboardingScreen(playIntro: false)));
      await settle(t);

      expect(find.text('LEVEL UP'), findsOneWidget);
      expect(find.text('YOUR HEALTH'), findsOneWidget);
      expect(find.textContaining('Every healthy choice'), findsOneWidget);
      for (final s in Stat.all) {
        expect(find.text(s.label), findsOneWidget);
      }
      expect(find.text('Lv. 01'), findsNWidgets(4));
      expect(find.text('LVL'), findsOneWidget);
      expect(find.text('0 / 100 XP'), findsOneWidget);
      expect(find.text('START JOURNEY'), findsOneWidget);
      expect(
        find.text('Your adventure to a better you starts now!'),
        findsOneWidget,
      );
      expect(find.byType(HeroStage), findsOneWidget);
      expect(find.byType(StatBadge), findsNWidgets(4));
      expect(t.takeException(), isNull);
    });

    testWidgets('the entrance runs top to bottom', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const OnboardingScreen(playIntro: false)));
      await t.pump();
      await t.pump(D.entrance * 0.36);

      double opacityAbove(Finder f) => t
          .widgetList<Opacity>(
              find.ancestor(of: f, matching: find.byType(Opacity)))
          .first
          .opacity;

      expect(opacityAbove(find.text('LEVEL UP')), greaterThan(0.9));
      expect(opacityAbove(find.text('START JOURNEY')), 0);

      await settle(t);
      expect(opacityAbove(find.text('START JOURNEY')), 1);
      expect(t.takeException(), isNull);
    });

    testWidgets('tapping a stat shows its blurb, then hands the line back',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const OnboardingScreen(playIntro: false)));
      await settle(t);

      await t.tap(find.text('PHYSICAL'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text(Stat.all.first.blurb), findsOneWidget);

      await t.pump(const Duration(milliseconds: 2200));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text(Stat.all.first.blurb), findsNothing);
      expect(find.textContaining('Every healthy choice'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('the call to action charges and opens the app',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
          home: const OnboardingScreen(playIntro: false),
        ),
      );
      await settle(t);
      expect(find.text('0 / 100 XP'), findsOneWidget);

      await t.tap(find.text('START JOURNEY'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('0 / 100 XP'), findsNothing);

      await t.pump(const Duration(milliseconds: 620));
      expect(find.text('100 / 100 XP'), findsOneWidget);

      // Blink, then the dashboard.
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 250));
      await t.pump(const Duration(milliseconds: 700));
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text("TODAY'S QUESTS"), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('dragging tilts the diorama without moving the interface',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const OnboardingScreen(playIntro: false)));
      await settle(t);

      final before = t.getTopLeft(find.byType(StatBadge).first);
      await t.drag(find.byType(HeroStage), const Offset(-90, 40));
      await t.pump(const Duration(milliseconds: 16));
      expect(t.getTopLeft(find.byType(StatBadge).first), before);

      await t.pump(const Duration(milliseconds: 900));
      expect(t.takeException(), isNull);
    });
  });

  group('dashboard', () {
    testWidgets('shows the player, the score and the three quests',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell()));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('GOOD MORNING,'), findsOneWidget);
      expect(find.text('PLAYER!'), findsOneWidget);
      expect(
        find.textContaining('LEVEL 12'),
        findsOneWidget,
      );
      expect(find.text('DAILY HEALTH SCORE'), findsOneWidget);
      expect(find.text('87'), findsOneWidget);
      expect(find.text('/100'), findsOneWidget);
      expect(find.text('7 DAYS'), findsOneWidget);
      expect(find.text('X2'), findsOneWidget);
      expect(find.text('2,840 / 4,000 XP'), findsOneWidget);
      expect(find.text("TODAY'S QUESTS"), findsOneWidget);
      expect(find.text('1/3 Completed'), findsOneWidget);
      for (final q in Quest.today) {
        expect(find.text(q.title), findsOneWidget);
        expect(find.text('+${q.xp} XP'), findsOneWidget);
      }
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('76%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('the numbers dial up rather than appearing',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell()));
      await t.pump();
      await t.pump(D.pageEntrance * 0.30);
      // Partway in, the score is on its way and not yet at its value.
      expect(find.text('87'), findsNothing);
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.text('87'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a quest opens its detail screen', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell()));
      await settle(t, const Duration(milliseconds: 1400));

      await t.tap(find.text('Walk 5,000 Steps'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.byType(QuestScreen), findsOneWidget);
      expect(find.text('QUEST DETAILS'), findsOneWidget);
      expect(find.text('WALK 5,000 STEPS'), findsOneWidget);
      expect(find.text('Keep moving, Warrior!'), findsOneWidget);
      expect(find.text('3,842'), findsOneWidget);
      expect(find.text('/ 5,000'), findsOneWidget);
      expect(find.text('STEPS'), findsOneWidget);
      expect(find.text('76% COMPLETED'), findsOneWidget);
      expect(find.text('+75 XP'), findsOneWidget);
      expect(find.text('Step Master'), findsOneWidget);
      expect(find.text('MILESTONES'), findsOneWidget);
      expect(find.text('KEEP GOING'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('KEEP GOING returns to the dashboard',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell()));
      await settle(t, const Duration(milliseconds: 1400));
      await t.tap(find.text('Drink 2L Water'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(QuestScreen), findsOneWidget);

      await t.tap(find.text('KEEP GOING'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(QuestScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('tabs', () {
    testWidgets('the bar switches between the four', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell()));
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(HomeScreen), findsOneWidget);

      await t.tap(find.text('REWARDS'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(RewardsScreen), findsOneWidget);
      expect(find.text('REWARDS VAULT'), findsOneWidget);

      await t.tap(find.text('STATS'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(LockedTab), findsOneWidget);
      expect(find.text('UNLOCKS AT LEVEL 15'), findsOneWidget);

      await t.tap(find.text('QUESTS'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('rewards vault', () {
    testWidgets('claiming an affordable badge spends XP and marks it',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell(initialTab: NavTab.rewards)));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('2 of 6 badges claimed'), findsOneWidget);
      expect(find.text('CLAIMED'), findsNWidgets(2));
      expect(find.text('2,840 XP'), findsOneWidget);

      // Still Mind costs 1,200, which the balance covers.
      await t.tap(find.text('Still Mind'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 800));

      expect(find.text('CLAIMED'), findsNWidgets(3));
      expect(find.text('3 of 6 badges claimed'), findsOneWidget);
      expect(find.text('1,640 XP'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a level-gated badge cannot be claimed',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell(initialTab: NavTab.rewards)));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('LEVEL 15'), findsOneWidget);
      await t.tap(find.text('Iron Streak'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));

      expect(find.text('LEVEL 15'), findsOneWidget);
      expect(find.text('2 of 6 badges claimed'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('robustness', () {
    testWidgets('every screen lays out on a small phone and a large one',
        (WidgetTester t) async {
      for (final size in <Size>[const Size(360, 720), const Size(430, 932)]) {
        phone(t, size: size);
        await t.pumpWidget(host(const OnboardingScreen(playIntro: false)));
        await settle(t);
        expect(find.text('START JOURNEY'), findsOneWidget, reason: '$size');
        expect(t.takeException(), isNull, reason: 'onboarding $size');

        await t.pumpWidget(host(const AppShell()));
        await settle(t, const Duration(milliseconds: 1400));
        expect(find.text("TODAY'S QUESTS"), findsOneWidget, reason: '$size');
        expect(t.takeException(), isNull, reason: 'dashboard $size');
      }
    });

    testWidgets('tears down mid-animation without leaking a timer',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const OnboardingScreen(playIntro: false)));
      await settle(t);
      await t.tap(find.text('MENTAL'));
      await t.pump();
      // Replace the tree while the blurb timer is still pending.
      await t.pumpWidget(const SizedBox.shrink());
      await t.pump(const Duration(seconds: 3));
      expect(t.takeException(), isNull);
    });
  });
}
