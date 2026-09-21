import 'dart:io';

import 'package:care_circle/core/widgets.dart';
import 'package:care_circle/data/store.dart';
import 'package:care_circle/features/shell/shell.dart';
import 'package:care_circle/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Jakarta')
    ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans.ttf').readAsBytesSync())));
  await loader.load();
}

Future<void> settle(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> launch(WidgetTester tester, {Size size = const Size(393, 852)}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  CareStore.instance.reset();
  await tester.pumpWidget(const CareApp(simulateDevice: true));
  await tester.runAsync(() => Portrait.warm(tester.element(find.byType(Scaffold).first)));
  await settle(tester, 2400);
  expect(tester.takeException(), isNull);
}

Future<void> toHome(WidgetTester tester) async {
  await tester.tap(find.text('Create your circle'));
  await settle(tester, 2400);
  expect(find.byType(Shell), findsOneWidget);
}

void main() {
  setUpAll(loadFonts);

  testWidgets('welcome shows the brand, headline and actions', (tester) async {
    await launch(tester);
    expect(find.textContaining('CareCircle', findRichText: true), findsOneWidget);
    expect(find.text('people'), findsOneWidget);
    expect(find.text('Create your circle'), findsOneWidget);
    expect(find.text('I was invited'), findsOneWidget);
  });

  testWidgets('home shows the family orbit, stats and quick actions', (tester) async {
    await launch(tester);
    await toHome(tester);
    for (final name in [
      'Grandpa Joe',
      'Nana Rose',
      'Mom',
      'Dad',
      'Leo',
      'Family',
      '5 members',
      '4 of 5',
      '11/12',
      'Thu',
    ]) {
      expect(find.text(name), findsWidgets, reason: name);
    }
    expect(find.text('Quick actions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nudge, open the missed dose, assign, remind and mark taken', (tester) async {
    await launch(tester);
    await toHome(tester);
    await tester.tap(find.text('Grandpa Joe').first);
    await settle(tester, 1800);
    expect(find.text('Grandpa Joe, 78'), findsOneWidget);
    expect(find.text('Needs a nudge'), findsOneWidget);

    await tester.tap(find.text('Nudge Grandpa'));
    await settle(tester, 1800);
    expect(find.text('Nudge sent'), findsOneWidget);
    expect(find.text('Nudged just now'), findsOneWidget);

    await tester.tap(find.text('Metformin 500mg'));
    await settle(tester, 1600);
    expect(find.text('For blood sugar management'), findsOneWidget);
    expect(find.text('Missed'), findsWidgets);

    await tester.tap(find.text('Mom').last);
    await settle(tester, 500);
    expect(CareStore.instance.assignee, 'mom');
    await tester.ensureVisible(find.text('Send gentle reminder'));
    await tester.tap(find.text('Send gentle reminder'));
    await settle(tester, 800);
    expect(find.text('Reminder sent to Mom'), findsOneWidget);

    await tester.ensureVisible(find.text('Mark as taken'));
    await tester.tap(find.text('Mark as taken'));
    await settle(tester, 1400);
    expect(CareStore.instance.morningTaken, isTrue);
    expect(find.text('Taken'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabs switch between timeline, meds and profile', (tester) async {
    await launch(tester);
    await toHome(tester);
    await tester.tap(find.text('Timeline').last);
    await settle(tester, 1400);
    expect(find.text('Family timeline'), findsOneWidget);
    await tester.tap(find.text('Visits'));
    await settle(tester, 1000);
    expect(find.text('Cardiology · Dr. Patel'), findsOneWidget);

    await tester.tap(find.text('Meds').last);
    await settle(tester, 1400);
    expect(find.text('Medications'), findsOneWidget);
    expect(find.text('11 of 12 doses taken'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await settle(tester, 1400);
    expect(find.text('Sara Mitchell'), findsOneWidget);

    await tester.tap(find.byType(GestureDetector).last, warnIfMissed: false);
    await settle(tester, 200);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reactions toggle', (tester) async {
    await launch(tester);
    await toHome(tester);
    await tester.tap(find.text('Grandpa Joe').first);
    await settle(tester, 1800);
    final moment = CareStore.instance.moments.first;
    final before = moment.liked;
    await tester.tap(find.byType(HeartBurst).first);
    await settle(tester, 800);
    expect(moment.liked, !before);
  });

  for (final size in const [Size(360, 640), Size(360, 740), Size(393, 852), Size(412, 915)]) {
    testWidgets('every screen fits ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      await launch(tester, size: size);
      await toHome(tester);
      expect(tester.takeException(), isNull);
      for (final tab in ['Timeline', 'Meds', 'Profile', 'Home']) {
        await tester.tap(find.text(tab).last);
        await settle(tester, 1400);
        expect(tester.takeException(), isNull, reason: tab);
      }
      await tester.tap(find.text('Leo').first);
      await settle(tester, 1800);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Metformin 500mg'));
      await settle(tester, 300);
      await tester.tap(find.text('Metformin 500mg'));
      await settle(tester, 1600);
      expect(find.text('For blood sugar management'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
