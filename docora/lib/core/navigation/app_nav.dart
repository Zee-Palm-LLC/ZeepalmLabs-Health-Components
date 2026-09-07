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

  /// Uses Flutter [Navigator] so [Hero] flights are not killed by GetX transitions.
  static Future<T?>? hero<T>(Widget page) {
    final context = Get.context;
    if (context == null) {
      return Get.to<T>(
        () => page,
        transition: Transition.noTransition,
        duration: const Duration(milliseconds: 450),
      );
    }

    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: true,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Soft page fade; the Hero photo does the main motion.
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
            reverseCurve: const Interval(0.35, 1.0, curve: Curves.easeInCubic),
          );
          return FadeTransition(opacity: fade, child: child);
        },
      ),
    );
  }

  static void back<T>([T? result]) {
    final navigator = Get.key.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
      return;
    }
    Get.back<T>(result: result);
  }
}
