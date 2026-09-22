import 'dart:io';
import 'dart:ui' as ui;

import 'package:clinic_queue/app.dart';
import 'package:clinic_queue/main.dart';
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
    debugDisableShadows = false;
    final width = double.parse(Platform.environment['SNAP_W'] ?? '393');
    final height = double.parse(Platform.environment['SNAP_H'] ?? '852');
    final android = Platform.environment['SNAP_ANDROID'] == '1';
    tester.view.physicalSize = Size(width * 2, height * 2);
    tester.view.devicePixelRatio = 2;
    if (android) {
      tester.view.padding = const FakeViewPadding(top: 48, bottom: 96);
      tester.view.viewPadding = const FakeViewPadding(top: 48, bottom: 96);
    }
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: QueueApp(simulateDevice: !android),
      ),
    );
    await tester.runAsync(
      () => precacheImage(const AssetImage('assets/images/wave.png'), tester.element(find.byType(Scaffold).first)),
    );
    await settle(tester, 1600);
    await snap(tester, key, 's0');
    final flow = tester.state<FlowState>(find.byType(QueueFlow));
    flow.open(Sheet.token);
    await settle(tester, 700);
    await snap(tester, key, 'sheet_token');
    await tester.tap(find.text('Confirm token'));
    await settle(tester, 1100);
    await snap(tester, key, 'sheet_print');
    await settle(tester, 2200);
    await snap(tester, key, 's1');
    await settle(tester, 16000);
    await snap(tester, key, 'q_almost');
    await tester.tap(find.text('Almost your turn · plan route'));
    await settle(tester, 1600);
    await snap(tester, key, 's2');
    flow.open(Sheet.swap);
    await settle(tester, 700);
    await snap(tester, key, 'sheet_swap');
    flow.close();
    await settle(tester, 500);
    flow.open(Sheet.visit);
    await settle(tester, 700);
    await snap(tester, key, 'sheet_visit');
    flow.close();
    await settle(tester, 500);
    await tester.tap(find.text("I'm on my way"));
    await settle(tester, 2500);
    await snap(tester, key, 's2_trip');
    await settle(tester, 4000);
    await snap(tester, key, 's3');
    await tester.tap(find.text("I'm here"));
    await settle(tester, 2400);
    await snap(tester, key, 's0_done');
    flow.go(FlowState.profile);
    await settle(tester, 1600);
    await snap(tester, key, 's4');
    debugDisableShadows = true;
  });
}
