import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract final class AppNav {
  static Future<T?>? to<T>(Widget page) {
    return Get.to<T>(
      () => page,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  static Future<T?>? up<T>(Widget page) {
    return Get.to<T>(
      () => page,
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  static void back<T>([T? result]) => Get.back<T>(result: result);
}
