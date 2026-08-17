import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController
    with GetTickerProviderStateMixin {
  late final PageController pageController;
  late final AnimationController entranceController;

  final currentPage = 0.obs;

  static const pageCount = 5;
  static const _entranceDuration = Duration(milliseconds: 1800);

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.9);
    entranceController = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    );

    if (Get.testMode) {
      entranceController.value = 1;
    } else {
      entranceController.forward();
    }
  }

  void onPageChanged(int index) => currentPage.value = index;

  void goToAboutYou() => Get.toNamed('/about-you');

  Animation<double> entranceInterval(
    double begin,
    double end, {
    Curve curve = Curves.easeOutCubic,
  }) {
    return CurvedAnimation(
      parent: entranceController,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  void onClose() {
    entranceController.dispose();
    pageController.dispose();
    super.onClose();
  }
}
