import 'package:get/get.dart';

import '../features/about_you/about_you_screen.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/onboarding/onboarding_screen.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static const initial = AppRoutes.onboarding;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.onboarding,
      page: OnboardingScreen.new,
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: AppRoutes.aboutYou,
      page: AboutYouScreen.new,
    ),
  ];
}
