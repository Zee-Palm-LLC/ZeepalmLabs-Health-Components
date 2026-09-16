import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'sfx.dart';

SfxEngine createPlatformEngine() => AudioPlayersSfxEngine();

class AudioPlayersSfxEngine implements SfxEngine {
  final Map<Sfx, List<AudioPlayer>> _voices = <Sfx, List<AudioPlayer>>{};
  final Map<Sfx, int> _next = <Sfx, int>{};
  final Map<AudioPlayer, double> _volumes = <AudioPlayer, double>{};
  Future<void>? _ready;

  @override
  Future<void> warmUp() => _ready ??= _load();

  Future<void> _load() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
          respectSilence: true,
        ).build(),
      );
    } catch (_) {
    }
    await Future.wait(<Future<void>>[
      for (final sfx in Sfx.values) _loadOne(sfx),
    ]);
  }

  Future<void> _loadOne(Sfx sfx) async {
    try {
      final ring = <AudioPlayer>[];
      for (var i = 0; i < sfx.voices; i++) {
        final player = AudioPlayer(playerId: 'sfx-${sfx.file}-$i');
        if (defaultTargetPlatform == TargetPlatform.android) {
          await player.setPlayerMode(PlayerMode.lowLatency);
        }
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource(sfx.asset));
        await player.setVolume(1);
        _volumes[player] = 1;
        ring.add(player);
      }
      _voices[sfx] = ring;
    } catch (_) {
      _voices.remove(sfx);
    }
  }

  @override
  void play(Sfx sfx, double volume) {
    final ring = _voices[sfx];
    if (ring == null || ring.isEmpty) return;
    final i = _next[sfx] ?? 0;
    _next[sfx] = (i + 1) % ring.length;
    final player = ring[i];
    unawaited(() async {
      try {
        if (_volumes[player] != volume) {
          _volumes[player] = volume;
          await player.setVolume(volume);
        }
        if (player.state == PlayerState.playing) await player.stop();
        await player.resume();
      } catch (_) {
      }
    }());
  }
}
