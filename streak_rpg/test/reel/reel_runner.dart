import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:streak_rpg/app.dart';
import 'package:streak_rpg/home/shell.dart';

import '../support.dart';
import 'reel_stage.dart';

/// Renders the social reels frame by frame.
///
/// `flutter test test/reel -j 2 --dart-define=REEL_DIR=frames_dir` renders both
/// reels in parallel, into `frames_dir/app` and `frames_dir/tutorial`.
///
/// REEL_EVERY=n renders every n-th frame for a quick preview.
const reelDir = String.fromEnvironment('REEL_DIR');
const reelEvery = int.fromEnvironment('REEL_EVERY', defaultValue: 1);
const fps = 30;

/// App-space points on the 402 x 874 phone (top inset 62, bottom 34).
const getStarted = Offset(204, 750);
const next = Offset(201.5, 781.8);
const gift = Offset(355.7, 627.2);
const startWorkout = Offset(202, 714.2);
const completeSet = Offset(158, 739);
const back = Offset(34, 82);
const questsTab = Offset(153.75, 800);
const waterQuest = Offset(200, 451);

class Tap {
  const Tap(this.at, this.point, {this.text});

  final double at;
  final Offset point;

  /// When set, the tap lands on the live widget with this text instead.
  final String? text;
}

class Script {
  const Script({required this.length, required this.outroAt, required this.taps, required this.captions, required this.lockup, required this.app, this.shots = const []});

  final List<Shot> shots;

  final double length;
  final double outroAt;
  final List<Tap> taps;
  final List<Caption> captions;
  final Lockup lockup;
  final Widget app;
}

final scripts = {
  'app': const Script(
    length: 32,
    outroAt: 28.6,
    app: StreakApp(tutorials: false),
    taps: [
      Tap(3.6, getStarted),
      Tap(8.4, next),
      Tap(12.9, gift),
      Tap(14.6, startWorkout),
      Tap(20.6, completeSet),
      Tap(23.4, back),
      Tap(24.4, questsTab),
      Tap(26.4, waterQuest),
    ],
    captions: [
      Caption(0.4, 3.4, 'MEET STREAK RPG', 'Train like', 'a legend'),
      Caption(3.9, 8.2, 'LEVEL UP', 'Every rep', 'earns XP'),
      Caption(9.6, 14.3, 'YOUR WORLD', 'A hero that', 'grows with you'),
      Caption(15.0, 23.0, 'WORKOUTS', 'Real reps.', 'Real loot.'),
      Caption(23.6, 28.2, 'DAILY QUESTS', 'Small steps,', 'big rewards'),
    ],
    lockup: Lockup(tagline: 'Train. Level Up. Explore.', sub: 'Turn every workout into an adventure'),
    shots: [
      Shot(0, 1, 437),
      Shot(12.3, 1, 437),
      Shot(12.8, 1.38, 560),
      Shot(14.2, 1.38, 560),
      Shot(14.7, 1, 437),
      Shot(19.9, 1, 437),
      Shot(20.4, 1.3, 640),
      Shot(22.6, 1.3, 640),
      Shot(23.1, 1, 437),
      Shot(25.7, 1, 437),
      Shot(26.2, 1.32, 430),
      Shot(28.0, 1.32, 430),
      Shot(28.5, 1, 437),
    ],
  ),
  'tutorial': const Script(
    length: 34.5,
    outroAt: 31.3,
    app: StreakApp(home: Shell()),
    taps: [
      Tap(7.0, Offset.zero, text: 'Next'),
      Tap(9.2, Offset.zero, text: 'Next'),
      Tap(11.4, Offset.zero, text: 'Next'),
      Tap(13.4, Offset.zero, text: 'Next'),
      Tap(15.4, Offset.zero, text: 'Next'),
      Tap(17.6, gift),
      Tap(20.1, Offset.zero, text: 'Next'),
      Tap(22.3, startWorkout),
      Tap(29.8, Offset.zero, text: 'Next'),
    ],
    captions: [
      Caption(0.4, 4.4, 'GUIDED TUTORIAL', 'Learn it by', 'playing it'),
      Caption(4.8, 11.0, 'COACH KAI', 'Spotlights', 'every feature'),
      Caption(11.4, 16.8, 'GAME-STYLE HUD', 'Stats, streaks', '& hero status'),
      Caption(17.2, 22.0, 'TRY IT LIVE', 'Tap the real', 'thing'),
      Caption(22.4, 26.6, 'CHAPTER CLEAR', 'Rewards for', 'learning'),
      Caption(26.9, 30.9, 'EVERY AREA', 'Arena, quests', '& more'),
    ],
    lockup: Lockup(tagline: 'Learn it by playing it.', sub: 'Tutorials that feel like a game'),
    // Follow Coach Kai's spotlight so the dialog stays readable.
    shots: [
      Shot(0, 1, 437),
      Shot(4.3, 1, 437),
      Shot(5.0, 1.45, 190),
      Shot(9.2, 1.45, 190),
      Shot(9.7, 1.45, 230),
      Shot(11.4, 1.45, 230),
      Shot(11.9, 1.4, 470),
      Shot(15.4, 1.4, 470),
      Shot(15.9, 1.4, 560),
      Shot(17.8, 1.4, 560),
      Shot(18.3, 1.35, 690),
      Shot(22.4, 1.35, 690),
      Shot(22.9, 1, 437),
      Shot(27.3, 1, 437),
      Shot(27.9, 1.4, 250),
      Shot(29.8, 1.4, 250),
      Shot(30.3, 1.35, 420),
      Shot(31.0, 1.35, 420),
      Shot(31.3, 1, 437),
    ],
  ),
};

