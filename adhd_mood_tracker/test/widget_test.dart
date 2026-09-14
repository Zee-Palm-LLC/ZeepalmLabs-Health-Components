import 'package:adhd_mood_tracker/core/mood.dart';
import 'package:adhd_mood_tracker/features/mood/mood_screen.dart';
import 'package:adhd_mood_tracker/features/mood/widgets/mood_picker_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Mood scale', () {
    test('has five stops, ordered worst to best', () {
      expect(Mood.values, hasLength(5));
      expect(Mood.last, 4);
      expect(
        Mood.values.map((m) => m.word),
        <String>['OVERWHELMED', 'DRAINED', 'OKAY', 'FOCUSED', 'ENERGIZED'],
      );
    });

    test('samples continuously between stops', () {
      expect(Mood.colorAt(0), Mood.values[0].color);
      expect(Mood.colorAt(4), Mood.values[4].color);

      final half = Mood.colorAt(0.5);
      expect(half, isNot(Mood.values[0].color));
      expect(half, isNot(Mood.values[1].color));
    });

    test('clamps out-of-range positions instead of throwing', () {
      expect(Mood.colorAt(-3), Mood.values[0].color);
      expect(Mood.colorAt(99), Mood.values[4].color);
      expect(Mood.faceAt(99), Mood.values[4].face);
    });

    test('the mouth passes through flat on its way from frown to smile', () {
      final frown = Mood.faceAt(0).mouthArc;
      final smile = Mood.faceAt(4).mouthArc;
      expect(frown, lessThan(0));
      expect(smile, greaterThan(0));

      // Somewhere between OKAY and its neighbours the arc crosses zero.
      expect(Mood.faceAt(2).mouthArc, 0);
    });

    test('face geometry extrapolates past the target so it can spring', () {
      final a = Mood.values[2].face; // OKAY, eyes 90
      final b = Mood.values[4].face; // ENERGIZED, eyes 106

      // Curves.elasticOut feeds values above 1; the shape must overshoot,
      // not clamp, or there is no bounce.
      final overshoot = FaceShape.lerp(a, b, 1.25);
      expect(overshoot.eyeWidth, greaterThan(b.eyeWidth));
      expect(overshoot.mouthArc, greaterThan(b.mouthArc));
    });

    test('a hard overshoot can never invert an eye', () {
      final big = Mood.values[4].face; // eyes 106 tall
      final squint = Mood.values[1].face; // eyes 30 tall

      for (final t in <double>[1.3, 1.6, 2.5]) {
        final shape = FaceShape.lerp(big, squint, t);
        expect(shape.eyeHeight, greaterThan(0));
        expect(shape.eyeWidth, greaterThan(0));
        expect(shape.mouthWidth, greaterThan(0));
      }
    });

    test('derived colours are darker than the background they come from', () {
      for (final mood in Mood.values) {
        final bg = HSLColor.fromColor(mood.color).lightness;
        expect(HSLColor.fromColor(mood.surfaceColor).lightness, lessThan(bg));
        expect(
          HSLColor.fromColor(mood.wordColor).lightness,
          lessThan(HSLColor.fromColor(mood.surfaceColor).lightness),
        );
      }
    });
  });

  testWidgets('renders the initial mood and moves when a stop is tapped',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MoodScreen(initialMood: 2)),
    );
    await tester.pumpAndSettle();

    expect(find.text('OKAY'), findsOneWidget);
    expect(find.text('Add note'), findsOneWidget);
    expect(find.byType(MoodPickerRow), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    // Tap the right-most picker circle to jump to ENERGIZED.
    await tester.tap(find.byKey(const ValueKey<String>('mood-dot-4')));
    await tester.pumpAndSettle();

    expect(find.text('ENERGIZED'), findsOneWidget);
  });
}
