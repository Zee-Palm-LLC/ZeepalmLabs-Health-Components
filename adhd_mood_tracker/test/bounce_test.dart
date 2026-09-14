import 'dart:math' as math;

import 'package:adhd_mood_tracker/core/mood.dart';
import 'package:adhd_mood_tracker/features/mood/mood_screen.dart';
import 'package:adhd_mood_tracker/features/mood/widgets/mood_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Samples the live face geometry frame by frame during a real mood change,
/// so the spring is verified on the screen rather than on the curve in
/// isolation.
void main() {
  FaceShape faceOf(WidgetTester tester) =>
      tester.widget<MoodFace>(find.byType(MoodFace)).shape;

  testWidgets('the face springs past the target before settling',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoodScreen(initialMood: 2)));
    await tester.pumpAndSettle();

    final start = Mood.values[2].face; // OKAY:      eyes 90
    final target = Mood.values[4].face; // ENERGIZED: eyes 106
    expect(faceOf(tester).eyeWidth, start.eyeWidth);

    await tester.tap(find.byKey(const ValueKey<String>('mood-dot-4')));

    final trace = <double>[];
    for (var frame = 0; frame < 48; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      trace.add(faceOf(tester).eyeWidth);
    }

    final peak = trace.reduce((a, b) => a > b ? a : b);
    debugPrint('eyeWidth trace (90 -> 106): '
        '${trace.map((v) => v.toStringAsFixed(1)).join(', ')}');

    // Overshoot: the eyes go visibly wider than ENERGIZED on the way in.
    expect(peak, greaterThan(target.eyeWidth + 2));

    // And it rings: after the peak the value comes back down below it.
    final peakIndex = trace.indexOf(peak);
    expect(trace.skip(peakIndex).any((v) => v < peak - 1), isTrue);

    // And it settles exactly on target.
    await tester.pumpAndSettle();
    expect(faceOf(tester).eyeWidth, moreOrLessEquals(target.eyeWidth));
    expect(faceOf(tester).mouthArc, moreOrLessEquals(target.mouthArc));
  });

  testWidgets('a two-step jump springs exactly like a one-step jump',
      (tester) async {
    // Regression: animating the word pager to a non-adjacent page sweeps
    // through the pages in between. If those intermediate pages are allowed to
    // feed back into the scale, the spring is restarted mid-flight toward the
    // wrong mood and the transition stutters. Normalised, both jumps must
    // trace the identical curve.
    Future<List<double>> traceFor(int index, double from, double to) async {
      // A fresh key per run, or Flutter reuses the existing State and the
      // second trace starts from wherever the first one left off.
      await tester.pumpWidget(
        MaterialApp(home: MoodScreen(key: ValueKey<int>(index), initialMood: 2)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey<String>('mood-dot-$index')));

      final trace = <double>[];
      for (var frame = 0; frame < 24; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        trace.add((faceOf(tester).eyeWidth - from) / (to - from));
      }
      await tester.pumpAndSettle();
      return trace;
    }

    final oneStep = await traceFor(3, 90, 100);
    final twoStep = await traceFor(4, 90, 106);

    for (var i = 0; i < oneStep.length; i++) {
      expect(twoStep[i], moreOrLessEquals(oneStep[i], epsilon: 0.005),
          reason: 'frame $i diverged — the spring was interrupted');
    }
  });

  testWidgets('the picked circle is the largest and springs past full size',
      (tester) async {
    double diameterOf(int i) => tester
        .getSize(find.byKey(ValueKey<String>('mood-dot-$i')))
        .width;

    await tester.pumpWidget(const MaterialApp(home: MoodScreen(initialMood: 2)));
    await tester.pumpAndSettle();

    // At rest: the selected circle is enlarged, the rest are at base size.
    expect(diameterOf(2), moreOrLessEquals(82, epsilon: 0.5));
    for (final i in <int>[0, 1, 3, 4]) {
      expect(diameterOf(i), moreOrLessEquals(52, epsilon: 0.5));
    }

    await tester.tap(find.byKey(const ValueKey<String>('mood-dot-0')));

    var peak = 0.0;
    for (var frame = 0; frame < 48; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      peak = math.max(peak, diameterOf(0));
    }
    // It overshoots the selected size on the way in...
    expect(peak, greaterThan(84));

    // ...and settles exactly, with the handover complete.
    await tester.pumpAndSettle();
    expect(diameterOf(0), moreOrLessEquals(82, epsilon: 0.5));
    expect(diameterOf(2), moreOrLessEquals(52, epsilon: 0.5));
  });

  testWidgets('the background never overshoots the scale', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoodScreen(initialMood: 2)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('mood-dot-4')));

    // Colour must stay on the OKAY -> ENERGIZED segment the whole way: a
    // spring on colour would flash a hue that is not on the scale.
    for (var frame = 0; frame < 48; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      final color = scaffold.backgroundColor!;

      expect(color.g, greaterThanOrEqualTo(Mood.values[2].color.g - 0.001));
      expect(color.g, lessThanOrEqualTo(Mood.values[4].color.g + 0.001));
      expect(color.r, lessThanOrEqualTo(Mood.values[2].color.r + 0.001));
    }
  });
}
