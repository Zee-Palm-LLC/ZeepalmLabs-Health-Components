import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunara/app.dart';
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

Future<void> snap(WidgetTester tester, GlobalKey key, String name) async {
  final dir = Platform.environment['SNAP_DIR'];
  if (dir == null) return;
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(dir).createSync(recursive: true);
    File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(loadFonts);

  testWidgets('screens', (tester) async {
    debugDisableShadows = false;
    final width = double.parse(Platform.environment['SNAP_W'] ?? '393');
    final height = double.parse(Platform.environment['SNAP_H'] ?? '852');
    final android = Platform.environment['SNAP_ANDROID'] == '1';
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    if (android) {
      tester.view.padding = const FakeViewPadding(top: 48 * 3, bottom: 96 * 3);
      tester.view.viewPadding = const FakeViewPadding(top: 48 * 3, bottom: 96 * 3);
    }
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: LunaraApp(simulateDevice: !android),
      ),
    );
    await settle(tester, 2600);
    await snap(tester, key, 's0');
    final flow = tester.state<FlowState>(find.byType(LunaraFlow));
    flow.begin();
    for (final (i, frame) in [400, 700, 1000, 1400].indexed) {
      await settle(tester, i == 0 ? frame : frame - [400, 700, 1000, 1400][i - 1]);
      await snap(tester, key, 'morph$i');
    }
    await settle(tester, 2600);
    await snap(tester, key, 's1');
    for (final tab in [1, 2, 3]) {
      flow.openTab(tab);
      await settle(tester, 2600);
      await snap(tester, key, 's${tab + 1}');
    }
    if (Platform.environment['SNAP_SAVE'] == '1') {
      flow.openTab(1);
      await settle(tester, 2600);
      await snap(tester, key, 'log0');
      await tester.tap(find.text('Save day'));
      for (final (i, ms) in [300, 500, 700, 900].indexed) {
        await settle(tester, i == 0 ? ms : ms - [300, 500, 700, 900][i - 1]);
        await snap(tester, key, 'save$i');
      }
      await settle(tester, 1400);
    }
    expect(flow.mounted, isTrue);
    expect(tester.takeException(), isNull);
    debugDisableShadows = true;
  });
}
