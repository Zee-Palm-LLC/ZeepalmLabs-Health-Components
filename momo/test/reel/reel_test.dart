import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:momo/app.dart';
import 'package:momo/chat/chat_screen.dart';
import 'package:momo/core/art.dart';
import 'package:momo/core/diary.dart';
import 'package:momo/core/motion.dart';

import '../support.dart';
import 'reel_stage.dart';

const reelDir = String.fromEnvironment('REEL_DIR');
const reelFrames = int.fromEnvironment('REEL_FRAMES', defaultValue: 900);
const reelFrom = int.fromEnvironment('REEL_FROM');
const reelEvery = int.fromEnvironment('REEL_EVERY', defaultValue: 1);
const fps = 30;

class Tap {
  Tap(this.at, this.point) : touch = Touch(start: at, end: at + 0.12, path: [point]);

  final double at;
  final Offset point;
  final Touch touch;
}

final taps = [
  Tap(2.5, const Offset(201, 289)),
  Tap(3.5, const Offset(201, 559)),
  Tap(4.5, const Offset(100, 629)),
  Tap(6.2, const Offset(262, 340)),
  Tap(7.1, const Offset(201, 758)),
  Tap(8.2, const Offset(300, 758)),
  Tap(12.0, const Offset(112.75, 565.4)),
  Tap(16.0, const Offset(105.75, 574.9)),
  Tap(17.7, const Offset(307.5, 302.7)),
  Tap(18.8, const Offset(107.1, 574)),
  Tap(20.0, const Offset(264.2, 302.8)),
  Tap(21.1, const Offset(362.3, 84)),
  Tap(22.0, const Offset(150, 768)),
  Tap(24.1, const Offset(359.5, 810.9)),
];

const question = 'how much protein';
const typeFrom = 22.35;
const typeTo = 23.75;

const captions = [
  Caption(0.5, 5.2, 'MEET MOMO', 'Your food diary', 'with a peach heart'),
  Caption(5.7, 10.4, 'SNAP', 'Point, shoot,', 'logged'),
  Caption(10.9, 15.4, 'COUNT', 'Calories in', 'one tap'),
  Caption(15.9, 21.3, 'MY DAY', 'Every meal,', 'every day'),
  Caption(21.8, 27.3, 'ASK', 'Ask anything', 'about your day'),
];

void main() {
  setUpAll(() async {
    await loadFonts();
    final nunito = FontLoader('Nunito')..addFont(Future.value(ByteData.sublistView(File('test/reel/fonts/Nunito-Variable.ttf').readAsBytesSync())));
    await nunito.load();
  });

  testWidgets('reel', (tester) async {
    tester.view.physicalSize = ReelStage.size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugDisableShadows = false;
    Clock.frozen = false;

    final time = ValueNotifier(0.0);
    final script = ChatScript();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: const ValueKey('reel'),
          child: ClockHost(
            child: ReelStage(
              time: time,
              touches: [for (final s in taps) s.touch],
              captions: captions,
              app: MomoApp(
                diary: Diary(now: DateTime(2026, 10, 4, 19, 30)),
                home: ChatScreen(script: script),
              ),
            ),
          ),
        ),
      ),
    );
    await warm(tester);
    final host = tester.element(find.byType(ChatScreen));
    await tester.runAsync(() async {
      for (final asset in Art.all) {
        await precacheImage(AssetImage(asset), host);
      }
    });
    await tester.pump();

    final live = <Tap, TestGesture>{};
    final done = <Tap>{};
    var typed = 0;
    final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('reel')));
    final clock = Stopwatch()..start();

    for (var frame = 0; frame < reelFrames; frame++) {
      final t = frame / fps;
      final next = (frame + 1) / fps;
      for (final tap in taps) {
        if (done.contains(tap)) continue;
        final gesture = live[tap];
        if (gesture == null) {
          if (t >= tap.touch.start) live[tap] = await tester.startGesture(ReelStage.toStage(tap.point));
          continue;
        }
        if (t >= tap.touch.end) {
          await gesture.up();
          live.remove(tap);
          done.add(tap);
        }
      }
      if (t >= typeFrom && typed < question.length) {
        final want = (((t - typeFrom) / (typeTo - typeFrom)) * question.length).ceil().clamp(1, question.length);
        if (want != typed) {
          typed = want;
          await tester.enterText(find.byType(TextField), question.substring(0, typed));
        }
      }
      time.value = t;
      await tester.pump(Duration(microseconds: ((next - t) * 1e6).round()));
      if (reelDir.isNotEmpty && frame >= reelFrom && frame % reelEvery == 0) {
        late ui.Image image;
        await tester.runAsync(() async {
          image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$reelDir/f${frame.toString().padLeft(4, '0')}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      if (frame % 60 == 0) debugPrint('frame $frame  ${clock.elapsed.inSeconds}s');
    }
    debugDisableShadows = true;
    expect(tester.takeException(), isNull);
  }, skip: reelDir.isEmpty);
}
