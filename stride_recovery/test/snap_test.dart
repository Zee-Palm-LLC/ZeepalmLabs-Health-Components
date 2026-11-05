// Renders frames of the splash → home timeline to build/snaps for review.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stride_recovery/home.dart';

void main() {
  testWidgets('snaps', (tester) async {
    final out = Directory('build/snaps')..createSync(recursive: true);
    HttpOverrides.global = null;
    debugDisableShadows = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('stride_fonts').path,
    );
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      final sdk = Platform.environment['FLUTTER_ROOT'] ?? 'C:/src/flutter';
      final bytes = File('$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf').readAsBytesSync();
      await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      for (final w in [FontWeight.w400, FontWeight.w500, FontWeight.w600, FontWeight.w700, FontWeight.w800]) {
        GoogleFonts.inter(fontWeight: w);
      }
      await GoogleFonts.pendingFonts();
    });

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(key: key, child: const FittedBox(child: StrideApp())),
    ));
    // Let the body image decode.
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(milliseconds: 1));
    }
    await tester.runAsync(() => precacheImage(const AssetImage('assets/images/avatar.png'), tester.element(find.byKey(key))));
    await tester.pump();

    final times = (Platform.environment['SNAP_T'] ?? '0.9,1.8,2.6,3.2,3.9,4.5,5.2,8').split(',').map(double.parse);
    var now = 0.0;
    for (final s in times) {
      while (now < s) {
        final step = (s - now).clamp(0, 1 / 30).toDouble();
        await tester.pump(Duration(microseconds: (step * 1e6).round()));
        now += step;
      }
      await tester.runAsync(() async {
        final b = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
        final img = await b.toImage(pixelRatio: 2);
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        File('${out.path}/t${s.toStringAsFixed(1)}.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
    await tester.pumpWidget(const SizedBox());
    debugDisableShadows = true;
  });
}
