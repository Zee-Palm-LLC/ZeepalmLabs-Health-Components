import 'package:adhd_mood_tracker/features/mood/mood_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openSheet(WidgetTester tester, {String? note}) async {
    await tester.pumpWidget(MaterialApp(home: MoodScreen(initialNote: note)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(note ?? 'Add note'));
    await tester.pumpAndSettle();
  }

  testWidgets('writing a note puts it on the bar', (tester) async {
    await openSheet(tester);
    expect(find.text('What is going on?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Three deadlines');
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();

    expect(find.text('Three deadlines'), findsOneWidget);
    expect(find.text('NOTE'), findsOneWidget);
    expect(find.text('Add note'), findsNothing);
  });

  testWidgets('the sheet survives its own exit animation', (tester) async {
    // Regression: the controller used to be created by the caller and disposed
    // as soon as `showModalBottomSheet` returned — which is while the sheet is
    // still animating out and still rebuilding its TextField. That threw
    // "A TextEditingController was used after being disposed", and only on the
    // frames *during* the exit, so pumpAndSettle alone would not catch it.
    await openSheet(tester);
    await tester.tap(find.text('Save note'));

    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull, reason: 'threw on exit frame $frame');
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the sheet scrolls instead of overflowing under the keyboard',
      (tester) async {
    // Regression: with the IME up there is very little height left, and a
    // fixed Column overflowed rather than scrolling.
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(1080, 1400);
    tester.view.devicePixelRatio = 3;

    await openSheet(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('an existing note can be removed', (tester) async {
    await openSheet(tester, note: 'Old note');
    expect(find.text('Remove'), findsOneWidget);

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Add note'), findsOneWidget);
    expect(find.text('Old note'), findsNothing);
  });

  testWidgets('the info sheet lists every mood', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoodScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('About this scale'));
    await tester.pumpAndSettle();

    expect(find.text('The scale'), findsOneWidget);
    for (final tick in <String>[
      'Overwhelmed',
      'Drained',
      'Okay',
      'Focused',
      'Energized',
    ]) {
      expect(find.text(tick), findsOneWidget);
    }
  });
}
