import 'package:flutter/widgets.dart';

class Sprite {
  const Sprite(this.name, this.left, this.top, this.width, this.height);

  final String name;
  final double left;
  final double top;
  final double width;
  final double height;

  String get asset => 'assets/art/$name.webp';

  Rect get rect => Rect.fromLTWH(left, top, width, height);

  Widget image({BoxFit fit = BoxFit.fill}) =>
      Image.asset(asset, width: width, height: height, fit: fit, filterQuality: FilterQuality.medium, gaplessPlayback: true);
}

abstract final class Art {
  static const hero = Sprite('mascot_hero', 65.0, 300.0, 307.67, 444.67);
  static const runner = Sprite('mascot_run', 232.67, 163.33, 144.0, 173.67);
  static const stretch = Sprite('mascot_stretch', 110.0, 62.33, 229.33, 250.0);
  static const thumbBlast = Sprite('thumb_blast', 29.33, 513.33, 85.67, 71.67);
  static const thumbSalad = Sprite('thumb_salad', 28.67, 607.67, 87.0, 71.33);
  static const recentBlast = Sprite('recent_blast', 30.0, 550.0, 65.0, 65.0);
  static const recentCore = Sprite('recent_core', 30.0, 632.5, 65.0, 65.0);
  static const recentStretch = Sprite('recent_stretch', 30.0, 715.0, 65.0, 65.0);
  static const avatar = Sprite('avatar', 337.5, 65.5, 37.0, 37.0);
  static const logo = Sprite('logo', 142.33, 68.33, 104.0, 27.33);
  static const flame = Sprite('flame', 50.67, 169.67, 33.33, 43.0);
  static const statFire = Sprite('stat_fire', 34.67, 750.0, 29.67, 33.33);
  static const statShoe = Sprite('stat_shoe', 155.33, 751.67, 32.33, 32.67);
  static const statDrop = Sprite('stat_drop', 283.33, 751.33, 25.67, 31.67);

  static const wave = 'assets/art/emoji_wave.webp';
  static const fire = 'assets/art/emoji_fire.webp';
}
