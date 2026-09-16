import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_quest/core/audio/sfx.dart';
import 'package:health_quest/core/design.dart';
import 'package:health_quest/core/settings.dart';
import 'package:health_quest/data/game_state.dart';
import 'package:health_quest/data/main_quest.dart';
import 'package:health_quest/data/progress.dart';
import 'package:health_quest/data/quests.dart';
import 'package:health_quest/data/social.dart';
import 'package:health_quest/data/stats.dart';
import 'package:health_quest/features/auth/forgot_password_screen.dart';
import 'package:health_quest/features/auth/login_screen.dart';
import 'package:health_quest/features/auth/main_quest_screen.dart';
import 'package:health_quest/features/auth/signup_screen.dart';
import 'package:health_quest/features/auth/widgets/auth_widgets.dart';
import 'package:health_quest/features/home/home_screen.dart';
import 'package:health_quest/features/leaderboard/leaderboard_screen.dart';
import 'package:health_quest/features/notifications/notifications_screen.dart';
import 'package:health_quest/features/onboarding/onboarding_screen.dart';
import 'package:health_quest/features/onboarding/widgets/hero_stage.dart';
import 'package:health_quest/features/onboarding/widgets/stat_badge.dart';
import 'package:health_quest/features/profile/profile_screen.dart';
import 'package:health_quest/features/quest/quest_screen.dart';
import 'package:health_quest/features/rewards/rewards_screen.dart';
import 'package:health_quest/features/settings/settings_screen.dart';
import 'package:health_quest/features/shell/app_shell.dart';
import 'package:health_quest/features/stats/stats_screen.dart';
import 'package:health_quest/widgets/nav_bar.dart';
import 'package:health_quest/widgets/hud_kit.dart';
import 'package:health_quest/widgets/painters/polygon.dart';
import 'package:shared_preferences/shared_preferences.dart';

