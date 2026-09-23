import 'package:flutter/animation.dart';

class Motion {
  Motion._();

  static const Duration micro = Duration(milliseconds: 140);
  static const Duration quick = Duration(milliseconds: 260);
  static const Duration medium = Duration(milliseconds: 420);
  static const Duration slow = Duration(milliseconds: 680);
  static const Duration reveal = Duration(milliseconds: 900);

  static const Curve enter = Cubic(0.16, 0.84, 0.24, 1.0);
  static const Curve exit = Cubic(0.4, 0.0, 0.6, 1.0);
  static const Curve glide = Cubic(0.33, 0.0, 0.0, 1.0);
  static const Curve breathe = Curves.easeInOutSine;
}
