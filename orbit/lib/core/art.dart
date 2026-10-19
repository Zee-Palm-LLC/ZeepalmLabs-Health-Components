import 'package:flutter/widgets.dart';

import 'canvas.dart';

class Box {
  const Box(this.l, this.t, this.r, this.b);

  const Box.circle(double cx, double cy, double radius) : l = cx - radius, t = cy - radius, r = cx + radius, b = cy + radius;

  final double l;
  final double t;
  final double r;
  final double b;

  double get w => r - l;
  double get h => b - t;
  Offset get center => Offset((l + r) / 2, (t + b) / 2);
  Rect get rect => Rect.fromLTRB(l, t, r, b);
}

class Sprite {
  const Sprite(this.name, this.box);

  final String name;
  final Box box;

  String get asset => 'assets/art/$name.webp';

  Widget image({BoxFit fit = BoxFit.fill}) => Image.asset(asset, fit: fit, filterQuality: FilterQuality.medium, gaplessPlayback: true);
}

abstract final class Art {
  static const egg = Sprite('egg', Box(40, 285, 365, 705));
  static const sun = Sprite('sun', Box(262, 295, 385, 415));
  static const logo = Sprite('logo', Box(25, 70, 370, 230));
  static const planet = Sprite('planet', Box(0, 225, 402, 685));
  static const buddy = Sprite('buddy', Box(0, 148, 100, 245));
  static const runner = Sprite('runner', Box(90, 415, 235, 685));
  static const chest = Sprite('chest', Box(225, 292, 295, 350));
  static const coin = Sprite('coin', Box.circle(248, 601, 24));
  static const luna = Sprite('p_luna', Box(12, 105, 162, 268));
  static const zane = Sprite('p_zane', Box(258, 145, 392, 285));
  static const you = Sprite('p_you', Box(75, 195, 300, 450));
  static const kai = Sprite('p_kai', Box(12, 438, 142, 565));
  static const maya = Sprite('p_maya', Box(268, 428, 392, 558));
  static const trophy = Sprite('trophy', Box(92, 575, 127, 609));
  static const crown = Sprite('crown', Box(178, 198, 215, 224));
  static const flame = Sprite('flame', Box(234, 163, 264, 198));
  static const star = Sprite('star', Box(352, 634, 375, 657));
  static const steps = Sprite('ic_steps', Box.circle(39, 85, 23.5));
  static const water = Sprite('ic_water', Box.circle(178, 95.5, 23.5));
  static const energy = Sprite('ic_energy', Box.circle(301.5, 101.5, 23.5));
  static const navMoon = Sprite('nav_moon', Box.circle(61.8, 779.5, 24.5));
  static const navSprout = Sprite('nav_sprout', Box.circle(115.6, 747.5, 25.5));
  static const navWorld = Sprite('nav_world', Box.circle(201, 745, 37.5));
  static const navHeart = Sprite('nav_heart', Box.circle(283.7, 751, 25));
  static const navStar = Sprite('nav_star', Box.circle(337, 783, 25));
  static const heart = Sprite('badge_heart', Box.circle(57.5, 179, 35));
  static const rocket = Sprite('badge_rocket', Box.circle(63.75, 803, 35));

  static const plates = ['splash', 'world', 'run', 'race'];
  static const all = [
    egg, sun, logo, planet, buddy, runner, chest, coin, luna, zane, you, kai, maya, trophy, crown, flame, star, steps, water,
    energy, navMoon, navSprout, navWorld, navHeart, navStar, heart, rocket,
  ];

  static const avatars = {'You': 'av_you', 'Luna': 'av_luna', 'Zane': 'av_zane', 'Maya': 'av_maya'};
  static const tagAvatars = {'Luna': 'tag_luna', 'Zane': 'tag_zane', 'Kai': 'tag_kai', 'Maya': 'tag_maya'};
}

class Place extends StatelessWidget {
  const Place(this.sprite, {super.key, this.child});

  final Sprite sprite;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final b = sprite.box;
    return Positioned(left: b.l, top: b.t, width: b.w, height: b.h, child: child ?? sprite.image());
  }
}

class Plate extends StatelessWidget {
  const Plate(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final f = Frame.maybeOf(context);
    final x = f?.extraX ?? 0;
    final y = f?.extraY ?? 0;
    return Positioned(
      left: -x,
      top: -y,
      width: 402 + 2 * x,
      height: 874 + 2 * y,
      child: Image.asset('assets/plates/$name.webp', fit: BoxFit.cover, filterQuality: FilterQuality.medium, gaplessPlayback: true),
    );
  }
}
