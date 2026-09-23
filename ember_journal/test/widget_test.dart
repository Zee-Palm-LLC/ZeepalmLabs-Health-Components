import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ember_journal/app.dart';

import 'fonts.dart';

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(786, 1704);
  tester.view.devicePixelRatio = 2;
  tester.view.viewPadding = const FakeViewPadding(top: 118, bottom: 68);
  tester.view.padding = const FakeViewPadding(top: 118, bottom: 68);
  addTearDown(tester.view.reset);
}

Future<void> settle(WidgetTester tester, [int frames = 60]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 34));
  }
}

void main() {
  testWidgets('a rolled question becomes a journal entry', (tester) async {
    await loadPoppins();
    phone(tester);
    await tester.pumpWidget(const EmberApp());
    await settle(tester);

    expect(find.text('Random question'), findsOneWidget);
    expect(find.text('Shake your'), findsOneWidget);

    await tester.tap(find.text('Get a question'));
    await settle(tester);

    expect(find.text('Your reflection'), findsOneWidget);
    expect(find.text('Random Question'), findsOneWidget);

    await tester.tap(find.text('Add to Journal'));
    await settle(tester, 110);

    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Thursday, March 19'), findsOneWidget);
  });

  testWidgets('week strip switches the day label', (tester) async {
    await loadPoppins();
    phone(tester);
    await tester.pumpWidget(const EmberApp());
    await settle(tester);
    await tester.tap(find.text('Get a question'));
    await settle(tester);
    await tester.tap(find.text('Add to Journal'));
    await settle(tester, 110);

    await tester.tap(find.text('16'));
    await settle(tester, 30);
    expect(find.text('Monday, March 16'), findsOneWidget);
  });
}