void phone(WidgetTester tester, {Size size = const Size(393, 852)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget host(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: Scaffold(backgroundColor: const Color(0xFF05060C), body: child),
    );

Future<void> settle(WidgetTester tester,
    [Duration d = const Duration(milliseconds: 2700)]) async {
  await tester.pump();
  await tester.pump(d);
  await tester.pump(const Duration(milliseconds: 16));
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump(const Duration(milliseconds: 16));
}

Finder navTab(String label) =>
    find.descendant(of: find.byType(NavBar), matching: find.text(label));

void main() {
  late RecordingSfxEngine sounds;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    GameState.instance.reset();
    GameSettings.instance.reset();
    sounds = RecordingSfxEngine();
    GameAudio.engine = sounds;
  });

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

    test('game state starts from the seeded player', () {
      final g = GameState.instance;
      expect(g.level, 12);
      expect(g.xp, 2840);
      expect(g.balance, 2840);
      expect(g.badgesOwned, 2);
      expect(g.unreadCount, 3);
    });

    test('a finished quest pays once, with the multiplier', () {
      final g = GameState.instance;
      final meditation = Quest.today.last;
      expect(g.payout(meditation), 60);
      expect(g.claimQuest(meditation), 0);
      expect(g.xp, 2900);
      expect(g.claimQuest(meditation), isNull);
      expect(g.claimQuest(Quest.today.first), isNull, reason: 'not finished');
    });

    test('the vault refuses what the player cannot have', () {
      final g = GameState.instance;
      final byName = {for (final r in Reward.all) r.name: r};
      expect(g.claimReward(byName['Step Master']!), ClaimResult.alreadyOwned);
      expect(g.claimReward(byName['Iron Streak']!), ClaimResult.levelLocked);
      expect(g.claimReward(byName['Still Mind']!), ClaimResult.claimed);
      expect(g.claimReward(byName['Night Owl Cure']!), ClaimResult.tooExpensive);
      expect(g.balance, 1640);
    });

    test('stats, history and the leaderboard hang together', () {
      expect(StatStanding.all.length, 4);
      expect(StatStanding.power, 50);
      expect(XpHistory.week.values.length, 7);
      expect(XpHistory.month.values.length, 4);
      expect(XpHistory.week.labels(DateTime(2026, 9, 16)).last, 'TODAY');
      expect(XpHistory.week.labels(DateTime(2026, 9, 16)).first, 'THU');
      expect(Rival.rankIn(Rival.friends), 4);
      expect(activityGrid.length, 35);
    });
  });

  group('polygon', () {
    test('a hexagon fills the box it is given', () {
      const size = Size(52, 60);
      final b = polygonPath(size, sides: 6, cornerRadius: 6).getBounds();
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

    testWidgets('the call to action charges and opens sign-up',
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

      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 250));
      await t.pump(const Duration(milliseconds: 700));
      await settle(t, const Duration(milliseconds: 1600));
      expect(find.byType(SignupScreen), findsOneWidget);
      expect(find.text('CREATE YOUR'), findsOneWidget);
      expect(find.text('HERO'), findsOneWidget);
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

  group('auth', () {
    Widget app(Widget home) => MaterialApp(
          theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
          home: home,
        );

    test('password strength is rated from length, case, digits, symbols', () {
      expect(passwordScore(''), 0);
      expect(passwordScore('Ab1!'), 1);
      expect(passwordScore('abcdefgh'), 1);
      expect(passwordScore('Abcdefgh'), 2);
      expect(passwordScore('Abcdefg1'), 3);
      expect(passwordScore('Abcdef1!'), 4);
    });

    testWidgets('sign-up refuses an empty form and says why',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const SignupScreen()));
      await settle(t, const Duration(milliseconds: 1600));

      await reveal(t, find.text('CREATE HERO'));
      await t.tap(find.text('CREATE HERO'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));

      expect(sounds.played.last, Sfx.denied);
      await reveal(t, find.text('Your hero needs a name.'));
      expect(find.text('Your hero needs a name.'), findsOneWidget);
      expect(find.text('Enter your email.'), findsOneWidget);
      expect(find.text('Choose a password.'), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('sign-up, then the main quest, then the game',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const SignupScreen()));
      await settle(t, const Duration(milliseconds: 1600));

      final fields = find.byType(TextField);
      await t.enterText(fields.at(0), 'Nova Knight');
      await t.enterText(fields.at(1), 'nova@quest.app');
      await t.enterText(fields.at(2), 'Abcdef1!');
      await t.pump();
      expect(find.text('LEGENDARY'), findsOneWidget);

      await reveal(t, find.textContaining('I accept the'));
      await t.tap(find.byType(HudCheckbox));
      await t.pump(const Duration(milliseconds: 400));

      await reveal(t, find.text('CREATE HERO'));
      await t.tap(find.text('CREATE HERO'));
      await t.pump();
      expect(find.text('FORGING YOUR HERO'), findsOneWidget);
      await t.pump(const Duration(milliseconds: 800));
      await settle(t, const Duration(milliseconds: 1600));
      expect(find.byType(MainQuestScreen), findsOneWidget);
      expect(find.text('MAIN QUEST'), findsOneWidget);
      expect(GameState.instance.name, 'NOVA KNIGHT');

      await reveal(t, find.text('BEGIN ADVENTURE'));
      await t.tap(find.text('BEGIN ADVENTURE'));
      await t.pump(const Duration(milliseconds: 400));
      expect(sounds.played.last, Sfx.denied);
      expect(find.text('Pick a path to begin.'), findsOneWidget);

      await reveal(t, find.text('HYDRATE'));
      await t.tap(find.text('HYDRATE'));
      await t.pump(const Duration(milliseconds: 400));
      await reveal(t, find.text('LEGEND'));
      await t.tap(find.text('LEGEND'));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('5 quests a day'), findsOneWidget);

      await reveal(t, find.text('BEGIN ADVENTURE'));
      await t.tap(find.text('BEGIN ADVENTURE'));
      await t.pump();
      expect(sounds.played.last, Sfx.charge);
      await t.pump(const Duration(milliseconds: 1300));
      await t.pump(const Duration(milliseconds: 700));
      await settle(t, const Duration(milliseconds: 1400));
      expect(sounds.played, contains(Sfx.levelUp));
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('NOVA KNIGHT'), findsOneWidget);
      expect(GameState.instance.mainQuest, MainQuest.hydrate);
      expect(GameState.instance.difficulty, Difficulty.legend);
      await t.pump(const Duration(seconds: 3));
      expect(t.takeException(), isNull);
    });

    testWidgets('log in: a bad email is refused, a good one gets in',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LoginScreen()));
      await settle(t, const Duration(milliseconds: 1600));
      expect(find.text('WELCOME BACK,'), findsOneWidget);

      final fields = find.byType(TextField);
      await t.enterText(fields.at(0), 'not-an-email');
      await reveal(t, find.text('LOG IN'));
      await t.tap(find.text('LOG IN'));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('That email does not look right.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);

      await t.enterText(fields.at(0), 'player@quest.app');
      await t.enterText(fields.at(1), 'hunter22');
      await t.pump();
      expect(find.text('That email does not look right.'), findsNothing);

      await t.tap(find.text('LOG IN'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1300));
      await t.pump(const Duration(milliseconds: 700));
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('PLAYER!'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('log in and sign up lead to each other',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LoginScreen()));
      await settle(t, const Duration(milliseconds: 1600));

      await reveal(t, find.text('CREATE ACCOUNT'));
      await t.tap(find.text('CREATE ACCOUNT'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1600));
      expect(find.byType(SignupScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      await reveal(t, find.text('LOG IN'));
      await t.tap(find.text('LOG IN'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1600));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('forgot password sends a link and confirms where',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LoginScreen()));
      await settle(t, const Duration(milliseconds: 1600));

      await t.tap(find.text('FORGOT PASSWORD?'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text('RESET PASSWORD'), findsOneWidget);

      await t.enterText(find.byType(TextField), 'player@quest.app');
      await t.tap(find.text('SEND RESET LINK'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1000));
      await t.pump(const Duration(milliseconds: 800));
      expect(find.text('CHECK YOUR INBOX'), findsOneWidget);
      expect(find.textContaining('player@quest.app'), findsOneWidget);

      await reveal(t, find.text('BACK TO LOG IN'));
      await t.tap(find.text('BACK TO LOG IN'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 800));
      expect(find.byType(ForgotPasswordScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('signing out from settings returns to log in',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const SettingsScreen()));
      await settle(t, const Duration(milliseconds: 1400));
      await reveal(t, find.text('Sign out'));
      await t.tap(find.text('Sign out'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      await t.tap(find.text('SIGN OUT'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1600));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
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
      expect(find.text('1/3 DONE'), findsOneWidget);
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
    testWidgets('the bar switches between the four, with a sound each time',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell()));
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(HomeScreen), findsOneWidget);

      await t.tap(navTab('REWARDS'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(RewardsScreen), findsOneWidget);
      expect(find.text('REWARDS VAULT'), findsOneWidget);

      await t.tap(navTab('STATS'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(StatsScreen), findsOneWidget);
      expect(find.text('CHARACTER STATS'), findsOneWidget);
      expect(find.text('POWER PROFILE'), findsOneWidget);

      await t.tap(navTab('PROFILE'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('PLAYER CARD'), findsOneWidget);

      await t.tap(navTab('QUESTS'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(HomeScreen), findsOneWidget);

      expect(sounds.played.where((Sfx s) => s == Sfx.nav).length, 4);
      expect(t.takeException(), isNull);
    });

    testWidgets('tapping the selected tab again is silent',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell()));
      await settle(t, const Duration(milliseconds: 1400));
      await t.tap(navTab('QUESTS'));
      await t.pump();
      expect(sounds.played, isNot(contains(Sfx.nav)));
    });
  });

  group('stats', () {
    testWidgets('shows the sheet and switches the chart to the month',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell(initialTab: NavTab.stats)));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('PHYSICAL'), findsWidgets);
      expect(find.text('HYDRATION'), findsWidgets);
      expect(find.text('POWER 50'), findsOneWidget);

      await reveal(t, find.text('MONTH'));
      expect(find.text('2,740 XP'), findsOneWidget);

      await t.tap(find.text('MONTH'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 800));
      expect(find.text('8,760 XP'), findsOneWidget);
      expect(find.text('NOW'), findsOneWidget);
      expect(sounds.played.last, Sfx.nav);

      await reveal(t, find.text('BEST STREAK'));
      expect(find.text('38,420'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('profile and its pages', () {
    testWidgets('the player card, achievements and the menu',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell(initialTab: NavTab.profile)));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('PLAYER!'), findsOneWidget);
      expect(find.text('WELLNESS WARRIOR'), findsOneWidget);
      expect(find.text('LV 12  ·  2,840 / 4,000 XP'), findsOneWidget);
      expect(find.text('BADGE SHOWCASE'), findsOneWidget);

      await reveal(t, find.text('Marathoner'));
      expect(find.text('38,420/42,195'), findsOneWidget);

      await reveal(t, find.text('Leaderboard'));
      expect(find.text('#4'), findsOneWidget);
      expect(find.text('3 NEW'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('the vault link switches to the rewards tab',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell(initialTab: NavTab.profile)));
      await settle(t, const Duration(milliseconds: 1400));
      await t.tap(find.text('VAULT  ›'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(RewardsScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('leaderboard: podium, your row, and the global board',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const LeaderboardScreen()));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('Nova'), findsOneWidget);
      expect(find.text('Kai'), findsOneWidget);
      expect(find.text('Mira'), findsOneWidget);
      expect(find.text('YOU  #4'), findsOneWidget);
      await reveal(t, find.text('You'));
      expect(find.text('#4'), findsOneWidget);

      await t.drag(find.byType(Scrollable).first, const Offset(0, 2000));
      await t.pump(const Duration(milliseconds: 400));
      await t.tap(find.text('GLOBAL'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.text('Aurora'), findsOneWidget);
      expect(find.text('YOU  #1,284'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('notifications: reading one, then all',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const NotificationsScreen()));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('3 UNREAD'), findsOneWidget);
      await t.tap(find.text('Quest complete'));
      await t.pump();
      expect(find.text('2 UNREAD'), findsOneWidget);
      expect(sounds.played.last, Sfx.tick);

      await t.tap(find.text('READ ALL'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('ALL READ'), findsOneWidget);
      expect(GameState.instance.unreadCount, 0);
      expect(sounds.played.last, Sfx.confirm);
      await t.pump(const Duration(seconds: 3));
      expect(t.takeException(), isNull);
    });

    testWidgets('settings: muting silences every sound after it',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const SettingsScreen()));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('Sound effects'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);

      await t.tap(find.byType(HudSwitch).first);
      await t.pump(const Duration(milliseconds: 400));
      expect(GameSettings.instance.sound, isFalse);
      expect(sounds.played.last, Sfx.toggleOff);
      final before = sounds.played.length;

      await t.tap(find.text('PLAY'));
      await t.pump();
      expect(sounds.played.length, before);

      await t.tap(find.byType(HudSwitch).first);
      await t.pump(const Duration(milliseconds: 400));
      expect(GameSettings.instance.sound, isTrue);
      await t.tap(find.text('PLAY'));
      await t.pump();
      expect(sounds.played.last, Sfx.levelUp);
      expect(t.takeException(), isNull);
    });

    testWidgets('settings: the volume dial steps and ticks',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const SettingsScreen()));
      await settle(t, const Duration(milliseconds: 1400));

      final dial = find.byType(VolumeDial);
      final box = t.getRect(dial);
      await t.tapAt(Offset(box.left + box.width * 0.25, box.center.dy));
      await t.pump(const Duration(milliseconds: 300));
      expect(GameSettings.instance.volume, closeTo(0.3, 0.001));
      expect(find.text('30%'), findsOneWidget);
      expect(sounds.played.last, Sfx.tick);
      expect(t.takeException(), isNull);
    });

    testWidgets('sign out asks first', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const SettingsScreen()));
      await settle(t, const Duration(milliseconds: 1400));
      await reveal(t, find.text('Sign out'));
      await t.tap(find.text('Sign out'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('LEAVE THE REALM?'), findsOneWidget);
      await t.tap(find.text('CANCEL'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('LEAVE THE REALM?'), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('quest victory', () {
    testWidgets('claiming a finished quest plays the fanfare and pays out',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(const AppShell()));
      await settle(t, const Duration(milliseconds: 1400));

      expect(find.text('CLAIM'), findsOneWidget);
      await t.tap(find.text('10 Min Meditation'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));

      final claim = find.text('CLAIM +60 XP');
      await reveal(t, claim);
      await t.tap(claim);
      await t.pump();
      expect(sounds.played, contains(Sfx.victory));

      await t.pump(const Duration(milliseconds: 2400));
      expect(find.text('VICTORY!'), findsOneWidget);
      expect(find.text('+60 XP'), findsOneWidget);
      expect(sounds.played, contains(Sfx.coin));
      expect(GameState.instance.xp, 2900);

      await t.tap(find.text('CONTINUE'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('VICTORY!'), findsNothing);
      expect(find.text('BACK TO QUESTS'), findsOneWidget);

      await t.tap(find.text('BACK TO QUESTS'));
      await t.pump();
      await settle(t, const Duration(milliseconds: 1400));
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('CLAIM'), findsNothing);
      expect(find.text('2,900 / 4,000 XP'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('the options key opens a sheet of actions',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(host(QuestScreen(quest: Quest.today.first)));
      await settle(t, const Duration(milliseconds: 1400));
      await t.tap(find.bySemanticsLabel('Quest options'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('QUEST OPTIONS'), findsOneWidget);
      expect(sounds.played.last, Sfx.open);

      await t.tap(find.text('Challenge a friend'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('QUEST OPTIONS'), findsNothing);
      expect(find.textContaining('Challenge sent'), findsOneWidget);
      await t.pump(const Duration(seconds: 3));
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

      await t.tap(find.text('Still Mind'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 800));

      expect(find.text('CLAIMED'), findsNWidgets(3));
      expect(find.text('3 of 6 badges claimed'), findsOneWidget);
      expect(find.text('1,640 XP'), findsOneWidget);
      expect(sounds.played.last, Sfx.coin);
      await t.pump(const Duration(seconds: 3));
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
      expect(sounds.played.last, Sfx.denied);
      await t.pump(const Duration(seconds: 3));
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
      await t.pumpWidget(const SizedBox.shrink());
      await t.pump(const Duration(seconds: 3));
      expect(t.takeException(), isNull);
    });
  });
}
