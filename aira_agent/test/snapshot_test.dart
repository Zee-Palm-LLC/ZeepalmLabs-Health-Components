import 'dart:io';
import 'dart:ui' as ui;

import 'package:aira_agent/main.dart';
import 'package:aira_agent/scene/orb.dart';
import 'package:aira_agent/scene/stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Inter')
    ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Inter-Variable.ttf').readAsBytesSync())));
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
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('snapshots', (tester) async {
    await loadFonts();
    await tester.runAsync(OrbShader.load);
    final width = double.parse(Platform.environment['SNAP_W'] ?? '393');
    final height = double.parse(Platform.environment['SNAP_H'] ?? '852');
    tester.view.physicalSize = Size(width * 2, height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: const AiraApp(simulateDevice: true)));
    for (var i = 1; i <= 4; i++) {
      await settle(tester, 350);
      await snap(tester, key, 'intro_$i');
    }
    await settle(tester, 1200);
    await snap(tester, key, 'home');
    final stage = tester.state<StageState>(find.byType(Stage));
    stage.go(Scene.voice);
    for (var i = 1; i <= 4; i++) {
      await settle(tester, 250);
      await snap(tester, key, 'h2v_$i');
    }
    await settle(tester, 3200);
    await snap(tester, key, 'voice');
    stage.director.sendVoice();
    for (var i = 1; i <= 5; i++) {
      await settle(tester, 250);
      await snap(tester, key, 'v2c_$i');
    }
    await settle(tester, 9000);
    await snap(tester, key, 'chat');
    stage.go(Scene.home);
    for (var i = 1; i <= 3; i++) {
      await settle(tester, 250);
      await snap(tester, key, 'c2h_$i');
    }
    await settle(tester, 1500);
    await tester.tap(find.text('Opus 4.8'));
    await settle(tester, 700);
    await snap(tester, key, 'pop_model');
    await tester.tapAt(const Offset(200, 300));
    await settle(tester, 500);
    await tester.tapAt(Offset(width - 83, 96));
    await settle(tester, 700);
    await snap(tester, key, 'pop_alerts');
    await tester.tapAt(const Offset(200, 300));
    await settle(tester, 500);
  });
}
