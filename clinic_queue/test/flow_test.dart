import 'dart:io';

import 'package:clinic_queue/app.dart';
import 'package:clinic_queue/core/glyphs.dart';
import 'package:clinic_queue/main.dart';
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

Future<FlowState> launch(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const QueueApp(simulateDevice: true));
  await settle(tester, 1600);
  expect(tester.takeException(), isNull);
  return tester.state<FlowState>(find.byType(QueueFlow));
}

Finder glyph(Glyph g) => find.byWidgetPredicate((w) => w is GlyphIcon && w.glyph == g);

void main() {
  setUpAll(loadFonts);

  testWidgets('full visit: token, live queue, route, swap, en route, check in', (tester) async {
    final flow = await launch(tester, const Size(393, 852));
    expect(find.text('Where are you\nvisiting?'), findsOneWidget);
    expect(find.text('YOUR NEXT TOKEN'), findsOneWidget);

    await tester.tap(find.text('Pediatrics'));
    await settle(tester, 300);
    await tester.tap(find.text('Get my token'));
    await settle(tester, 700);
    expect(find.text('Confirm your token'), findsOneWidget);
    expect(find.text('Dr. Oliver Hayes · Pediatrics'), findsOneWidget);

    await tester.tap(find.text('Confirm token'));
    await settle(tester, 1200);
    expect(find.text("You're in line!"), findsOneWidget);
    await settle(tester, 1800);
    expect(flow.step, FlowState.queue);
    expect(flow.visit.hasToken, isTrue);
    expect(find.text('LIVE QUEUE'), findsOneWidget);

    await settle(tester, 9000);
    expect(find.text('3 rd', findRichText: true), findsOneWidget);
    await settle(tester, 8000);
    expect(flow.visit.sim.rank, 2);
    expect(find.text('Almost your turn · plan route'), findsOneWidget);

    await tester.tap(find.text('Almost your turn · plan route'));
    await settle(tester, 1600);
    expect(flow.step, FlowState.route);

    await tester.tap(find.text('Need more time? Swap spot'));
    await settle(tester, 700);
    expect(find.text('Need more time?'), findsOneWidget);
    await tester.tap(find.text('Swap spot'));
    await settle(tester, 700);
    expect(flow.visit.sim.rank, 3);
    expect(find.text('You let 1 person go ahead'), findsOneWidget);

    await tester.tap(glyph(Glyph.info));
    await settle(tester, 700);
    expect(find.text('Visit details'), findsOneWidget);
    flow.back();
    await settle(tester, 600);
    expect(flow.sheet, isNull);

    await tester.tap(find.text("I'm on my way"));
    await settle(tester, 1000);
    expect(find.text('On the way to CityCare'), findsOneWidget);
    expect(find.text('ON THE WAY'), findsOneWidget);
    await settle(tester, 5800);
    expect(flow.step, FlowState.turn);

    await tester.tap(find.text("I'm here"));
    await settle(tester, 600);
    expect(find.text('Checked in'), findsOneWidget);
    await settle(tester, 2000);
    expect(flow.step, FlowState.home);
    expect(flow.visit.hasToken, isFalse);
    expect(find.text('Checked in · Room 3 at 10:41 AM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('queue and map tabs ask for a token first; profile works', (tester) async {
    final flow = await launch(tester, const Size(393, 852));
    await tester.tap(glyph(Glyph.queue));
    await settle(tester, 700);
    expect(flow.step, FlowState.home);
    expect(find.text('Confirm your token'), findsOneWidget);
    flow.back();
    await settle(tester, 600);

    await tester.tap(glyph(Glyph.user));
    await settle(tester, 1400);
    expect(flow.step, FlowState.profile);
    expect(find.text('Grace Bennett'), findsOneWidget);
    expect(find.text('NO ACTIVE TOKEN'), findsOneWidget);
    await tester.tap(find.text('Leave-time alerts'));
    await settle(tester, 300);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel token from visit details', (tester) async {
    final flow = await launch(tester, const Size(393, 852));
    flow.visit.take();
    flow.go(FlowState.route);
    await settle(tester, 1600);
    flow.open(Sheet.visit);
    await settle(tester, 700);
    await tester.tap(find.text('Cancel my token'));
    await settle(tester, 1600);
    expect(flow.step, FlowState.home);
    expect(flow.visit.hasToken, isFalse);
  });

  for (final size in const [Size(360, 640), Size(360, 780), Size(393, 852), Size(412, 915), Size(430, 932)]) {
    testWidgets('every screen and sheet fits ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      final flow = await launch(tester, size);
      flow.open(Sheet.token);
      await settle(tester, 700);
      expect(tester.takeException(), isNull, reason: 'token sheet');
      flow.close();
      flow.visit.take();
      for (final step in [FlowState.queue, FlowState.route, FlowState.turn, FlowState.profile]) {
        flow.go(step);
        await settle(tester, 1600);
        expect(tester.takeException(), isNull, reason: 'step $step');
      }
      flow.go(FlowState.route);
      await settle(tester, 1200);
      for (final sheet in [Sheet.swap, Sheet.visit]) {
        flow.open(sheet);
        await settle(tester, 700);
        expect(tester.takeException(), isNull, reason: '$sheet');
      }
    });
  }
}
