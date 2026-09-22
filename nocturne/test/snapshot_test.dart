import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocturne/app.dart';
import 'package:nocturne/features/shell/shell.dart';
import 'package:nocturne/features/welcome/welcome_screen.dart';
import 'package:nocturne/scene/clock.dart';
import 'package:nocturne/sound/mixer.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Poppins');
  for (final weight in ['Light', 'Regular', 'Medium', 'SemiBold']) {
    final bytes = File('assets/fonts/Poppins-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
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
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> precache(WidgetTester tester, GlobalKey key) async {
  await tester.runAsync(() async {
    final ctx = key.currentContext!;
    for (final a in [
      'assets/images/welcome_night.jpg',
      'assets/images/sleep_lake.jpg',
    ]) {
      await precacheImage(AssetImage(a), ctx);
    }
  });
}

void main() {
  testWidgets('snapshots', (tester) async {
    await loadFonts();
    await tester.runAsync(Shaders.load);
    final width = double.parse(Platform.environment['SNAP_W'] ?? '393');
    final height = double.parse(Platform.environment['SNAP_H'] ?? '852');
    tester.view.physicalSize = Size(width * 2, height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: NocturneApp(mixer: Mixer(), simulateDevice: true),
      ),
    );
    await precache(tester, key);
    await settle(tester, 3000);
    await snap(tester, key, 'welcome');
    await tester.tap(find.text('Begin Your Journey'));
    await settle(tester, 2600);
    await snap(tester, key, 'home');
    expect(tester.takeException(), isNull);
    final shell = tester.state<ShellState>(find.byType(Shell));
    shell.openMix();
    for (var i = 1; i <= 3; i++) {
      await settle(tester, 300);
      await snap(tester, key, 'h2m_$i');
    }
    await settle(tester, 4500);
    await snap(tester, key, 'mix');
    await tester.tap(find.text('Ambient'));
    for (var i = 1; i <= 3; i++) {
      await settle(tester, 300);
      await snap(tester, key, 'm2s_$i');
    }
    await settle(tester, 2500);
    await snap(tester, key, 'sleep');
    expect(tester.takeException(), isNull);
    expect(find.byType(WelcomeScreen), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await settle(tester, 200);
  });
}
