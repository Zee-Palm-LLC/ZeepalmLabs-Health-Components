import 'dart:ui' as ui;

abstract final class Shaders {
  static ui.FragmentProgram? orb;
  static ui.FragmentProgram? grain;

  static Future<void> load() async {
    orb ??= await _tryLoad('shaders/orb.frag');
    grain ??= await _tryLoad('shaders/grain.frag');
  }

  static Future<ui.FragmentProgram?> _tryLoad(String asset) async {
    try {
      return await ui.FragmentProgram.fromAsset(asset);
    } catch (_) {
      return null;
    }
  }
}
