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

  Sprite shift(double dx, double dy) => Sprite(name, left + dx, top + dy, width, height);

  Widget image({BoxFit fit = BoxFit.fill}) =>
      Image.asset(asset, width: width, height: height, fit: fit, filterQuality: FilterQuality.medium, gaplessPlayback: true);

  Widget place({double dx = 0, double dy = 0}) => Positioned(left: left + dx, top: top + dy, width: width, height: height, child: image());
}

abstract final class Art {
  static const splashPlate = Sprite('splash_plate', 0.0, 0.0, 392.67, 903.33);
  static const splashMascot = Sprite('splash_mascot', 38.33, 331.33, 354.67, 426.0);
  static const pickPlate = Sprite('pick_plate', 19.0, 240.0, 358.0, 183.33);
  static const pickMascot = Sprite('pick_mascot', 190.0, 240.0, 187.33, 183.33);
  static const homeAvatar = Sprite('home_avatar', 324.67, 66.33, 51.67, 51.67);
  static const catBreakfast = Sprite('cat_breakfast', 37.0, 465.67, 40.33, 39.33);
  static const catLunch = Sprite('cat_lunch', 131.67, 466.33, 39.67, 39.0);
  static const catDinner = Sprite('cat_dinner', 225.33, 467.33, 40.67, 35.33);
  static const catSnacks = Sprite('cat_snacks', 321.33, 466.33, 36.67, 39.33);
  static const photoPasta = Sprite('photo_pasta', 20.5, 606.5, 171.67, 104.0);
  static const photoPancakes = Sprite('photo_pancakes', 205.2, 606.5, 171.67, 104.0);
  static const detailHero = Sprite('detail_hero', 0.0, 0.0, 393.0, 330.0);
  static const detailBowl = Sprite('detail_bowl', 6.0, 243.67, 308.67, 69.0);
  static const detailBasil = Sprite('detail_basil', 346.0, 322.33, 31.0, 29.67);
  static const nutFlame = Sprite('nut_flame', 32.0, 492.67, 26.0, 35.33);
  static const nutProtein = Sprite('nut_protein', 159.33, 492.33, 26.67, 36.33);
  static const nutCarbs = Sprite('nut_carbs', 285.33, 492.0, 26.67, 37.33);
  static const ingPasta = Sprite('ing_pasta', 21.27, 591.67, 45.0, 45.0);
  static const ingCream = Sprite('ing_cream', 21.27, 628.27, 45.0, 45.0);
  static const ingParmesan = Sprite('ing_parmesan', 21.27, 665.17, 45.0, 45.0);
  static const ingGarlic = Sprite('ing_garlic', 21.27, 702.17, 45.0, 45.0);
  static const ingOil = Sprite('ing_oil', 21.27, 736.2, 45.0, 47.67);
  static const profAvatar = Sprite('prof_avatar', 118.67, 64.67, 157.0, 164.0);
  static const profBasilA = Sprite('prof_basil_a', 65.33, 72.33, 34.67, 35.0);
  static const profBasilB = Sprite('prof_basil_b', 325.67, 211.33, 31.33, 32.0);
  static const profPlate = Sprite('prof_plate', 0.0, 0.0, 392.67, 322.0);
  static const profTomato = Sprite('prof_tomato', 0.0, 84.0, 37.33, 62.0);
  static const profPepper = Sprite('prof_pepper', 0.0, 202.0, 66.0, 74.0);
  static const profBlobA = Sprite('prof_blob_a', 347.33, 125.67, 45.67, 101.67);
  static const profBlobB = Sprite('prof_blob_b', 320.0, 252.67, 73.0, 71.33);
  static const profCrown = Sprite('prof_crown', 35.33, 430.0, 53.33, 53.33);
  static const toss0 = Sprite('toss_0', 326.0, 488.33, 56.0, 95.67);
  static const toss1 = Sprite('toss_1', 333.33, 441.66, 43.67, 41.33);
  static const toss2 = Sprite('toss_2', 315.0, 406.33, 31.33, 38.67);
  static const toss3 = Sprite('toss_3', 315.0, 532.0, 18.67, 36.33);
  static const toss4 = Sprite('toss_4', 315.0, 500.66, 18.67, 30.0);
  static const toss5 = Sprite('toss_5', 370.33, 470.33, 15.67, 17.0);
  static const toss6 = Sprite('toss_6', 369.67, 541.0, 16.67, 14.67);
  static const toss7 = Sprite('toss_7', 315.67, 460.0, 12.67, 10.67);
  static const toss8 = Sprite('toss_8', 334.67, 483.33, 7.0, 7.0);

  static const toss = [toss0, toss1, toss2, toss3, toss4, toss5, toss6, toss7, toss8];
}
