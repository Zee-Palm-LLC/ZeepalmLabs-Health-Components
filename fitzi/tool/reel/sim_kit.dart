// Shared driver for the "dev desk" simulator reels (see lib/reel/sim_stage.dart).
//
// A reel script drives the real app with real gestures on an exact 1/60 s
// test clock; the mouse pointer on the stage follows those gestures. Each
// render is two passes, so the pointer can glide to a tap before it happens:
//
//   REEL_DRY=1 flutter test tool/reel/<script>.dart   # records the gesture track
//   REEL_OUT=build/reel/frames flutter test tool/reel/<script>.dart
//
// Optional: REEL_UNTIL=<seconds>, REEL_EVERY=<n> for quick previews.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fitzi/reel/sim_stage.dart';

const fps = 60;
const _rest = Offset(845, 240 + 760);

class SimKit {
  SimKit(
    this.tester, {
    required this.name,
    required this.length,
    required this.code,
    required this.phone,
    required this.phoneSize,
    required this.app,
    this.designWidth = 390,
    List<(String, double, double)>? parts,
  }) : parts = parts ?? [(name, 0, length)];

  final WidgetTester tester;

  /// Output file name, e.g. `Lull-Simulator-9x16.mp4`.
  final String name;
  final double length;
  SimCode code;
  final Widget Function() phone;
  final Size phoneSize;

  /// Finds the app canvas inside the phone; taps use its design points.
  final Finder app;
  final double designWidth;

  /// Output clips cut from the one continuous run: (file name, start, end).
  /// Each is written to its own folder under [out] when there are several.
  final List<(String, double, double)> parts;

  final _env = Platform.environment;
  late final bool dry = _env['REEL_DRY'] == '1';
  late final Directory out = Directory(_env['REEL_OUT'] ?? 'build/reel/frames');
  late final double until = double.tryParse(_env['REEL_UNTIL'] ?? '') ?? length;
  late final int every = int.tryParse(_env['REEL_EVERY'] ?? '') ?? 1;
  late final File _trackFile = File('build/reel/${name.replaceAll('.mp4', '')}.track.json');

  int frame = 0;
  Duration _elapsed = Duration.zero;
  double get now => frame / fps;
  Duration get _stamp => Duration(microseconds: (frame * 1e6 / fps).round());
  final events = <Map<String, Object>>[];
  final _stageKey = GlobalKey();

  // Pointer: live state, and the recorded track of presses (t0, t1, from, to).
  TestGesture? _g;
  Offset? _pos;
  final _presses = <List<double>>[];
  List<List<double>> _track = const [];

  double _scroll = 0;
  int _active = 0;
  int _target = 0;

