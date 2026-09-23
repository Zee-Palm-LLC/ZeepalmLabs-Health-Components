import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ember_journal/app.dart';

import 'fonts.dart';

const dir = String.fromEnvironment('SNAP_DIR');

Future<void> settle(WidgetTester tester, [int frames = 60]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 34));
  }
}

Future<void> shoot(WidgetTester tester, String name) async {
  if (dir.isEmpty) return;
  final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary));
  late ui.Image image;
  await tester.runAsync(() async {
    image = await boundary.toImage(pixelRatio: 2);
  });
  final bytes = await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
  File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render every stage', (tester) async {
    await loadPoppins();
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2;
    tester.view.viewPadding = const FakeViewPadding(top: 118, bottom: 68);
    tester.view.padding = const FakeViewPadding(top: 118, bottom: 68);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        child: MediaQuery.fromView(view: tester.view, child: const EmberApp()),
      ),
    );
    await settle(tester);
    await shoot(tester, 'ask');

    await tester.tap(find.text('Get a question'));
    await settle(tester);
    await shoot(tester, 'reflect');

    await tester.tap(find.text('Shuffle'));
    await tester.pump(const Duration(milliseconds: 330));
    await shoot(tester, 'shuffle');
    await settle(tester);

    await tester.tap(find.text('Add to Journal'));
    await settle(tester, 32);
    await shoot(tester, 'flight');
    await settle(tester, 80);
    await shoot(tester, 'journal');

    await tester.tapAt(const Offset(326, 780));
    await settle(tester, 30);
    await shoot(tester, 'you');

    debugDisableShadows = true;
  });
}
