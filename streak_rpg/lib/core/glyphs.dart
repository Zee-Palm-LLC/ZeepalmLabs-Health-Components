import 'package:flutter/widgets.dart';

abstract final class Ph {
  static const arrowLeft = IconData(0xe058, fontFamily: 'PhosphorBold');
  static const arrowRight = IconData(0xe06c, fontFamily: 'PhosphorBold');
  static const arrowUpRight = IconData(0xe092, fontFamily: 'PhosphorBold');
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold');
  static const caretRight = IconData(0xe13a, fontFamily: 'PhosphorBold');
  static const gear = IconData(0xe270, fontFamily: 'PhosphorFill');
  static const pause = IconData(0xe39e, fontFamily: 'PhosphorFill');
  static const play = IconData(0xe3d0, fontFamily: 'PhosphorFill');
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const trophy = IconData(0xe67e, fontFamily: 'PhosphorFill');
  static const users = IconData(0xe4d6, fontFamily: 'PhosphorFill');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorFill');
  static const star = IconData(0xe46a, fontFamily: 'PhosphorFill');
  static const gift = IconData(0xe276, fontFamily: 'PhosphorFill');
  static const sparkle = IconData(0xe6a2, fontFamily: 'PhosphorFill');
  static const heart = IconData(0xe2a8, fontFamily: 'PhosphorFill');
  static const lightning = IconData(0xe2de, fontFamily: 'PhosphorFill');
  static const question = IconData(0xe3e8, fontFamily: 'PhosphorBold');
}

class PhIcon extends StatelessWidget {
  const PhIcon(this.icon, {super.key, this.size = 24, this.color = const Color(0xFFFFFFFF), this.shadows});

  final IconData icon;
  final double size;
  final Color color;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(fontFamily: icon.fontFamily, fontSize: size, height: 1, color: color, shadows: shadows, leadingDistribution: TextLeadingDistribution.even),
          textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
        ),
      ),
    );
  }
}

/// Art cut from the mockup. Each entry keeps the pt rect it occupied on its screen.
class Art {
  const Art(this.name, this.x, this.y, this.w, this.h);

  final String name;
  final double x;
  final double y;
  final double w;
  final double h;

  String get path => 'assets/art/$name.webp';

  Rect get rect => Rect.fromLTWH(x, y, w, h);

  Image image({BoxFit fit = BoxFit.fill}) => Image.asset(path, width: w, height: h, fit: fit, filterQuality: FilterQuality.medium, gaplessPlayback: true);

  static const logo = Art('logo', 89.33, 42.00, 233.00, 148.00);
  static const heroSplash = Art('hero_splash', 14.00, 295.67, 388.00, 488.67);
  static const heroPushup = Art('hero_pushup', 35.67, 318.00, 334.67, 271.00);
  static const iconDumbbell = Art('icon_dumbbell', 56.33, 274.00, 64.67, 55.33);
  static const iconArrow = Art('icon_arrow', 296.33, 261.00, 38.67, 51.00);
  static const iconStar = Art('icon_star', 322.00, 340.00, 51.67, 52.00);
  static const heroHome = Art('hero_home', 175.33, 237.00, 131.67, 299.00);
  static const gift = Art('gift', 326.67, 522.00, 58.00, 59.00);
  static const heroWorkout = Art('hero_workout', 140.00, 183.33, 316.00, 142.67);
  static const chestPedestal = Art('chest_pedestal', 21.33, 164.33, 201.33, 252.67);
  static const avatar = Art('avatar', 22.00, 58.00, 64.33, 64.33);
  static const shieldGold = Art('shield_gold', 30.67, 144.00, 66.00, 76.67);
  static const fire = Art('fire', 315.67, 69.33, 31.67, 39.00);
  static const icWorkouts = Art('ic_workouts', 33.00, 399.33, 28.00, 27.67);
  static const icTimer = Art('ic_timer', 31.67, 464.00, 29.67, 31.33);
  static const icCalories = Art('ic_calories', 33.67, 531.00, 26.00, 32.00);
  static const navHome = Art('nav_home', 42.33, 686.00, 34.33, 32.00);
  static const shieldPurple = Art('shield_purple', 55.33, 97.33, 62.67, 76.67);
  static const chestSmall = Art('chest_small', 334.67, 112.00, 50.00, 44.67);
  static const icBolt = Art('ic_bolt', 89.00, 344.00, 24.67, 35.33);
  static const icSets = Art('ic_sets', 264.33, 347.33, 27.67, 27.33);
  static const icFlame = Art('ic_flame', 450.00, 342.00, 27.67, 37.00);
  static const icWater = Art('ic_water', 266.00, 191.67, 33.00, 45.00);
  static const icShoe = Art('ic_shoe', 258.33, 266.00, 50.00, 44.67);
  static const icDumbbell = Art('ic_dumbbell', 257.33, 340.00, 51.33, 44.33);
  static const trophy = Art('trophy', 244.33, 436.00, 38.00, 32.67);

  static const bgSplash = 'assets/art/bg_splash.webp';
  static const bgOnboard = 'assets/art/bg_onboard.webp';
  static const bgHome = 'assets/art/bg_home.webp';
  static const bgWorkout = 'assets/art/bg_workout.webp';

  static const all = [
    logo, heroSplash, heroPushup, iconDumbbell, iconArrow, iconStar, heroHome, gift, heroWorkout, chestPedestal, avatar, shieldGold, fire, //
    icWorkouts, icTimer, icCalories, navHome, shieldPurple, chestSmall, icBolt, icSets, icFlame, icWater, icShoe, icDumbbell, trophy,
  ];

  static const plates = [bgSplash, bgOnboard, bgHome, bgWorkout];

  static Future<void> warm(BuildContext context) async {
    await Future.wait([for (final a in all) precacheImage(AssetImage(a.path), context), for (final p in plates) precacheImage(AssetImage(p), context)]);
  }
}
