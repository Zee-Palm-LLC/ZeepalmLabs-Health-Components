import 'dart:io';
import 'dart:ui' as ui;

import 'package:care_circle/core/widgets.dart';
import 'package:care_circle/data/store.dart';
import 'package:care_circle/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

Future<void> precache(WidgetTester tester) async {
  final context = tester.element(find.byType(Scaffold).first);
  await tester.runAsync(() => Portrait.warm(context));
}

Future<void> snap(WidgetTester tester, GlobalKey key, String name) async {
  final dir = Platform.environment['SNAP_DIR'];
  if (dir == null) return;
  final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('snapshots', (tester) async {
    await loadFonts();
    final width = double.parse(Platform.environment['SNAP_W'] ?? '393');
    final height = double.parse(Platform.environment['SNAP_H'] ?? '852');
    tester.view.physicalSize = Size(width * 2, height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    CareStore.instance.reset();
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: const CareApp(simulateDevice: true)));
    await precache(tester);
    await settle(tester, 700);
    await snap(tester, key, 'welcome_mid');
    await settle(tester, 2000);
    await snap(tester, key, 'welcome');
    await tester.tap(find.text('Create your circle'));
    await settle(tester, 450);
    await snap(tester, key, 'hero_mid');
    await settle(tester, 2200);
    await snap(tester, key, 'home');
    await tester.tap(find.text('Timeline').last);
    await settle(tester, 150);
    await snap(tester, key, 'switch_mid');
    await settle(tester, 1200);
    await tester.tap(find.text('Meds').last);
    await settle(tester, 150);
    await snap(tester, key, 'switch_mid2');
    await settle(tester, 1200);
    await tester.tap(find.text('Home').last);
    await settle(tester, 800);
    await tester.tap(find.text('Grandpa Joe').first);
    await settle(tester, 2200);
    await snap(tester, key, 'member');
    await tester.tap(find.textContaining('Metformin 500mg', findRichText: true).first);
    await settle(tester, 1800);
    await snap(tester, key, 'sheet');
    await tester.ensureVisible(find.text('Mark as taken'));
    await settle(tester, 400);
    await tester.tap(find.text('Mark as taken'));
    await settle(tester, 1400);
    await snap(tester, key, 'sheet_taken');
  });
}
