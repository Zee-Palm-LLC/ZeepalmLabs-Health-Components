import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'engine.dart';
import 'sounds.dart';

class Mixer extends ChangeNotifier {
  Mixer({SoundEngine? engine}) : engine = engine ?? SilentEngine() {
    _load(presetMixes.first);
  }

  static const maxSounds = 4;
  static const defaultVolume = 0.64;

  final SoundEngine engine;

  final List<Sound> _sounds = [];
  final Map<Sound, double> _volumes = {};
  final List<Mix> library = presetMixes.toList();

  String name = presetMixes.first.name;
  double master = 0.62;
  bool playing = false;
  bool liked = false;
  Duration timer = const Duration(minutes: 60);
  Duration elapsed = const Duration(seconds: 12);
  int pourGeneration = 0;
  Timer? _clock;

  List<Sound> get sounds => List.unmodifiable(_sounds);
  bool contains(Sound s) => _sounds.contains(s);
  double volume(Sound s) => _volumes[s] ?? defaultVolume;
  bool get isFull => _sounds.length >= maxSounds;
  Duration get remaining =>
      timer - elapsed < Duration.zero ? Duration.zero : timer - elapsed;
  double get progress => timer.inMilliseconds == 0
      ? 0
      : (elapsed.inMilliseconds / timer.inMilliseconds).clamp(0.0, 1.0);
  String get subtitle => _sounds.map((s) => s.label).join('  ·  ');

  String get poem {
    if (_sounds.length >= 3) return 'A Calmer You';
    if (_sounds.isEmpty) return 'An Empty Sky';
    final lead = _sounds.reduce((a, b) => volume(a) >= volume(b) ? a : b);
    return switch (lead) {
      Sound.rain => 'A Softer Night',
      Sound.waves => 'A Slower Tide',
      Sound.fire => 'A Warmer You',
      Sound.wind => 'A Lighter Mind',
      Sound.forest => 'A Greener Hush',
      Sound.night => 'A Deeper Dark',
      Sound.stream => 'A Clearer Mind',
      Sound.crickets => 'A Summer Dusk',
      Sound.thunder => 'A Safer Storm',
    };
  }

  void _load(Mix mix) {
    _sounds
      ..clear()
      ..addAll(mix.sounds.take(maxSounds));
    _volumes
      ..clear()
      ..addAll(mix.volumes);
    name = mix.name;
    liked = false;
  }

  bool toggle(Sound s) {
    if (_sounds.contains(s)) {
      _sounds.remove(s);
    } else {
      if (isFull) return false;
      _sounds.add(s);
      _volumes.putIfAbsent(s, () => defaultVolume);
    }
    _markCustom();
    _sync();
    notifyListeners();
    return true;
  }

  void remove(Sound s) {
    if (!_sounds.remove(s)) return;
    _markCustom();
    _sync();
    notifyListeners();
  }

  void setVolume(Sound s, double v) {
    _volumes[s] = v.clamp(0.0, 1.0);
    _sync();
    notifyListeners();
  }

  void setMaster(double v) {
    master = v.clamp(0.0, 1.0);
    _sync();
    notifyListeners();
  }

  void reset() {
    for (final s in _sounds) {
      _volumes[s] = defaultVolume;
    }
    master = 0.62;
    pourGeneration++;
    _sync();
    notifyListeners();
  }

  void play() {
    if (playing) return;
    playing = true;
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _second());
    _sync();
    notifyListeners();
  }

  void pause() {
    if (!playing) return;
    playing = false;
    _clock?.cancel();
    _sync();
    notifyListeners();
  }

  void togglePlay() => playing ? pause() : play();

  void setTimer(Duration d) {
    timer = d;
    elapsed = Duration.zero;
    notifyListeners();
  }

  void _second() {
    elapsed += const Duration(seconds: 1);
    if (elapsed >= timer) {
      elapsed = timer;
      pause();
      return;
    }
    final left = remaining.inSeconds;
    if (left < 30) _sync(fade: left / 30);
    notifyListeners();
  }

  void toggleLike() {
    liked = !liked;
    if (liked) {
      final mix = Mix(
        name: name,
        sounds: sounds,
        volumes: Map.of(_volumes),
        saved: true,
      );
      final i = library.indexWhere((m) => m.name == name);
      if (i >= 0) {
        library[i] = mix;
      } else {
        library.insert(0, mix);
      }
    } else {
      if (!presetMixes.any((m) => m.name == name)) {
        library.removeWhere((m) => m.name == name);
      }
    }
    notifyListeners();
  }

  void open(Mix mix) {
    _load(mix);
    pourGeneration++;
    elapsed = Duration.zero;
    _sync();
    notifyListeners();
  }

  void step(int direction) {
    if (library.isEmpty) return;
    final i = library.indexWhere((m) => m.name == name);
    final next = library[((i < 0 ? 0 : i) + direction) % library.length];
    open(next);
  }

  void _markCustom() {
    final preset = library.where((m) => m.name == name).firstOrNull;
    if (preset == null) return;
    final same = listEquals(preset.sounds, _sounds);
    if (!same) {
      name = 'Tonight’s Mix';
      liked = false;
    }
  }

  void _sync({double fade = 1}) {
    for (final s in Sound.values) {
      final on = playing && _sounds.contains(s);
      engine.setLevel(s, on ? volume(s) * master * fade * 1.25 : 0);
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    engine.dispose();
    super.dispose();
  }
}

class MixerScope extends InheritedNotifier<Mixer> {
  const MixerScope({super.key, required Mixer mixer, required super.child})
    : super(notifier: mixer);

  static Mixer of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MixerScope>()!.notifier!;

  static Mixer read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<MixerScope>()!.notifier!;
}
