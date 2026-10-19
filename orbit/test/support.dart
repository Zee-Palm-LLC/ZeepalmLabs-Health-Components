import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/widgets/model3d.dart';

const snapDir = String.fromEnvironment('SNAP_DIR');

Future<void> loadFonts() async {
  Model3D.enabled = false;
  Future<void> load(String family, String file) async {
    final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync())));
    await loader.load();
  }

  await load('Baloo', 'Baloo2-Variable.ttf');
  await load('PhosphorFill', 'Phosphor-Fill.ttf');
  await load('PhosphorBold', 'Phosphor-Bold.ttf');
}

void phone(WidgetTester tester, {double width = 402, double height = 874, double top = 62, double bottom = 34}) {
  debugDisableShadows = false;
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
  tester.view.viewPadding = FakeViewPadding(top: top, bottom: bottom);
  addTearDown(tester.view.reset);
}

void done(WidgetTester tester) {
  debugDisableShadows = true;
}

Future<void> warm(WidgetTester tester) async {
  final files = [...Directory('assets/art').listSync(), ...Directory('assets/plates').listSync()].whereType<File>();
  await tester.runAsync(() async {
    for (final f in files) {
      final folder = f.parent.uri.pathSegments.where((e) => e.isNotEmpty).last;
      final data = await rootBundle.load('assets/$folder/${f.uri.pathSegments.last}');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      await codec.getNextFrame();
    }
  });
  for (final el in find.byType(Image).evaluate()) {
    final w = el.widget as Image;
    await tester.runAsync(() => precacheImage(w.image, el));
  }
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump();
  }
}

Future<void> run(WidgetTester tester, int frames, [int ms = 33]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

Future<void> shoot(WidgetTester tester, String name, {double ratio = 3, bool settle = true}) async {
  if (snapDir.isEmpty) return;
  if (settle) await warm(tester);
  final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
  late ui.Image image;
  await tester.runAsync(() async {
    image = await boundary.toImage(pixelRatio: ratio);
  });
  final bytes = await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
  File('$snapDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}
