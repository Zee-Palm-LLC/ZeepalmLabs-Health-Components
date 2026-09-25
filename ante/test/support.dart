import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ante/app.dart';

const snapDir = String.fromEnvironment('SNAP_DIR');

Future<void> loadFonts() async {
  Future<void> load(String family, String file) async {
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync())));
    await loader.load();
  }

  await load('Inter', 'Inter-Variable.ttf');
  await load('PhosphorRegular', 'Phosphor-Regular.ttf');
  await load('PhosphorBold', 'Phosphor-Bold.ttf');
  await load('PhosphorFill', 'Phosphor-Fill.ttf');
  await load('PhosphorLight', 'Phosphor-Light.ttf');
}

void phone(WidgetTester tester, {double height = 917, double top = 50, double bottom = 22, double width = 393}) {
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
  final dir = Directory('assets/art');
  await tester.runAsync(() async {
    for (final f in dir.listSync().whereType<File>()) {
      final key = 'assets/art/${f.uri.pathSegments.last}';
      final data = await rootBundle.load(key);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      await codec.getNextFrame();
    }
  });
  for (final el in find.byType(Image).evaluate()) {
    final w = el.widget as Image;
    await tester.runAsync(() => precacheImage(w.image, el));
  }
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await tester.pump();
  }
}

Future<void> run(WidgetTester tester, int frames, [int ms = 34]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

class AnteAppHost extends StatelessWidget {
  const AnteAppHost({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) => AnteApp(home: home);
}

Future<void> mount(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(RepaintBoundary(key: const ValueKey('shot'), child: AnteApp(home: home)));
  await warm(tester);
}

Future<void> shoot(WidgetTester tester, String name, {double ratio = 3}) async {
  if (snapDir.isEmpty) return;
  await warm(tester);
  final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
  late ui.Image image;
  await tester.runAsync(() async {
    image = await boundary.toImage(pixelRatio: ratio);
  });
  final bytes = await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
  File('$snapDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}
