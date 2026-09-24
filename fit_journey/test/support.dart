import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const snapDir = String.fromEnvironment('SNAP_DIR');

Future<void> loadFonts() async {
  final loader = FontLoader('Figtree');
  for (final name in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Figtree-$name.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
  for (final style in ['Fill', 'Regular', 'Bold', 'Duotone']) {
    final phosphor = FontLoader('Phosphor$style');
    phosphor.addFont(Future.value(ByteData.sublistView(File('assets/fonts/Phosphor-$style.ttf').readAsBytesSync())));
    await phosphor.load();
  }
  final icons = FontLoader('MaterialIcons');
  final root = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final candidates = [
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ];
  for (final path in candidates) {
    final file = File(path);
    if (file.existsSync()) {
      icons.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      await icons.load();
      break;
    }
  }
}

void usePhone(WidgetTester tester, {Size size = const Size(393, 852), double top = 59, double bottom = 34}) {
  const ratio = 3.0;
  tester.view.physicalSize = size * ratio;
  tester.view.devicePixelRatio = ratio;
  tester.view.padding = FakeViewPadding(top: top * ratio, bottom: bottom * ratio);
  tester.view.viewPadding = FakeViewPadding(top: top * ratio, bottom: bottom * ratio);
  addTearDown(tester.view.reset);
}

Future<void> precache(WidgetTester tester, List<String> assets) async {
  final element = tester.element(find.byType(RepaintBoundary).first);
  await tester.runAsync(() async {
    for (final a in assets) {
      await precacheImage(AssetImage(a), element);
    }
  });
}

Future<void> step(WidgetTester tester, int ms, [int frame = 16]) async {
  var left = ms;
  while (left > 0) {
    final d = left < frame ? left : frame;
    await tester.pump(Duration(milliseconds: d));
    left -= d;
  }
}

Future<void> shoot(WidgetTester tester, String name, {double ratio = 1}) async {
  if (snapDir.isEmpty) return;
  final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('stage')));
  late ui.Image image;
  await tester.runAsync(() async {
    image = await boundary.toImage(pixelRatio: ratio);
  });
  final bytes = await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
  File('$snapDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

Widget stage(Widget child) {
  return RepaintBoundary(key: const ValueKey('stage'), child: child);
}
