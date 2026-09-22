import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocturne/app.dart';
import 'package:nocturne/features/shell/shell.dart';
import 'package:nocturne/scene/clock.dart';
import 'package:nocturne/sound/engine.dart';
import 'package:nocturne/sound/mixer.dart';
import 'package:nocturne/sound/sounds.dart';

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

void main() {
  for (final size in const [
    Size(360, 640),
    Size(360, 740),
    Size(393, 852),
    Size(412, 915),
    Size(430, 932),
  ]) {
    testWidgets('full flow at ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await loadFonts();
      await tester.runAsync(Shaders.load);
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.view.padding = FakeViewPadding(
        top: size.height > 700 ? 162 : 60,
        bottom: size.height > 700 ? 102 : 0,
      );
      addTearDown(tester.view.reset);
      final engine = SilentEngine();
      final mixer = Mixer(engine: engine);
      await tester.pumpWidget(NocturneApp(mixer: mixer));
      await settle(tester, 2800);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Begin Your Journey'));
      await settle(tester, 2400);
      expect(find.byType(Shell), findsOneWidget);

      await tester.tap(find.text('Nature'));
      await settle(tester, 700);
      expect(find.text('Fire'), findsOneWidget);
      await tester.tap(find.text('All'));
      await settle(tester, 700);

      await tester.enterText(find.byType(TextField), 'stor');
      await settle(tester, 700);
      await tester.enterText(find.byType(TextField), '');
      await settle(tester, 700);

      await tester.tap(find.text('Rain').first);
      await settle(tester, 400);
      expect(mixer.contains(Sound.rain), isFalse);
      await tester.tap(find.text('Rain').first);
      await settle(tester, 400);
      expect(mixer.contains(Sound.rain), isTrue);
      await settle(tester, 2600);

      tester.state<ShellState>(find.byType(Shell)).openMix();
      await settle(tester, 4000);
      expect(mixer.playing, isTrue);
      expect(engine.levels[Sound.rain]! > 0, isTrue);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Fire').last);
      await settle(tester, 600);
      expect(find.textContaining('Fire  ·'), findsOneWidget);
      await tester.tap(find.text('Reset'));
      await settle(tester, 1500);

      mixer.remove(Sound.wind);
      await settle(tester, 900);
      await tester.tap(find.text('Add'));
      await settle(tester, 900);
      await tester.tap(find.text('Forest').last);
      await settle(tester, 1200);
      expect(mixer.contains(Sound.forest), isTrue);

      await tester.tap(find.text('Timer'));
      await settle(tester, 900);
      await tester.tap(find.text('45'));
      await settle(tester, 900);
      expect(mixer.timer, const Duration(minutes: 45));
      await settle(tester, 2600);

      await tester.tap(find.text('Save Mix'));
      await settle(tester, 600);
      expect(mixer.liked, isTrue);
      await settle(tester, 2600);

      await tester.tap(find.text('Ambient'));
      await settle(tester, 2600);
      expect(tester.takeException(), isNull);
      expect(find.text('You’re Almost\nThere'), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              w.painter.runtimeType.toString() == 'GlyphPainter' &&
              (w.painter as dynamic).g.toString() == 'G.pause',
        ),
      );
      await settle(tester, 400);
      expect(mixer.playing, isFalse);

      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              w.painter.runtimeType.toString() == 'GlyphPainter' &&
              (w.painter as dynamic).g.toString() == 'G.sliders',
        ),
      );
      await settle(tester, 900);
      expect(find.text('Your blend'), findsOneWidget);
      await tester.tapAt(const Offset(20, 40));
      await settle(tester, 900);

      await tester.tap(
        find
            .byWidgetPredicate(
              (w) =>
                  w is CustomPaint &&
                  w.painter.runtimeType.toString() == 'GlyphPainter' &&
                  (w.painter as dynamic).g.toString() == 'G.moonFill',
            )
            .last,
      );
      await settle(tester, 1600);
      expect(find.text('Tap to wake'), findsOneWidget);
      await tester.tapAt(Offset(size.width / 2, size.height / 2));
      await settle(tester, 1600);

      final close = find.byWidgetPredicate(
        (w) =>
            w is CustomPaint &&
            w.painter.runtimeType.toString() == 'GlyphPainter' &&
            (w.painter as dynamic).g.toString() == 'G.chevronDown',
      );
      expect(close, findsOneWidget);
      await tester.tap(close);
      await settle(tester, 1500);
      expect(find.text('Blending Your Peace'), findsOneWidget);
      await tester.tap(find.text('Ambient'));
      await settle(tester, 1600);
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.pop();
      await settle(tester, 1500);
      nav.pop();
      await settle(tester, 1500);

      tester.state<ShellState>(find.byType(Shell)).select(Section.library);
      await settle(tester, 1600);
      expect(find.text('Midnight Forest'), findsOneWidget);
      await tester.tap(find.text('Midnight Forest'));
      await settle(tester, 3000);
      expect(mixer.name, 'Midnight Forest');
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await settle(tester, 300);
    });
  }
}
