import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const snapDir = String.fromEnvironment('SNAP_DIR');

Future<void> loadFonts() async {
  final loader = FontLoader('PlusJakartaSans')..addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans.ttf').readAsBytesSync())));
  await loader.load();
}

/// Sizes the test view. [hinge] adds a vertical hinge display feature, the
/// way an open book-style foldable reports it.
void device(WidgetTester tester, {required double width, required double height, double top = 0, double bottom = 0, Rect? hinge}) {
  debugDisableShadows = false;
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
  tester.view.viewPadding = FakeViewPadding(top: top, bottom: bottom);
  tester.view.displayFeatures = [
    if (hinge != null) ui.DisplayFeature(bounds: hinge, type: ui.DisplayFeatureType.hinge, state: ui.DisplayFeatureState.postureFlat),
  ];
  addTearDown(tester.view.reset);
}

void done(WidgetTester tester) {
  debugDisableShadows = true;
}

Future<void> run(WidgetTester tester, int frames, [int ms = 33]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

Future<void> shoot(WidgetTester tester, String name, {double ratio = 2}) async {
  if (snapDir.isEmpty) return;
  final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
  late ui.Image image;
  await tester.runAsync(() async {
    image = await boundary.toImage(pixelRatio: ratio);
  });
  final bytes = await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
  File('$snapDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}