  /// Fonts, view size and the first frame. [fonts] preloads app fonts.
  Future<void> setUp({Future<void> Function()? fonts, String focusOn = ''}) async {
    out.createSync(recursive: true);
    if (!dry && _trackFile.existsSync()) {
      _track = [for (final p in jsonDecode(_trackFile.readAsStringSync()) as List) [for (final v in p as List) (v as num).toDouble()]];
    }
    HttpOverrides.global = null;
    debugDisableShadows = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('sim_reel_fonts').path,
    );
    tester.view.physicalSize = simSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      final sdk = _env['FLUTTER_ROOT'] ?? 'C:/src/flutter';
      final icons = File('$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf').readAsBytesSync();
      await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons)))).load();
      for (final w in [FontWeight.w400, FontWeight.w500, FontWeight.w600, FontWeight.w700]) {
        GoogleFonts.inter(fontWeight: w);
      }
      GoogleFonts.jetBrainsMono();
      await fonts?.call();
      await GoogleFonts.pendingFonts();
    });
    focus(focusOn, jump: true);
    await tester.pumpWidget(_stage());
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(microseconds: 1));
    }
  }

  Widget _stage() => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: _stageKey,
            child: SimStage(
              t: now - _part.$2,
              length: _part.$3 - _part.$2,
              phone: phone(),
              phoneSize: phoneSize,
              code: code,
              scroll: _scroll,
              active: _active,
              cursor: _cursor(),
              down: _g != null,
            ),
          ),
        ),
      );

  (String, double, double) get _part => parts.lastWhere((p) => now >= p.$2 - 1e-9, orElse: () => parts.first);

  Directory _dir(int i) => parts.length == 1 ? out : Directory('${out.path}/${i + 1}');

  /// A design point on the app canvas, in screen coordinates.
  Offset at(double x, double y) {
    final r = tester.getRect(app);
    return r.topLeft + Offset(x, y) * (r.width / designWidth);
  }

  void cue(String kind) => events.add({'t': now, 'kind': kind});

  /// Moves the editor to the first line containing [pattern].
  void focus(String pattern, {bool jump = false}) {
    if (pattern.isEmpty) return;
    final i = code.lines.indexWhere((l) => l.contains(pattern));
    if (i < 0) return;
    _target = i;
    if (jump) {
      _active = i;
      _scroll = max(0, i - 12).toDouble();
    }
  }

  // ── Gestures ──

  Future<void> press(double x, double y, {String? code}) => pressAt(at(x, y), code: code);

  Future<void> pressAt(Offset p, {String? code}) async {
    if (code != null) focus(code);
    _pos = p;
    _presses.add([now, double.nan, _pos!.dx, _pos!.dy, _pos!.dx, _pos!.dy]);
    _g = await tester.createGesture();
    await _g!.down(_pos!, timeStamp: _stamp);
  }

  Future<void> moveTo(double x, double y) async {
    _pos = at(x, y);
    await _g!.moveTo(_pos!, timeStamp: _stamp);
  }

  Future<void> release() async {
    _presses.last
      ..[1] = now
      ..[4] = _pos!.dx
      ..[5] = _pos!.dy;
    await _g!.up(timeStamp: _stamp);
    _g = null;
  }

  Future<void> tap(double x, double y, {String? code, double hold = 0.09}) => tapAt(at(x, y), code: code, hold: hold);

  Future<void> tapAt(Offset p, {String? code, double hold = 0.09}) async {
    await pressAt(p, code: code);
    await to(now + hold);
    await release();
  }

  /// Presses at (x0, y0) and drags to (x1, y1) over [dur] seconds.
  Future<void> drag(double x0, double y0, double x1, double y1,
      {double dur = 0.35, String? code, Curve curve = Curves.easeInOut, double hold = 0.04}) async {
    await press(x0, y0, code: code);
    await to(now + hold);
    final t0 = now;
    while (now < t0 + dur - 1e-9) {
      await step();
      final k = curve.transform(((now - t0) / dur).clamp(0.0, 1.0));
      await moveTo(x0 + (x1 - x0) * k, y0 + (y1 - y0) * k);
    }
    await release();
  }

  /// Moves the held pointer to (x, y) over [dur] seconds, frame by frame.
  Future<void> glide(double x, double y, double dur, {Curve curve = Curves.easeInOut}) async {
    final a = _pos!, b = at(x, y), t0 = now;
    while (now < t0 + dur - 1e-9) {
      await step();
      final k = curve.transform(((now - t0) / dur).clamp(0.0, 1.0));
      _pos = Offset.lerp(a, b, k);
      await _g!.moveTo(_pos!, timeStamp: _stamp);
    }
  }

  /// Glides between recorded presses; follows the live pointer while down.
  Offset _cursor() {
    if (_g != null && _pos != null) return _pos!;
    final t = now;
    final track = _track;
    Offset from = _rest, to = _rest;
    double a = -1, b = 0.6;
    for (var i = 0; i < track.length; i++) {
      final p = track[i];
      if (p[0] > t) {
        to = Offset(p[2], p[3]);
        final prevUp = i > 0 ? track[i - 1][1] : 0.0;
        if (i > 0) from = Offset(track[i - 1][4], track[i - 1][5]);
        b = p[0] - 0.06;
        a = max(prevUp + 0.08, b - 0.75);
        if (i == 0) a = max(0.4, b - 0.9);
        // A long wait: park over the editor instead of hovering on the app.
        if (i > 0 && b - prevUp > 3.2) {
          if (t < b - 0.9) {
            final k = Curves.easeInOutCubic.transform(((t - prevUp - 0.3) / 0.9).clamp(0.0, 1.0));
            return Offset.lerp(from, _rest, k)!;
          }
          from = _rest;
          a = b - 0.9;
        }
        break;
      }
      if (i == track.length - 1) {
        from = Offset(p[4], p[5]);
        a = p[1] + 0.35;
        b = a + 0.9;
      }
    }
    if (track.isEmpty) return _rest;
    final k = Curves.easeInOutCubic.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
    return Offset.lerp(from, to, k)!;
  }

  // ── Clock ──

  Future<void> step() async {
    final s = 1 - exp(-8 / fps);
    _scroll += (max(0, _target - 12) - _scroll) * s;
    if ((_scroll - max(0, _target - 12)).abs() < 0.02) _scroll = max(0, _target - 12).toDouble();
    _active = _target;
    await tester.pumpWidget(_stage());
    final target = _stamp;
    await tester.pump(target - _elapsed);
    _elapsed = target;
    final part = parts.indexWhere((p) => now >= p.$2 - 1e-9 && now < p.$3 - 1e-9);
    final local = part < 0 ? 0 : ((now - parts[part].$2) * fps).round();
    if (!dry && part >= 0 && local % every == 0 && now < until) {
      final dir = _dir(part)..createSync(recursive: true);
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_stageKey));
      await tester.runAsync(() async {
        final img = await boundary.toImage(pixelRatio: 1);
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        img.dispose();
        File('${dir.path}/${local.toString().padLeft(5, '0')}.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
    frame++;
  }

  Future<void> to(double s) async {
    while (now < s - 1e-9 && now < until) {
      await step();
    }
  }

  Future<void> finish() async {
    await to(length);
    if (dry) {
      Directory('build/reel').createSync(recursive: true);
      _trackFile.writeAsStringSync(jsonEncode(_presses));
    } else {
      for (final (i, (file, a, b)) in parts.indexed) {
        _dir(i).createSync(recursive: true);
        File('${_dir(i).path}/events.json').writeAsStringSync(jsonEncode({
          'fps': fps,
          'length': b - a,
          'width': simSize.width.round(),
          'height': simSize.height.round(),
          'name': file,
          'events': [
            for (final e in events)
              if ((e['t'] as double) >= a && (e['t'] as double) < b) {...e, 't': (e['t'] as double) - a},
          ],
        }));
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    debugDisableShadows = true;
  }
}

/// Reads a project source file for the editor.
SimCode readCode(String project, String path, {List<String> tabs = const []}) =>
    SimCode(project: project, path: path, lines: File(path).readAsLinesSync(), tabs: tabs);
