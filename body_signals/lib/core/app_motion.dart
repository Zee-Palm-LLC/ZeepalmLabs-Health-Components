import 'package:flutter/material.dart';

class AppMotion {
  const AppMotion._();

  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 340);
  static const slow = Duration(milliseconds: 560);
  static const counter = Duration(milliseconds: 1100);
  static const route = Duration(milliseconds: 480);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const emphasized = Cubic(0.2, 0.9, 0.2, 1);
  static const spring = Curves.easeOutBack;

  static Duration stagger(int index, {int step = 80, int from = 0}) =>
      Duration(milliseconds: from + index * step);
}
