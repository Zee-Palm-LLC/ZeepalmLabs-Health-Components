// Renders the Reforma showcase reel frame by frame at 60 fps
// (1920×1440 by default, or 1080×1350 with REEL_FORMAT=4x5).
//
//   REEL_OUT=<dir> flutter test tool/reel/render_reel_test.dart
//
// Optional: REEL_UNTIL=<seconds> to stop early, REEL_EVERY=<n> to save only
// every n-th frame (quick previews). Time advances exactly 1/60 s per frame
// through the test clock, so every animation, spring and fling in the real
// app is sampled perfectly evenly — the smoothest possible capture.
// Then encode with tool/reel/encoder.html (see tool/reel/README.md).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reforma/main.dart';
import 'package:reforma/reel/reel_stage.dart';
import 'package:reforma/screens/body_viewer.dart';
import 'package:reforma/screens/home.dart';
import 'package:reforma/screens/mobility.dart';
import 'package:reforma/widgets/gauges.dart';

const fps = 60;
const length = 30.0;

void main() {
  testWidgets('render reel', (tester) async {
    final out = Directory(Platform.environment['REEL_OUT'] ?? 'build/reel/frames')..createSync(recursive: true);
    final until = double.tryParse(Platform.environment['REEL_UNTIL'] ?? '') ?? length;
    final every = int.tryParse(Platform.environment['REEL_EVERY'] ?? '') ?? 1;
    // REEL_FORMAT=4x5 → 1080×1350 portrait (Instagram); default 4:3 1920×1440.
    final format = switch (Platform.environment['REEL_FORMAT']) {
      '4x5' => ReelFormat.portrait,
      '4x5-phone' => ReelFormat.phoneOnly,
      _ => ReelFormat.landscape,
    };

    // Real fonts: Inter through google_fonts (needs real HTTP), Phosphor from assets.
    HttpOverrides.global = null;
    // flutter_test draws BoxShadows as hard unblurred slabs by default; render them like the app.
    debugDisableShadows = false;
    // google_fonts caches downloads via path_provider: point it at a temp dir.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('reel_fonts').path,
    );
    tester.view.physicalSize = format.size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      for (final (family, file) in const [
        ('PhosphorRegular', 'assets/fonts/Phosphor.ttf'),
        ('PhosphorFill', 'assets/fonts/Phosphor-Fill.ttf'),
        ('PhosphorBold', 'assets/fonts/Phosphor-Bold.ttf'),
      ]) {
        final bytes = File(file).readAsBytesSync();
        await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      }
      for (final w in [FontWeight.w400, FontWeight.w500, FontWeight.w600]) {
        GoogleFonts.inter(fontWeight: w);
      }
      await GoogleFonts.pendingFonts();
    });

    final st = ReelState();
    final stageKey = GlobalKey();
    Widget app(Widget phone) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Material(
            type: MaterialType.transparency,
            child: RepaintBoundary(key: stageKey, child: ReelStage(state: st, phoneChild: phone, format: format)),
          ),
        );
    await tester.pumpWidget(app(const SizedBox()));

    // ---- clock + capture -------------------------------------------------
    var frame = 0;
    var elapsed = Duration.zero;
    double now() => frame / fps;
    Duration stamp() => elapsed;
    final events = <Map<String, Object>>[];
    void cue(String kind) => events.add({'t': now(), 'kind': kind});
    // The phone-only cut follows the Lull 4:5 reel: shorter, camera push-ins, gesture labels.
    final reelLength = format.bare ? 27.5 : length;
    st.length = reelLength;

    // Finger (base stage coordinates) + camera tweens, evaluated every frame.
    final size = format.size, centre = size.center(Offset.zero);
    final offstage = Offset(size.width - 160, size.height + 80);
    st.finger = offstage;
    Offset fFrom = offstage, fTo = offstage;
    var fT0 = 0.0, fDur = 1.0, fadeTarget = 0.0, pressTarget = 0.0;
    Offset cFrom = centre, cTo = centre;
    var zFrom = 1.0, zTo = 1.0, cT0 = 0.0, cDur = 1.0;
    void hook() {
      final k = Curves.easeInOutCubic.transform(((now() - fT0) / fDur).clamp(0.0, 1.0));
      st.finger = Offset.lerp(fFrom, fTo, k)!;
      final c = Curves.easeInOutCubic.transform(((now() - cT0) / cDur).clamp(0.0, 1.0));
      st.camFocus = Offset.lerp(cFrom, cTo, c);
      st.camZoom = zFrom + (zTo - zFrom) * c;
      st.fingerOpacity += (fadeTarget - st.fingerOpacity) * 0.18;
      st.press += (pressTarget - st.press) * 0.35;
      st.ripples.removeWhere((r) => now() - r.$2 > 1);
    }

    Future<void> step() async {
      final target = Duration(microseconds: (frame * 1e6 / fps).round());
      hook();
      st.tick(now());
      await tester.pump(target - elapsed);
      elapsed = target;
      if (frame % every == 0 && now() < until) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(stageKey));
        await tester.runAsync(() async {
          final img = await boundary.toImage(pixelRatio: 1);
          final png = await img.toByteData(format: ui.ImageByteFormat.png);
          img.dispose();
          File('${out.path}/${frame.toString().padLeft(5, '0')}.png').writeAsBytesSync(png!.buffer.asUint8List());
        });
      }
      frame++;
    }

    Future<void> to(double t) async {
      while (now() < t - 1e-9 && now() < until) {
        await step();
      }
    }

    Future<void> wait(double s) => to(now() + s);

    Offset base(Offset screen) => st.toBase(screen, size);
    Offset screen(Offset b) => st.toScreen(b, size);

    /// Camera push-in to a screen point (null = back to the full phone).
    Future<void> cam(Offset? at, double zoom, {double dur = 0.75}) async {
      cFrom = st.camFocus ?? centre;
      zFrom = st.camZoom;
      cTo = at == null ? centre : base(at);
      zTo = zoom;
      cT0 = now();
      cDur = dur;
      await wait(dur);
    }

    void label(String text, IconData icon, double dur) =>
        st.label = (text: text, icon: icon, start: now(), end: now() + dur);

    Future<void> moveTo(Offset p, {double dur = 0.5}) async {
      fFrom = st.finger;
      fTo = base(p);
      fT0 = now();
      fDur = dur;
      fadeTarget = 1;
      await wait(dur);
    }

    Future<void> tap(Offset p, {String kind = 'tap'}) async {
      await moveTo(p);
      final at = screen(fTo);
      final g = await tester.createGesture();
      await g.down(at, timeStamp: stamp());
      pressTarget = 1;
      await wait(7 / fps);
      await g.up(timeStamp: stamp());
      st.ripples.add((fTo, now()));
      cue(kind);
      pressTarget = 0;
      await wait(4 / fps);
    }

    /// Drag with a timestamped pointer path, so the real VelocityTracker sees
    /// the true speed (flings carry genuine inertia). [hold] stops before
    /// release for a zero-velocity let-go.
    Future<void> drag(Offset from, Offset to, double dur, {bool hold = false, Curve curve = Curves.linear}) async {
      final a = base(from), b = base(to);
      await moveTo(from, dur: 0.45);
      final g = await tester.createGesture();
      await g.down(screen(a), timeStamp: stamp());
      pressTarget = 1;
      final n = (dur * fps).round();
      for (var i = 1; i <= n; i++) {
        final p = Offset.lerp(a, b, curve.transform(i / n))!;
        fFrom = fTo = p;
        await step();
        await g.moveTo(screen(p), timeStamp: stamp());
      }
      if (hold) await wait(8 / fps);
      await g.up(timeStamp: stamp());
      pressTarget = 0;
    }

    Offset centerOf(Finder f) => tester.getCenter(f.hitTestable().first);
    Offset mid(Offset a, Offset b) => Offset.lerp(a, b, 0.5)!;

    /// Design-space point (390-wide canvas) inside the widget found by [f].
    Offset design(Finder f, double x, double y) {
      final r = tester.getRect(f.first);
      final s = r.width / 390;
      return r.topLeft + Offset(x, y) * s;
    }

    Offset highFace() {
      // The pain-scale faces are painted, not widgets: aim at the "High" face (x = 240 design pt).
      final r = tester.getRect(find.byType(EmojiScale));
      return r.topLeft + Offset(240, 30) * (r.width / 347);
    }

    void fingerAway() {
      fadeTarget = 0;
      fFrom = st.finger;
      fTo = st.finger + const Offset(160, 260);
      fT0 = now();
      fDur = 0.8;
    }

    if (format.bare) {
      // ---- Lull-style 4:5 cut: camera pushes in on each interaction --------
      cue('rise');
      await tester.pumpWidget(app(const PhoneFrame(shadow: false, child: HomeScreen())));

      // Home → body check-in.
      await to(3.6);
      final card = centerOf(find.text('Movement &\nrecovery')) + const Offset(60, 90);
      await cam(card, 1.45);
      label('Tap', ReelIcons.tap, 1.6);
      await tap(centerOf(find.text('Movement &\nrecovery')) + const Offset(60, 90), kind: 'whoosh');
      await to(5.6);
      await cam(null, 1, dur: 0.6);

      // Tap the knee, then the neck: the callout morphs between them.
      await to(6.5);
      final body = find.byType(BodyViewer);
      await cam(tester.getRect(body).center, 1.5, dur: 0.8);
      label('Tap', ReelIcons.tap, 2.6);
      await tap(design(body, 212, 300));
      await to(8.7);
      await tap(design(body, 184, 74));

      // Spin with a real fling; inertia carries it round.
      await to(9.9);
      label('Spin', ReelIcons.grab, 2.0);
      await drag(design(body, 80, 250), design(body, 330, 250), 0.42);
      cue('spin');

      // Pain scale + save.
      await to(12.2);
      final emoji = tester.getRect(find.byType(EmojiScale)).center;
      await cam(mid(emoji, tester.getCenter(find.text('Save check-in'))), 1.45, dur: 0.8);
      label('Tap', ReelIcons.tap, 2.2);
      await tap(highFace());
      await to(13.9);
      await tap(centerOf(find.text('Save check-in')), kind: 'success');
      await to(14.6);
      await cam(null, 1, dur: 0.6);
      await to(15.3);
      cue('whoosh');

      // Home updated live: push in on the ring + pain pill.
      await to(15.8);
      await cam(mid(tester.getCenter(find.byType(RecoveryRing)), centerOf(find.text('Pain'))), 1.6, dur: 0.8);
      await to(17.2);
      await cam(null, 1, dur: 0.6);

      // Guided session.
      label('Tap', ReelIcons.tap, 1.4);
      await tap(centerOf(find.text('Continue session')), kind: 'whoosh');
      await to(19.0);
      final session = find.byType(MobilityScreen);
      await cam(design(session, 195, 250), 1.4, dur: 0.8);
      label('Tap', ReelIcons.tap, 1.3);
      await tap(centerOf(find.text('Watch preview')));
      await to(20.8);
      label('Drag', ReelIcons.swipe, 1.6);
      await drag(design(session, 250, 250), design(session, 355, 250), 0.35);
      cue('spin');
      await to(22.2);
      await cam(null, 1, dur: 0.6);
      label('Pull', ReelIcons.pull, 1.6);
      await drag(design(session, 195, 470), design(session, 195, 640), 0.55, hold: true, curve: Curves.easeOut);

      await to(24.0);
      await cam(design(session, 195, 600), 1.45, dur: 0.7);
      label('Tap', ReelIcons.tap, 1.9);
      await tap(centerOf(find.text('Shoulder Rolls')), kind: 'tick');
      await to(25.6);
      await tap(centerOf(find.text('Band Pull Aparts')), kind: 'tick');
      await to(26.2);
      fingerAway();
      await cam(null, 1, dur: 0.8);
      await to(reelLength);
    } else {
      // ---- Captioned cuts (4:3 / 4:5) -----------------------------------
      cue('intro');
      await to(1.85);
      await tester.pumpWidget(app(const PhoneFrame(child: HomeScreen())));
      cue('rise');

      await to(4.5);
      await tap(centerOf(find.text('Movement &\nrecovery')) + const Offset(60, 90), kind: 'whoosh');

      await to(7.2);
      final body = find.byType(BodyViewer);
      await tap(design(body, 212, 300));
      await to(8.6);
      await tap(design(body, 184, 74));

      await to(10.7);
      await drag(design(body, 80, 250), design(body, 330, 250), 0.42);
      cue('spin');

      await to(12.9);
      await tap(highFace());
      await to(13.8);
      await tap(centerOf(find.text('Save check-in')), kind: 'success');
      await to(15.4);
      cue('whoosh');

      await to(17.5);
      await tap(centerOf(find.text('Continue session')), kind: 'whoosh');

      await to(19.4);
      await tap(centerOf(find.text('Watch preview')));

      await to(20.9);
      final session = find.byType(MobilityScreen);
      await drag(design(session, 250, 250), design(session, 355, 250), 0.35);
      cue('spin');

      await to(22.5);
      await drag(design(session, 195, 470), design(session, 195, 640), 0.55, hold: true, curve: Curves.easeOut);

      await to(23.9);
      await tap(centerOf(find.text('Shoulder Rolls')), kind: 'tick');
      await to(24.7);
      await tap(centerOf(find.text('Band Pull Aparts')), kind: 'tick');

      await to(25.5);
      fingerAway();
      await to(26.3);
      cue('outro');
      await to(length);
    }

    File('${out.path}/events.json').writeAsStringSync(jsonEncode({
      'fps': fps,
      'length': reelLength,
      'width': format.size.width.round(),
      'height': format.size.height.round(),
      'name': switch (format.name) {
        '4x5' => 'Reforma-Showcase-4x5-Captions-30s.mp4',
        '4x5-phone' => 'Reforma-Showcase-4x5.mp4',
        _ => 'Reforma-Showcase-30s.mp4',
      },
      'events': events,
    }));
    // Unmount so pending timers from the app settle cleanly.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    debugDisableShadows = true; // restore before the binding checks its invariants
  }, timeout: const Timeout(Duration(hours: 2)));
}
