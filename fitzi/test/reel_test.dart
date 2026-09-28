import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitzi/features/onboarding/onboarding_screen.dart';

import 'support.dart';

const reelDir = String.fromEnvironment('REEL_DIR');

void main() {
  setUpAll(loadFonts);

  testWidgets('reel', (tester) async {
    if (reelDir.isEmpty) return;
    phone(tester, width: 393, height: 852, top: 59, bottom: 34);
    await mount(tester, const OnboardingScreen());

    var frame = 0;
    final taps = <Map<String, Object>>[];
    final marks = <Map<String, Object>>[];
    const step = Duration(microseconds: 33333);

    Future<void> capture() async {
      final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
      late ui.Image image;
      await tester.runAsync(() async {
        image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$reelDir/f${frame.toString().padLeft(4, '0')}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      frame++;
    }

    Future<void> play(double seconds) async {
      final n = (seconds * 30).round();
      for (var i = 0; i < n; i++) {
        await tester.pump(step);
        await capture();
      }
    }

    void mark(String label) => marks.add({'frame': frame, 'label': label});

    Future<void> tap(double x, double y, {double hold = 0.12}) async {
      taps.add({'frame': frame, 'x': x, 'y': y});
      final g = await tester.startGesture(Offset(x, y));
      await play(hold);
      await g.up();
    }

    Future<void> drag(List<Offset> path, double seconds) async {
      final g = await tester.startGesture(path.first);
      final n = (seconds * 30).round();
      taps.add({
        'frame': frame,
        'x': path.first.dx,
        'y': path.first.dy,
        'path': [for (final p in path) [p.dx, p.dy]],
        'frames': n,
      });
      for (var i = 1; i <= n; i++) {
        final t = i / n * (path.length - 1);
        final k = t.floor().clamp(0, path.length - 2);
        final p = Offset.lerp(path[k], path[k + 1], t - k)!;
        await g.moveTo(p);
        await tester.pump(step);
        await capture();
      }
      await g.up();
    }

    mark('Meet Fitzi');
    await play(3.2);
    mark('Drag for parallax');
    await drag(const [Offset(200, 420), Offset(120, 380), Offset(290, 470), Offset(210, 430)], 1.3);
    await play(0.3);
    mark('Tap the mascot');
    await tap(215, 480);
    await play(0.9);
    mark('Liquid launch');
    await tap(197, 729);
    await play(2.3);
    mark('Home');
    await play(1.2);
    await tap(299.7, 86.5);
    await play(0.6);
    await tap(55.5, 394);
    await play(0.5);
    await drag(const [Offset(200, 640), Offset(200, 560)], 0.35);
    await play(0.4);
    await drag(const [Offset(200, 520), Offset(200, 640)], 0.3);
    await play(0.4);
    mark('Hero transition');
    await tap(196, 556);
    await play(2.2);
    await tap(358.5, 89.3);
    await play(0.7);
    mark('Workout player');
    await tap(197.5, 778.8);
    await play(5.0);
    await tap(196.5, 743, hold: 0.1);
    await play(0.9);
    mark('Liquid progress chart');
    await tap(41, 90);
    await play(0.6);
    await tap(41, 90.5);
    await play(0.6);
    await tap(246, 786.6);
    await play(2.0);
    await tap(109.7, 436);
    await play(0.7);
    await tap(208.5, 428);
    await play(0.7);
    mark('Workouts & Profile');
    await tap(148.7, 786.6);
    await play(1.0);
    await tap(341.2, 786.6);
    await play(1.0);
    await tap(53, 786.6);
    await play(0.8);

    File('$reelDir/timeline.json').writeAsStringSync(jsonEncode({'frames': frame, 'taps': taps, 'marks': marks}));
    done(tester);
  }, timeout: const Timeout(Duration(minutes: 30)));
}
