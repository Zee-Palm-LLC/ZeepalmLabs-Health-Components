import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunara/app.dart';
import 'package:lunara/core/glyphs.dart';
import 'package:lunara/main.dart';

Future<void> loadFonts() async {
  for (final entry in {'Poppins': 'Poppins-Regular.ttf'}.entries) {
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/${entry.value}').readAsBytesSync())));
    await loader.load();
  }
}

Future<void> settle(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 40; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

Future<FlowState> launch(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const LunaraApp(simulateDevice: true));
  await settle(tester, 2400);
  expect(tester.takeException(), isNull);
  return tester.state<FlowState>(find.byType(LunaraFlow));
}

Finder glyph(Glyph g) => find.byWidgetPredicate((w) => w is GlyphIcon && w.glyph == g);

void main() {
  setUpAll(loadFonts);

  testWidgets('welcome morphs into the cycle ring', (tester) async {
    final flow = await launch(tester, const Size(393, 852));
    expect(find.text('Embrace your rhythm'), findsOneWidget);
    expect(find.text('Smart predictions'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await settle(tester, 2600);
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Ava'), findsOneWidget);
    expect(find.text('Ovulation'), findsWidgets);
    expect(find.text('14'), findsWidgets);
    expect(flow.tab, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a feeling chip opens the log with that section focused', (tester) async {
    final flow = await launch(tester, const Size(393, 852));
    flow.begin();
    await settle(tester, 2600);

    await tester.tap(find.text('Mood').first);
    await settle(tester, 2200);
    expect(flow.tab, 1);
    expect(flow.focus, 'Mood');
    expect(find.text('May 14, 2024'), findsOneWidget);
    expect(find.text('Flow intensity'), findsOneWidget);
    expect(find.text('Ovulation · Day 14'), findsOneWidget);
  });

  testWidgets('logging a day records flow, mood, energy and symptoms', (tester) async {
    final flow = await launch(tester, const Size(393, 852));
    flow.begin();
    await settle(tester, 2600);
    flow.openTab(1);
    await settle(tester, 2400);

    expect(flow.cycle.flow, 2);
    await tester.tap(find.text('Heavy'));
    await settle(tester, 700);
    expect(flow.cycle.flow, 4);

    expect(flow.cycle.picked.contains('Fatigue'), isFalse);
    await tester.tap(find.text('Fatigue'));
    await settle(tester, 700);
    expect(flow.cycle.picked.contains('Fatigue'), isTrue);

    await tester.tap(find.text('Cramps'));
    await settle(tester, 700);
    expect(flow.cycle.picked.contains('Cramps'), isFalse);

    await tester.tap(find.text('Save day'));
    await settle(tester, 2600);
    expect(flow.cycle.saved, isTrue);
    expect(flow.tab, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabs reach insights and you', (tester) async {
    final flow = await launch(tester, const Size(393, 852));
    flow.begin();
    await settle(tester, 2600);

    await tester.tap(glyph(Glyph.chart).first);
    await settle(tester, 2400);
    expect(flow.tab, 2);
    expect(find.text('Insights'), findsWidgets);
    expect(find.text('Your cycle overview'), findsOneWidget);
    expect(find.text('Next 3 cycles'), findsOneWidget);

    await tester.tap(glyph(Glyph.user).first);
    await settle(tester, 2400);
    expect(flow.tab, 3);
    expect(find.text('Ava Moreau'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a week day moves the ring', (tester) async {
    final flow = await launch(tester, const Size(393, 852));
    flow.begin();
    await settle(tester, 2600);
    expect(flow.cycle.day, 14);
    await tester.tap(find.text('10').first);
    await settle(tester, 900);
    expect(flow.cycle.day, 10);
    expect(find.text('Follicular'), findsWidgets);
  });

  for (final size in const [Size(360, 640), Size(360, 780), Size(393, 852), Size(412, 915), Size(430, 932)]) {
    testWidgets('every screen fits ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      final flow = await launch(tester, size);
      expect(tester.takeException(), isNull, reason: 'welcome');
      flow.begin();
      await settle(tester, 2600);
      expect(tester.takeException(), isNull, reason: 'home');
      for (final tab in [1, 2, 3, 0]) {
        flow.openTab(tab);
        await settle(tester, 2400);
        expect(tester.takeException(), isNull, reason: 'tab $tab');
      }
    });
  }
}
