import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'sounds.dart';

abstract class SoundEngine {
  void setLevel(Sound sound, double level);
  void dispose();
}

class SilentEngine implements SoundEngine {
  final Map<Sound, double> levels = {};

  @override
  void setLevel(Sound sound, double level) => levels[sound] = level;

  @override
  void dispose() {}
}

class LoopEngine implements SoundEngine {
  LoopEngine() {
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) => _step());
    unawaited(_configure());
  }

  final Map<Sound, AudioPlayer> _players = {};
  final Map<Sound, double> _target = {};
  final Map<Sound, double> _current = {};
  final Set<Sound> _starting = {};
  late final Timer _ticker;

  Future<void> _configure() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
          respectSilence: false,
          stayAwake: true,
        ).build(),
      );
    } catch (_) {}
  }

  @override
  void setLevel(Sound sound, double level) {
    _target[sound] = level.clamp(0.0, 1.0);
    if (level > 0 && !_players.containsKey(sound)) unawaited(_start(sound));
  }

  Future<void> _start(Sound sound) async {
    if (_starting.contains(sound)) return;
    _starting.add(sound);
    try {
      final player = AudioPlayer(playerId: 'nocturne_${sound.name}');
      _players[sound] = player;
      _current[sound] = 0;
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(0);
      await player.play(AssetSource(sound.asset), volume: 0);
    } catch (_) {
      _players.remove(sound)?.dispose();
    } finally {
      _starting.remove(sound);
    }
  }

  void _step() {
    for (final entry in _players.entries.toList()) {
      final sound = entry.key;
      final target = _target[sound] ?? 0;
      final current = _current[sound] ?? 0;
      if ((target - current).abs() < 0.002) continue;
      final rate = target > current ? 0.035 : 0.05;
      final next = current + (target - current).clamp(-rate, rate);
      _current[sound] = next;
      final gain = next * next;
      try {
        entry.value.setVolume(gain);
      } catch (_) {}
      if (next <= 0.002 && target == 0) {
        _current.remove(sound);
        final player = _players.remove(sound);
        player?.stop().catchError((_) {}).whenComplete(() => player.dispose());
      }
    }
  }

  @override
  void dispose() {
    _ticker.cancel();
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
  }
}
