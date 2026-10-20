import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helora_duo/app.dart';

import 'support.dart';

void main() {
  const phones = [(360.0, 640.0, 24.0, 0.0), (390.0, 844.0, 47.0, 34.0), (430.0, 932.0, 59.0, 34.0), (466.0, 678.0, 32.0, 20.0)];
  for (final (w, h, top, bottom) in phones) {
    testWidgets('phone column lays out at ${w.toInt()}x${h.toInt()}', (tester) async {
      await loadFonts();
      device(tester, width: w, height: h, top: top, bottom: bottom);
      await tester.pumpWidget(const HeloraApp());
      await run(tester, 60);
      expect(find.byKey(const ValueKey('column')), findsOneWidget);
      expect(find.textContaining('Metformin', findRichText: true), findsNothing, reason: 'the single screen never names a medication on Today');
      for (final tab in ['Trends', 'Meds', 'Profile', 'Today']) {
        await tester.tap(find.text(tab).last);
        await run(tester, 40);
      }
      await tester.tap(find.text('Meds').last);
      await run(tester, 30);
      expect(find.textContaining('Metformin', findRichText: true), findsNothing, reason: 'names stay veiled until asked');
      await tester.tap(find.text('Show names'));
      await run(tester, 30);
      expect(find.textContaining('Metformin', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
      done(tester);
    });
  }

  const spreads = [
    ('iPhone Duo open', 951.0, 669.0, Rect.fromLTWH(455.5, 0, 40, 669)),
    ('tablet', 1024.0, 768.0, null),
    ('phone landscape', 844.0, 390.0, null),
  ];
  for (final (name, w, h, hinge) in spreads) {
    testWidgets('$name spreads Today and Trends', (tester) async {
      await loadFonts();
      device(tester, width: w, height: h, hinge: hinge);
      await tester.pumpWidget(const HeloraApp());
      await run(tester, 60);
      expect(find.byKey(const ValueKey('spread')), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
      if (hinge != null) {
        for (final text in ['Today', 'Trends', 'Medications']) {
          final box = tester.getRect(find.text(text));
          expect(box.right <= hinge.left - 24 || box.left >= hinge.right + 24, isTrue, reason: '$text keeps 24 pt off the hinge');
        }
      }
      for (final r in ['7D', '90D', '30D']) {
        await tester.tap(find.text(r));
        await run(tester, 30);
      }
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -400));
      await run(tester, 30);
      expect(tester.takeException(), isNull);
      done(tester);
    });
  }
}
