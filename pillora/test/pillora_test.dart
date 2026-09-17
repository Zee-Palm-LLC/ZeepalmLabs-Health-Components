import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillora/core/icons/glyphs.dart';
import 'package:pillora/core/shaders.dart';
import 'package:pillora/data/assistant_brain.dart';
import 'package:pillora/data/medications.dart';
import 'package:pillora/features/assistant/assistant_screen.dart';
import 'package:pillora/features/home/dose_card.dart';
import 'package:pillora/features/shell/app_shell.dart';
import 'package:pillora/main.dart';

void main() {
  setUpAll(() async {
    final poppins = FontLoader('Poppins');
    for (final weight in ['Regular', 'Medium', 'SemiBold']) {
      poppins.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
    }
    await poppins.load();
    await Shaders.load();
  });

  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Finder glyph(Glyph value) => find.byWidgetPredicate((w) => w is GlyphIcon && w.glyph == value);

  Future<void> settle(WidgetTester tester, [int millis = 3200]) async {
    for (var elapsed = 0; elapsed < millis; elapsed += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('data', () {
    test('week plan starts on Sunday and contains today', () {
      final plan = WeekPlan(DateTime(2026, 9, 17, 9, 41));
      expect(plan.start.weekday, DateTime.sunday);
      expect(plan.todayIndex, 4);
      expect(plan.day(plan.todayIndex).day, 17);
      expect(plan.doseFor(plan.todayIndex), Cabinet.amlodipine);
    });

    test('greeting follows the clock', () {
      expect(greetingFor(DateTime(2026, 1, 1, 8)), 'Good morning');
      expect(greetingFor(DateTime(2026, 1, 1, 14)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 1, 1, 20)), 'Good evening');
    });

    test('helper answers by topic', () {
      expect(AssistantBrain.reply('Generate summary'), contains('Amlodipine 5mg is next'));
      expect(AssistantBrain.reply('I missed a dose'), contains('Never take two doses'));
      expect(AssistantBrain.reply('Any tips for my Amoxicillin course?'), contains('every 8 hours'));
      expect(AssistantBrain.reply('When should I take Amlodipine?'), contains('10:00 AM'));
    });
  });

  testWidgets('onboarding plays and Get started opens the dashboard', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const PilloraApp(simulateDevice: true));
    await settle(tester, 3600);

    expect(find.text('Never'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await settle(tester, 4200);

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('Robert fox'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Amlodipine - 5mg'), findsOneWidget);
    expect(find.text('Dose Schedule'), findsOneWidget);
    await settle(tester, 3000);
  });

  testWidgets('marking a dose taken and switching days', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const PilloraApp(home: AppShell()));
    await settle(tester);

    await tester.tap(find.text('Taken'));
    await settle(tester, 1500);
    expect(find.text('Dose taken at 9:41'), findsOneWidget);
    await settle(tester, 2000);

    final plan = WeekPlan(DateTime.now());
    final other = plan.todayIndex == 6 ? 5 : plan.todayIndex + 1;
    await tester.tap(find.text('${plan.day(other).day}').first);
    await settle(tester, 1200);
    final card = tester.widget<DoseCard>(find.byType(DoseCard));
    expect(card.dayIndex, other);
    expect(find.text(plan.doseFor(other).title), findsOneWidget);
  });

  testWidgets('nav bar switches to the plan tab', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const PilloraApp(home: AppShell()));
    await settle(tester);

    await tester.tap(glyph(Glyph.calendar).first);
    await settle(tester, 1500);
    expect(find.text('Medication plan'), findsOneWidget);
    await settle(tester, 2000);
  });

  testWidgets('assistant sends a suggestion and streams a reply', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const PilloraApp(home: AssistantScreen()));
    await settle(tester, 2600);

    expect(find.text('AI helper'), findsOneWidget);
    expect(find.text('Ask me anything'), findsOneWidget);

    await tester.tap(find.text('Generate summary'));
    await settle(tester, 600);
    expect(find.text('Pillora AI'), findsOneWidget);
    expect(find.text('Generate summary'), findsNWidgets(2));

    await settle(tester, 6000);
    expect(find.textContaining('12 day streak', findRichText: true), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
  });

  testWidgets('voice input transcribes and sends', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const PilloraApp(home: AssistantScreen()));
    await settle(tester, 2600);

    await tester.tap(glyph(Glyph.mic));
    await settle(tester, 400);
    expect(find.text('Listening'), findsOneWidget);

    await settle(tester, 9000);
    expect(find.text(AssistantBrain.voicePrompt), findsOneWidget);
    expect(find.textContaining('once a day', findRichText: true), findsOneWidget);
  });
}
