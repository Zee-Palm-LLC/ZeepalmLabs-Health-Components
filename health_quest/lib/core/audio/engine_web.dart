import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

import 'sfx.dart';

SfxEngine createPlatformEngine() => WebAudioSfxEngine();

class WebAudioSfxEngine implements SfxEngine {
  web.AudioContext? _context;
  final Map<Sfx, web.AudioBuffer> _buffers = <Sfx, web.AudioBuffer>{};
  Future<void>? _ready;

  @override
  Future<void> warmUp() => _ready ??= _load();

  Future<void> _load() async {
    final context = web.AudioContext(
      web.AudioContextOptions(latencyHint: 'interactive'.toJS),
    );
    _context = context;

    void unlock(web.Event _) {
      if (context.state != 'running') context.resume();
    }

    web.document.addEventListener('pointerdown', unlock.toJS);
    web.document.addEventListener('keydown', unlock.toJS);

    await Future.wait(<Future<void>>[
      for (final sfx in Sfx.values) _decode(context, sfx),
    ]);
  }

  Future<void> _decode(web.AudioContext context, Sfx sfx) async {
    try {
      final data = await rootBundle.load('assets/${sfx.asset}');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final copy = Uint8List.fromList(bytes);
      _buffers[sfx] = await context.decodeAudioData(copy.buffer.toJS).toDart;
    } catch (_) {
    }
  }

  @override
  void play(Sfx sfx, double volume) {
    final context = _context;
    final buffer = _buffers[sfx];
    if (context == null || buffer == null) return;
    try {
      if (context.state != 'running') context.resume();
      final source = context.createBufferSource()..buffer = buffer;
      final gain = context.createGain();
      gain.gain.value = volume;
      source.connect(gain);
      gain.connect(context.destination);
      source.start();
    } catch (_) {
    }
  }
}
