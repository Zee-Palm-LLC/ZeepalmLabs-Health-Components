import 'dart:ui' as ui;

abstract final class Shaders {
  static ui.FragmentProgram? holo;

  static Future<void> load() async {
    try {
      holo ??= await ui.FragmentProgram.fromAsset('shaders/holo.frag');
    } catch (_) {
      holo = null;
    }
  }
}
