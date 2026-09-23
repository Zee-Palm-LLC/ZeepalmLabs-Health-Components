import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunara/app.dart';
import 'package:lunara/core/canvas.dart';
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

class Item {
  Item(this.text, this.rect, this.clipped);

  final String text;
  final Rect rect;
  final bool clipped;
}

List<Item> collect(WidgetTester tester) {
  final items = <Item>[];
  void visit(RenderObject node) {
    if (node is RenderParagraph) {
      final box = node;
      final offset = box.localToGlobal(Offset.zero);
      final text = box.text.toPlainText();
      if (text.trim().isNotEmpty) {
        items.add(Item(text, offset & box.size, box.didExceedMaxLines));
      }
    }
    node.visitChildren(visit);
  }

  visit(tester.binding.renderViewElement!.renderObject!);
  return items;
}

Rect canvasRect(WidgetTester tester) {
  final box = tester.renderObject<RenderBox>(find.byKey(canvasKey));
  return box.localToGlobal(Offset.zero) & box.size;
}

void main() {
  setUpAll(loadFonts);

  for (final size in const [Size(393, 852), Size(360, 640), Size(430, 932)]) {
    testWidgets('no clipped or escaping text at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const LunaraApp(simulateDevice: true));
      await settle(tester, 2400);

      final flow = tester.state<FlowState>(find.byType(LunaraFlow));
      final problems = <String>[];

      Future<void> check(String screen) async {
        await settle(tester, 2400);
        final bounds = canvasRect(tester);
        for (final item in collect(tester)) {
          final label = item.text.replaceAll('\n', ' ');
          if (item.clipped) problems.add('$screen: clipped text "$label"');
          if (item.rect.left < bounds.left - 0.6 ||
              item.rect.right > bounds.right + 0.6 ||
              item.rect.top < bounds.top - 0.6 ||
              item.rect.bottom > bounds.bottom + 0.6) {
            problems.add('$screen: "$label" escapes the canvas (${item.rect} vs $bounds)');
          }
        }
      }

      await check('welcome');
      flow.begin();
      await check('home');
      for (final (tab, name) in [(1, 'log'), (2, 'insights'), (3, 'you')]) {
        flow.openTab(tab);
        await check(name);
      }

      expect(problems, isEmpty, reason: problems.join('\n'));
      expect(tester.takeException(), isNull);
    });
  }
}
