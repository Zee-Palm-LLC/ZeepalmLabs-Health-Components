import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_chef/app.dart';
import 'package:pocket_chef/core/motion.dart';

import '../support.dart';
import 'reel_stage.dart';

const reelDir = String.fromEnvironment('REEL_DIR');
const reelFrames = int.fromEnvironment('REEL_FRAMES', defaultValue: 900);
const reelFrom = int.fromEnvironment('REEL_FROM');
const fps = 30;

sealed class Step {
  const Step(this.touch);

  final Touch touch;
}

class TapStep extends Step {
  TapStep(double at, Offset p) : super(Touch(start: at, end: at + 0.12, path: [p]));
}

class DragStep extends Step {
  DragStep(double from, double to, List<Offset> path) : super(Touch(start: from, end: to, path: path));
}

final steps = <Step>[
  TapStep(5.6, const Offset(197, 794)),
  DragStep(9.1, 10.5, const [Offset(292, 330), Offset(362, 296), Offset(226, 366), Offset(300, 330)]),
  TapStep(11.2, const Offset(106, 660)),
  DragStep(13.9, 14.7, const [Offset(200, 440), Offset(200, 470), Offset(200, 560)]),
  TapStep(15.3, const Offset(200, 721)),
  TapStep(15.9, const Offset(200, 758)),
  TapStep(16.9, const Offset(197, 829)),
  TapStep(18.6, const Offset(235, 825)),
  TapStep(19.8, const Offset(235, 825)),
  TapStep(20.9, const Offset(196, 210)),
  TapStep(21.6, const Offset(40.6, 87)),
  TapStep(22.6, const Offset(356.1, 626.9)),
  TapStep(23.3, const Offset(196.9, 825.8)),
  TapStep(23.95, const Offset(196.9, 825.8)),
  TapStep(24.9, const Offset(349.3, 831)),
  TapStep(27.2, const Offset(364.5, 83.5)),
];

const captions = [
  Caption(0.5, 5.4, 'MEET POCKETCHEF', 'A tiny chef', 'in your pocket'),
  Caption(6.0, 11.0, 'HOME', 'Fresh picks', 'every day'),
  Caption(11.6, 16.6, 'RECIPE', 'Cook it', 'step by step'),
  Caption(17.1, 21.3, 'COOK MODE', 'Your sous-chef', 'on call'),
  Caption(21.8, 24.5, 'SAVE & CREATE', 'Keep what', 'you love'),
  Caption(25.0, 27.8, 'PROFILE', 'Your kitchen,', 'your style'),
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
          child: ReelStage(
            time: time,
            touches: [for (final s in steps) s.touch],
            captions: captions,
            app: const PocketChefApp(),
          ),
        ),
      ),
    );
    await warm(tester);

    final live = <Step, TestGesture>{};
    final done = <Step>{};
    final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('reel')));
    final clock = Stopwatch()..start();

    for (var frame = 0; frame < reelFrames; frame++) {
      final t = frame / fps;
      final next = (frame + 1) / fps;
      for (final step in steps) {
        if (done.contains(step)) continue;
        final touch = step.touch;
        final gesture = live[step];
        if (gesture == null) {
          if (t >= touch.start) live[step] = await tester.startGesture(ReelStage.toStage(touch.path.first));
          continue;
        }
        if (step is DragStep) await gesture.moveTo(ReelStage.toStage(touch.at(t)));
        if (t >= touch.end) {
          await gesture.up();
          live.remove(step);
          done.add(step);
        }
      }
      time.value = t;
      await tester.pump(Duration(microseconds: ((next - t) * 1e6).round()));
      if (reelDir.isNotEmpty && frame >= reelFrom) {
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
