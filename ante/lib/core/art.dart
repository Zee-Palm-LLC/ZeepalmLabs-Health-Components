import 'package:flutter/widgets.dart';

class Sprite {
  const Sprite(this.name, this.left, this.top, this.width, this.height);

  final String name;
  final double left;
  final double top;
  final double width;
  final double height;

  String get asset => 'assets/art/$name.webp';

  Offset get center => Offset(left + width / 2, top + height / 2);

  Rect get rect => Rect.fromLTWH(left, top, width, height);

  Widget image({BoxFit fit = BoxFit.fill}) =>
      Image.asset(asset, width: width, height: height, fit: fit, filterQuality: FilterQuality.medium, gaplessPlayback: true);
}

abstract final class Art {
  static const onboardPlate = Sprite('onboard_plate', 0, 0, 393, 917);
  static const trophy = Sprite('hero_trophy', 116.0, 99.67, 170.33, 262.0);
  static const ticket = Sprite('hero_ticket', 31.33, 207.0, 153.67, 130.0);
  static const dumbbell = Sprite('hero_dumbbell', 249.0, 192.0, 121.67, 140.33);
  static const billTopLeft = Sprite('hero_bill_tl', 54.67, 127.67, 71.33, 61.67);
  static const billTopRight = Sprite('hero_bill_tr', 296.0, 141.67, 70.0, 41.67);
  static const billLowLeft = Sprite('hero_bill_bl', 92.33, 315.0, 80.67, 57.67);
  static const billLowRight = Sprite('hero_bill_br', 238.33, 310.0, 75.67, 67.33);
  static const coinTopRight = Sprite('hero_coin_tr', 301.33, 116.0, 25.0, 32.33);
  static const coinLeft = Sprite('hero_coin_l', 25.0, 201.33, 31.0, 28.33);
  static const coinLow = Sprite('hero_coin_b', 190.67, 312.33, 50.33, 46.67);

  static const oTrophy = Sprite('o_trophy', 41.15, 755.38, 32, 32);
  static const oFlame = Sprite('o_flame', 158.73, 758.8, 32, 32);
  static const oPeople = Sprite('o_people', 282.63, 755.92, 36, 36);

  static const streakPlate = Sprite('streak_plate', 11.2, 112.0, 371.8, 199.4);
  static const streakRunner = Sprite('streak_runner', 185.2, 134.0, 166.67, 176.33);
  static const gDumbbell = Sprite('g_dumbbell_blue', 36.79, 471.54, 46, 46);
  static const gRun = Sprite('g_run_green', 36.89, 544.29, 46, 46);
  static const gBook = Sprite('g_book', 37.6, 619.13, 46, 46);
  static const sBag = Sprite('s_bag', 17.42, 726.01, 44, 44);
  static const sFlame = Sprite('s_flame', 211.6, 728.16, 44, 44);
  static const sPeople = Sprite('s_people', 20.07, 796.29, 44, 44);
  static const sWarn = Sprite('s_warn', 212.49, 800.67, 44, 44);

  static const trioPlate = Sprite('trio_plate', 0, 0, 393, 330);
  static const trio = Sprite('trio', 41.67, 100.67, 289.33, 206.67);
  static const cDumbbell = Sprite('c_dumbbell', 31.76, 344.72, 48, 48);
  static const cCoins = Sprite('c_coins', 32.8, 446.79, 48, 48);
  static const cUsers = Sprite('c_users', 34.04, 627.98, 48, 48);
  static const cHeart = Sprite('c_heart', 33.39, 740.81, 48, 48);
  static const cCharity = Sprite('c_acs', 111.0, 787.78, 30, 30);

  static const clubPlate = Sprite('club_plate', 0, 0, 393, 298);
  static const clubRunner = Sprite('club_runner', 225.33, 94.67, 98.33, 160.67);
  static const dRun = Sprite('d_run', 25.6, 180.84, 54, 54);

  static const crownLogo = Sprite('crown_logo', 22.11, 64.66, 28, 28);
  static const crownName = Sprite('crown_john', 197.45, 84.52, 24, 24);

  static const fire = 'assets/art/emoji_fire.webp';
  static const biceps = 'assets/art/emoji_biceps.webp';
  static const crown = 'assets/art/emoji_crown.webp';

  static String avatar(String name) => 'assets/art/av_$name.webp';
}
