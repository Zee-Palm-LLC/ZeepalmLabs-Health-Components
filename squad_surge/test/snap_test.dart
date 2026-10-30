// Plays the level with scripted steering and writes frames to build/snaps.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:squad_surge/game/surge_game.dart';
import 'package:squad_surge/ui/hud.dart';

void main() {
  testWidgets('snaps', (tester) async {
    final out = Directory('build/snaps')..createSync(recursive: true);
    HttpOverrides.global = null;
    debugDisableShadows = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('surge_fonts').path,
    );
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      Future<void> font(String family, String path) async {
        final f = File(path);
        if (f.existsSync()) await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())))).load();
      }

      final sdk = Platform.environment['FLUTTER_ROOT'] ?? 'C:/src/flutter';
      await font('MaterialIcons', '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
      await font('Segoe UI Emoji', 'C:/Windows/Fonts/seguiemj.ttf');
      GoogleFonts.lilitaOne();
      await GoogleFonts.pendingFonts();
    });

    final game = SurgeGame();
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: key,
          child: FittedBox(child: SurgeScreen(game: game)),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 16));
    }

    Future<void> shot(String name) async {
      await tester.runAsync(() async {
        final b = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
        final img = await b.toImage(pixelRatio: 2);
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        File('${out.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    await tester.pump(const Duration(milliseconds: 500));
    await shot('a_start');
    game.start();
    final times = (Platform.environment['SNAP_T'] ?? '1.2,3.0,5.6,8.4,10.6,13.8,16,19,21').split(',').map(double.parse).toList();
    var i = 0;
    while (i < times.length) {
      // Autopilot: take the better gate side.
      final t = game.t;
      game.targetX = t < 2.0
          ? -0.6
          : t < 5.4
          ? -0.5
          : t < 7.5
          ? 0
          : 0.55;
      await tester.pump(const Duration(microseconds: 16667));
      if (game.t >= times[i] || game.phase == Phase.lost) {
        await shot('t${times[i].toStringAsFixed(1)}');
        stdout.writeln('t=${game.t.toStringAsFixed(1)} count=${game.count} phase=${game.phase} boss=${game.bossHealth}');
        i++;
      }
      if (game.clock > 40 || game.phase == Phase.won) break;
    }
    if (game.phase == Phase.won) {
      await tester.pump(const Duration(milliseconds: 300));
      await shot('win_blast');
      for (var k = 0; k < 150; k++) {
        await tester.pump(const Duration(microseconds: 16667));
      }
      await shot('win_card');
    }
    File('${out.path}/log.txt').writeAsStringSync('${game.phase} count=${game.count} t=${game.t}');
    await tester.pumpWidget(const SizedBox());
    debugDisableShadows = true;
  });
}
