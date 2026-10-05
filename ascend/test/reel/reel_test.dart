import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/app.dart';
import 'package:ascend/core/glyphs.dart';
import 'package:ascend/core/motion.dart';
import 'package:ascend/onboarding/onboarding.dart';

import '../support.dart';
import 'reel_stage.dart';

const reelDir = String.fromEnvironment('REEL_DIR');
const reelFrames = int.fromEnvironment('REEL_FRAMES', defaultValue: 900);
const reelFrom = int.fromEnvironment('REEL_FROM');
const reelEvery = int.fromEnvironment('REEL_EVERY', defaultValue: 1);
const fps = 30;

const continueAt = Offset(201.3, 798.8);
const backAt = Offset(56, 104.5);
const googleAt = Offset(202.5, 766);

class Tap {
  Tap(this.at, this.point) : touch = Touch(start: at, end: at + 0.12, path: [point]);

  final double at;
  final Offset point;
  final Touch touch;
}

final taps = [
  Tap(5.6, continueAt),
  Tap(11.4, continueAt),
  Tap(15.4, googleAt),
  Tap(18.1, backAt),
  Tap(20.7, backAt),
  Tap(23.5, continueAt),
  Tap(25.6, continueAt),
];

const captions = [
  Caption(0.5, 5.2, 'MEET ASCEND', 'Level up', 'every habit'),
  Caption(5.9, 10.9, 'STREAKS', 'Keep the', 'chain alive'),
  Caption(11.7, 17.5, 'LEADERBOARD', 'Rise with', 'your crew'),
  Caption(18.2, 22.9, 'MOTION', 'Every screen', 'comes alive'),
  Caption(23.6, 27.3, 'GET STARTED', 'Your climb', 'starts now'),
];

void main() {
  setUpAll(loadFonts);

  testWidgets('reel', (tester) async {
    tester.view.physicalSize = ReelStage.size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugDisableShadows = false;
    Clock.frozen = false;

    final time = ValueNotifier(0.0);
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
              app: AscendApp(home: Onboarding(script: OnboardingScript())),
            ),
          ),
        ),
      ),
    );
    await warm(tester);
    final host = tester.element(find.byType(Onboarding));
    await tester.runAsync(() async {
      for (final asset in Art.all) {
        await precacheImage(AssetImage(asset), host);
      }
    });
    await tester.pump();

    final live = <Tap, TestGesture>{};
    final done = <Tap>{};
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
