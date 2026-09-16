import 'package:flutter/services.dart';

import '../settings.dart';
import 'engine_native.dart'
    if (dart.library.js_interop) 'engine_web.dart'
    as platform;

enum Sfx {
  tap('tap', voices: 4),
  tick('tick', voices: 4),
  nav('nav'),
  back('back'),
  open('open'),
  toggleOn('toggle_on'),
  toggleOff('toggle_off'),
  confirm('confirm'),
  coin('coin'),
  denied('denied'),
  charge('charge', voices: 1),
  levelUp('level_up', voices: 1),
  victory('victory', voices: 1);

  const Sfx(this.file, {this.voices = 2});

  final String file;

  final int voices;

  String get asset => 'sfx/$file.wav';
}

abstract interface class SfxEngine {
  Future<void> warmUp();
  void play(Sfx sfx, double volume);
}

class SilentSfxEngine implements SfxEngine {
  @override
  Future<void> warmUp() async {}

  @override
  void play(Sfx sfx, double volume) {}
}

class RecordingSfxEngine implements SfxEngine {
  final List<Sfx> played = <Sfx>[];

  @override
  Future<void> warmUp() async {}

  @override
  void play(Sfx sfx, double volume) => played.add(sfx);
}

class GameAudio {
  GameAudio._();

  static SfxEngine engine = SilentSfxEngine();

  static Future<void> init() async {
    final real = platform.createPlatformEngine();
    engine = real;
    await real.warmUp();
  }

  static void play(Sfx sfx) {
    final settings = GameSettings.instance;
    if (!settings.sound || settings.volume <= 0) return;
    engine.play(sfx, settings.volume);
  }
}

enum Buzz { selection, light, medium, heavy }

class Haptics {
  Haptics._();

  static void buzz(Buzz kind) {
    if (!GameSettings.instance.haptics) return;
    switch (kind) {
      case Buzz.selection:
        HapticFeedback.selectionClick();
      case Buzz.light:
        HapticFeedback.lightImpact();
      case Buzz.medium:
        HapticFeedback.mediumImpact();
      case Buzz.heavy:
        HapticFeedback.heavyImpact();
    }
  }
}
