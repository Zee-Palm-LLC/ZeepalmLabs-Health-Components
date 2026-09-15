import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:symptom_assessment/core/design.dart';
import 'package:symptom_assessment/data/symptoms.dart';
import 'package:symptom_assessment/features/assess/assess_screen.dart';
import 'package:symptom_assessment/features/report/report_screen.dart';
import 'package:symptom_assessment/features/search/search_screen.dart';
import 'package:symptom_assessment/main.dart';
import 'package:symptom_assessment/widgets/expandable_section.dart';
import 'package:symptom_assessment/widgets/glass_orb.dart';
import 'package:symptom_assessment/widgets/rolling_number.dart';
import 'package:symptom_assessment/widgets/search_field.dart';
import 'package:symptom_assessment/widgets/symptom_chip.dart';
import 'package:symptom_assessment/widgets/symptom_tile.dart';

/// Lets a screen's entrance controller run out, plus the longest route.
///
/// Never `pumpAndSettle`: the orb, the wash and the button sheen tick for
/// as long as they are on screen, so "settled" never arrives.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(D.entrance + const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 16));
}

/// A phone-shaped viewport, 393 x 852 logical, the canvas the layout was
/// measured against. The default 800 x 600 test surface is wider and much
/// shorter, and pushes the report's sections below the fold.
void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393 * 3, 852 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('catalogue', () {
    test('"back pain" returns the reference results in order', () {
      final names = Catalogue.search('back pain').map((s) => s.name).toList();
      expect(names.length, 10);
      // Phrase matches lead, then name matches, then hint matches, and the
      // one that only matched through hidden terms comes last.
      expect(names.sublist(0, 3),
          <String>['Back pain', 'Lower back pain', 'Upper back pain']);
      expect(names, containsAll(<String>[
        'Headache',
        'Muscle tenderness in the back',
        'Elbow pain',
        'Knee stiffness after exercise',
      ]));
      expect(names.last, 'Knee stiffness after exercise');
    });

    test('word order does not matter and blanks return nothing', () {
      expect(Catalogue.search('pain back').first.name, 'Back pain');
      expect(Catalogue.search('   '), isEmpty);
      expect(Catalogue.search('zzzz'), isEmpty);
    });

    test('back symptoms escalate to the emergency report', () {
      final a = Catalogue.assess(Catalogue.search('back pain').first);
      expect(a.bestMatch.name, 'Thoracolumbar spine trauma');
      expect(a.bestMatch.urgency, Urgency.emergency);
      expect(a.attentionLabel, 'Needs immediate attention');
      expect(a.actionTitle, 'Call an ambulance');
      expect(a.lessLikely.length, 3);
      expect(a.reported.single.name, 'Back pain');
    });

    test('a cold-family symptom gets the routine report', () {
      final a = Catalogue.assess(Catalogue.popular[1]); // Runny nose
      expect(a.bestMatch.urgency, Urgency.routine);
      expect(a.actionTitle, 'Rest and monitor');
    });

    test('every popular chip has an emoji asset name', () {
      for (final s in Catalogue.popular) {
        expect(s.emoji, isNotNull, reason: s.name);
      }
    });
  });

  group('assess screen', () {
    testWidgets('renders the headline, field, chips and privacy card',
        (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(const SymptomApp());
      await settle(tester);

      expect(find.text('Symptom Assessment'), findsOneWidget);
      // The headline is set one word at a time; every word is present.
      for (final w in <String>['What', 'symptom', 'bothering', 'most?']) {
        expect(find.textContaining(w), findsWidgets, reason: w);
      }
      expect(find.byType(SearchField), findsOneWidget);
      expect(find.byType(GlassOrb), findsOneWidget);
      expect(find.text('Popular searches'), findsOneWidget);
      expect(find.byType(SymptomChip), findsWidgets);
      expect(find.text('Your health, your data'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the entrance is staggered top to bottom',
        (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(const SymptomApp());
      await tester.pump();
      // A third of the way in: the header is fully up, the privacy card
      // has not started.
      await tester.pump(D.entrance * 0.33);
      final privacy = tester.widget<Opacity>(find.ancestor(
        of: find.text('Your health, your data'),
        matching: find.byType(Opacity),
      ).first);
      expect(privacy.opacity, 0);
      final title = tester.widget<Opacity>(find.ancestor(
        of: find.text('Symptom Assessment'),
        matching: find.byType(Opacity),
      ).first);
      expect(title.opacity, 1);
      await settle(tester);
    });

    testWidgets('tapping the field opens the results screen and the field '
        'lands at the top', (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(const SymptomApp());
      await settle(tester);

      final before = tester.getTopLeft(find.byType(SearchField));
      await tester.tap(find.byType(SearchField));
      await tester.pump();
      await tester.pump(D.route + const Duration(milliseconds: 50));
      await settle(tester);

      expect(find.byType(SearchScreen), findsOneWidget);
      final after = tester.getTopLeft(find.byType(SearchField));
      expect(after.dy, lessThan(before.dy - 100));
      expect(find.text('Popular symptoms: '), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a chip searches for it', (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(const SymptomApp());
      await settle(tester);

      await tester.tap(find.text('Headache').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(D.route + const Duration(milliseconds: 100));
      await settle(tester);

      expect(find.byType(SearchScreen), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Headache');
      expect(find.text('Symptoms found: '), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('search screen', () {
    testWidgets('typing filters, the count rolls, clearing restores popular',
        (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await settle(tester);

      await tester.enterText(find.byType(TextField), 'back pain');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Symptoms found: '), findsOneWidget);
      final count = tester.widget<RollingNumber>(find.byType(RollingNumber));
      expect(count.value, 10);
      expect(find.text('Back pain'), findsOneWidget);
      expect(find.text('Lower back pain'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('Popular symptoms: '), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a result opens the report inside a container transform',
        (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'back');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('Back pain'));
      await tester.pump();
      // Mid-flight: both screens exist, the report is not yet fully shown.
      await tester.pump(D.containerRoute * 0.4);
      expect(find.byType(ReportScreen), findsOneWidget);
      expect(find.byType(SearchScreen), findsOneWidget);

      await tester.pump(D.containerRoute);
      await settle(tester);
      expect(find.text('Your assessment report'), findsOneWidget);
      expect(find.text('Needs immediate attention'), findsOneWidget);
      expect(find.text('Thoracolumbar spine trauma'), findsOneWidget);
      expect(find.text('Call an ambulance'), findsOneWidget);
      expect(find.text('Read about this condition'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the ? badge opens an explanation', (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'lower back');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      final tile = find.byType(SymptomTile).first;
      // The badge is the innermost Pressable inside the tile.
      await tester.tap(find.descendant(
        of: tile,
        matching: find.byWidgetPredicate(
            (Widget w) => w is Container && w.constraints?.maxWidth == D.badge),
      ).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Got it'), findsOneWidget);
      expect(find.textContaining('People also describe it as'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('report screen', () {
    final assessment = Catalogue.assess(Catalogue.search('back pain').first);

    testWidgets('sections expand and collapse with a turning chevron',
        (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(
          MaterialApp(home: ReportScreen(assessment: assessment)));
      await settle(tester);

      // Collapsed: the body exists but is clipped away, so it is not
      // hit-testable.
      expect(find.text('Lumbar muscle strain').hitTestable(), findsNothing);
      await tester.tap(find.text('Less likely causes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Lumbar muscle strain').hitTestable(), findsOneWidget);
      expect(find.text('Herniated disc').hitTestable(), findsOneWidget);

      await tester.tap(find.text('Less likely causes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      // Collapsed again: the body is clipped to zero height.
      final align = tester.widget<Align>(find.descendant(
        of: find.byType(ExpandableSection).first,
        matching: find.byWidgetPredicate(
            (Widget w) => w is Align && w.heightFactor != null),
      ));
      expect(align.heightFactor, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reported symptoms are listed', (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(
          MaterialApp(home: ReportScreen(assessment: assessment)));
      await settle(tester);
      expect(find.text('Back pain').hitTestable(), findsNothing);
      await tester.tap(find.text('Symptoms you reported'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Back pain').hitTestable(), findsOneWidget);
    });

    testWidgets('the button opens the condition sheet',
        (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(
          MaterialApp(home: ReportScreen(assessment: assessment)));
      await settle(tester);
      await tester.tap(find.text('Read about this condition'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.textContaining('guidance, not a diagnosis'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the whole flow tears down without leaking timers',
        (WidgetTester tester) async {
      phone(tester);
      await tester.pumpWidget(const SymptomApp());
      await settle(tester);
      await tester.tap(find.byType(SearchField));
      await tester.pump();
      await tester.pump(D.route + const Duration(milliseconds: 50));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'back');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.tap(find.text('Back pain'));
      await tester.pump();
      await tester.pump(D.containerRoute + const Duration(milliseconds: 50));
      await settle(tester);
      expect(find.byType(ReportScreen), findsOneWidget);
      // Close returns to the first route.
      Navigator.of(tester.element(find.byType(ReportScreen)))
          .popUntil((Route r) => r.isFirst);
      await tester.pump();
      await tester.pump(D.containerRoute + const Duration(milliseconds: 50));
      await tester.pump(D.route + const Duration(milliseconds: 50));
      expect(find.byType(ReportScreen), findsNothing);
      expect(find.byType(AssessScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
