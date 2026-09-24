import 'package:flutter/material.dart';

class Sprite {
  const Sprite(this.name, this.left, this.top, this.right, this.bottom);

  final String name;
  final double left;
  final double top;
  final double right;
  final double bottom;

  String get asset => 'assets/images/$name.png';

  double get width => right - left;

  double get height => bottom - top;

  Rect get rect => Rect.fromLTRB(left, top, right, bottom);

  Offset get center => rect.center;

  Sprite shift(double dx, double dy) => Sprite(name, left + dx, top + dy, right + dx, bottom + dy);

  Widget image({FilterQuality quality = FilterQuality.medium}) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.fill,
      filterQuality: quality,
      gaplessPlayback: true,
    );
  }

  Widget place({Widget? child}) {
    return Positioned(left: left, top: top, width: width, height: height, child: child ?? image());
  }
}

abstract final class Scenes {
  static const splash = 'assets/images/splash_scene.jpg';
  static const path = 'assets/images/path_scene.jpg';
  static const map = 'assets/images/map_scene.jpg';
  static const river = 'assets/images/river_scene.jpg';
}

abstract final class Art {
  static const logoPeaks = Sprite('logo_peaks', 133.0, 74.67, 269.67, 163.0);
  static const logoFlag = Sprite('logo_flag', 212.67, 75.67, 231.0, 93.67);
  static const logoMove = Sprite('logo_move', 46.33, 166.66, 211.33, 236.0);
  static const logoQuest = Sprite('logo_quest', 210.33, 166.0, 361.33, 227.67);
  static const splashRunner = Sprite('splash_runner', 17.0, 288.67, 204.67, 669.33);

  static const pathRunner = Sprite('onb_runner', 5.33, 92.67, 231.33, 538.0);
  static const chipRun = Sprite('chip_run', 247.0, 149.33, 298.0, 200.67);
  static const chipWalk = Sprite('chip_walk', 256.33, 209.67, 307.0, 260.33);
  static const chipYoga = Sprite('chip_yoga', 246.33, 269.67, 297.0, 320.33);
  static const chipGym = Sprite('chip_gym', 241.67, 329.33, 293.0, 380.67);
  static const chipCycling = Sprite('chip_cycling', 239.33, 390.67, 290.33, 441.33);

  static const avatar = Sprite('avatar', 19.33, 57.33, 85.0, 123.0);
  static const flex = Sprite('flex', 183.0, 92.67, 202.0, 113.67);
  static const gem = Sprite('gem', 280.33, 77.67, 304.67, 101.33);
  static const statFire = Sprite('stat_fire', 25.33, 150.33, 66.67, 191.67);
  static const statSteps = Sprite('stat_steps', 25.33, 213.0, 65.67, 253.33);
  static const statPin = Sprite('stat_pin', 27.67, 279.67, 67.67, 319.67);
  static const levelBadge = Sprite('level_badge', 214.33, 151.33, 264.67, 214.0);
  static const badgeGym = Sprite('badge_gym', 189.67, 247.0, 241.33, 328.67);
  static const badgePark = Sprite('badge_park', 249.0, 315.67, 311.33, 394.33);
  static const badgeWater = Sprite('badge_water', 318.0, 377.0, 381.0, 463.33);
  static const questCrystal = Sprite('quest_crystal', 35.0, 574.33, 77.67, 622.0);
  static const questRock = Sprite('quest_rock', 267.0, 539.0, 385.33, 590.0);
  static const miniPin = Sprite('mini_pin', 43.0, 638.33, 58.0, 662.0);
  static const miniClock = Sprite('mini_clock', 141.67, 638.33, 164.0, 661.0);
  static const miniFlame = Sprite('mini_flame', 259.67, 639.0, 277.0, 663.0);

  static const homeHero = Sprite('home_hero', 130.67, 372.67, 183.67, 518.33);
  static const routeRunner = Sprite('route_runner', 145.0, 173.33, 217.0, 346.0);
  static const balloon = Sprite('balloon', 157.33, 69.33, 195.0, 115.0);
  static const crownBadge = Sprite('crown_badge', 15.33, 352.0, 73.0, 414.67);
  static const routePin = Sprite('route_pin', 32.33, 546.33, 52.67, 572.67);
  static const routeClock = Sprite('route_clock', 155.33, 546.67, 176.0, 570.0);
  static const routeFlame = Sprite('route_flame', 273.67, 548.0, 293.0, 573.0);
  static const highlightScenic = Sprite('hl_scenic', 27.67, 657.67, 81.33, 711.33);
  static const highlightWater = Sprite('hl_water', 128.33, 658.0, 182.0, 712.0);
  static const highlightRest = Sprite('hl_rest', 220.33, 658.0, 274.33, 712.0);
  static const highlightSafe = Sprite('hl_safe', 318.0, 656.67, 372.33, 711.0);

  static const all = [
    logoPeaks,
    logoFlag,
    logoMove,
    logoQuest,
    splashRunner,
    pathRunner,
    chipRun,
    chipWalk,
    chipYoga,
    chipGym,
    chipCycling,
    avatar,
    flex,
    gem,
    statFire,
    statSteps,
    statPin,
    levelBadge,
    badgeGym,
    badgePark,
    badgeWater,
    questCrystal,
    questRock,
    miniPin,
    miniClock,
    miniFlame,
    homeHero,
    routeRunner,
    balloon,
    crownBadge,
    routePin,
    routeClock,
    routeFlame,
    highlightScenic,
    highlightWater,
    highlightRest,
    highlightSafe,
  ];
}
