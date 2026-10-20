import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helora_duo/app.dart';

import 'support.dart';

void main() {
  testWidgets('phone snapshots', (tester) async {
    await loadFonts();
    device(tester, width: 390, height: 844, top: 47, bottom: 34);
    await tester.pumpWidget(const RepaintBoundary(key: ValueKey('shot'), child: HeloraApp()));
    await run(tester, 8);
    await shoot(tester, 'phone_intro');
    await run(tester, 70);
    await shoot(tester, 'phone_today');
    await tester.tap(find.text('Trends').last);
    await run(tester, 60);
    await shoot(tester, 'phone_trends');
    await tester.tap(find.text('Meds').last);
    await run(tester, 50);
    await shoot(tester, 'phone_meds');
    expect(tester.takeException(), isNull);
    done(tester);
  });

  testWidgets('duo snapshots', (tester) async {
    await loadFonts();
    device(tester, width: 951, height: 669, hinge: const Rect.fromLTWH(455.5, 0, 40, 669));
    await tester.pumpWidget(const RepaintBoundary(key: ValueKey('shot'), child: HeloraApp()));
    await run(tester, 12);
    await shoot(tester, 'duo_unfold');
    await run(tester, 70);
    await shoot(tester, 'duo_open');
    await tester.tap(find.text('7D'));
    await run(tester, 50);
    await shoot(tester, 'duo_7d');
    expect(tester.takeException(), isNull);
    done(tester);
  });
}