/// Renders reel [name] into `REEL_DIR/name`.
void reelTest(String name) {
  setUpAll(loadFonts);

  testWidgets('reel $name', (tester) async {
    final script = scripts[name]!;
    final out = Directory('$reelDir/$name')..createSync(recursive: true);
    tester.view.physicalSize = ReelStage.size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugDisableShadows = false;

    final time = ValueNotifier(0.0);
    final touches = <Touch>[];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: const ValueKey('reel'),
          child: ReelStage(time: time, touches: touches, captions: script.captions, app: script.app, outroAt: script.outroAt, lockup: script.lockup, shots: script.shots),
        ),
      ),
    );
    await warm(tester);

    final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('reel')));
    final frames = (script.length * fps).round();
    final pending = [...script.taps];
    final live = <TestGesture, double>{};
    final clock = Stopwatch()..start();

    for (var frame = 0; frame < frames; frame++) {
      final t = frame / fps;
      while (pending.isNotEmpty && t >= pending.first.at) {
        final tap = pending.removeAt(0);
        // Map through the live render tree so camera zooms are accounted for.
        final appBox = tester.renderObject<RenderBox>(find.byType(StreakApp));
        var point = tap.point;
        if (tap.text != null) {
          final f = find.text(tap.text!);
          if (f.evaluate().isEmpty) continue;
          point = appBox.globalToLocal(tester.getCenter(f.last));
        }
        touches.add(Touch(start: t, end: t + 0.12, at: point));
        live[await tester.startGesture(appBox.localToGlobal(point))] = t + 0.12;
      }
      for (final g in [...live.keys]) {
        if (t >= live[g]!) {
          await g.up();
          live.remove(g);
        }
      }
      time.value = t;
      await tester.pump(const Duration(microseconds: 1000000 ~/ fps));
      if (reelDir.isNotEmpty && frame % reelEvery == 0) {
        late ui.Image image;
        await tester.runAsync(() async {
          image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${out.path}/f${frame.toString().padLeft(4, '0')}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      if (frame % 90 == 0) debugPrint('frame $frame/$frames  ${clock.elapsed.inSeconds}s');
    }
    debugDisableShadows = true;
    expect(tester.takeException(), isNull);
  }, skip: reelDir.isEmpty, timeout: Timeout.none);
}
