import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/bottom_action_bar.dart';
import '../../core/widgets/fitonist_logo.dart';
import '../../core/widgets/page_dots.dart';
import '../../core/widgets/primary_button.dart';
import 'onboarding_controller.dart';
import 'widgets/luxury_page_physics.dart';
import 'widgets/onboarding_copy.dart';
import 'widgets/onboarding_hero.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  static const _pages = [
    _OnboardingData(
      title: 'Gym workout generator',
      description:
          'Get workouts with real-time tracking, heart rate monitoring and personalised experience',
      imageAsset: AppAssets.onboardingOne,
      glowColor: Color(0xFF7C5CFF),
    ),
    _OnboardingData(
      title: 'Your Workout Plan',
      description:
          'The personalised plans, real-time tracking, and motivating reminders have truly transformed my fitness journey.',
      imageAsset: AppAssets.onboardingTwo,
      glowColor: Color(0xFF3B82F6),
      heroRadius: 24,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _BlendedAmbient(pageController: controller.pageController),
            Column(
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 10.h),
                _EntranceLayer(
                  animation: controller.entranceInterval(0, 0.38),
                  offset: const Offset(0, -0.18),
                  child: const FitonistLogo(),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: _EntranceLayer(
                    animation: controller.entranceInterval(0.14, 0.62),
                    offset: const Offset(0, 0.12),
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: controller.pageController,
                            builder: (context, _) {
                              final page = controller.pageController.hasClients
                                  ? (controller.pageController.page ??
                                      controller.currentPage.value.toDouble())
                                  : controller.currentPage.value.toDouble();

                              return PageView.builder(
                                controller: controller.pageController,
                                physics: const LuxuryPageScrollPhysics(),
                                onPageChanged: controller.onPageChanged,
                                itemCount: _pages.length,
                                itemBuilder: (context, index) {
                                  final data = _pages[index];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                    ),
                                    child: FloatingHeroWrapper(
                                      child: OnboardingHero(
                                        imageAsset: data.imageAsset,
                                        glowColor: data.glowColor,
                                        heroRadius: data.heroRadius,
                                        pageOffset: page - index,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(() {
                          final index = controller.currentPage.value
                              .clamp(0, _pages.length - 1);
                          final data = _pages[index];

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 580),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (current, previous) => Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                ...previous,
                                ?current,
                              ],
                            ),
                            transitionBuilder: (child, animation) {
                              final curved = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              );
                              return FadeTransition(
                                opacity: curved,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(curved),
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.96,
                                      end: 1,
                                    ).animate(curved),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: OnboardingCopy(
                              key: ValueKey(data.title),
                              title: data.title,
                              description: data.description,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _EntranceLayer(
                  animation: controller.entranceInterval(0.52, 0.82),
                  offset: const Offset(0, 0.08),
                  child: AnimatedBuilder(
                    animation: controller.pageController,
                    builder: (context, _) {
                      final page = controller.pageController.hasClients
                          ? (controller.pageController.page ??
                              controller.currentPage.value.toDouble())
                          : controller.currentPage.value.toDouble();

                      return Obx(
                        () => PageDots(
                          count: OnboardingController.pageCount,
                          activeIndex: controller.currentPage.value,
                          scrollPage: page,
                        ),
                      );
                    },
                  ),
                ),
                _EntranceLayer(
                  animation: controller.entranceInterval(
                    0.64,
                    1,
                    curve: Curves.easeOutQuart,
                  ),
                  offset: const Offset(0, 0.28),
                  child: BottomActionBar(
                    children: [
                      PrimaryButton(
                        label: 'Get started',
                        onPressed: controller.goToAboutYou,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlendedAmbient extends StatelessWidget {
  const _BlendedAmbient({required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final page = pageController.hasClients
            ? (pageController.page ?? 0).clamp(0.0, 1.0)
            : 0.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - page,
              child: const AmbientBackground(
                variant: AmbientVariant.onboardingOne,
              ),
            ),
            Opacity(
              opacity: page,
              child: const AmbientBackground(
                variant: AmbientVariant.onboardingTwo,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EntranceLayer extends StatelessWidget {
  const _EntranceLayer({
    required this.animation,
    required this.offset,
    required this.child,
  });

  final Animation<double> animation;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - animation.value) * 24.w,
              offset.dy * (1 - animation.value) * 24.h,
            ),
            child: Transform.scale(
              scale: 0.94 + (animation.value * 0.06),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.glowColor,
    this.heroRadius = 0,
  });

  final String title;
  final String description;
  final String imageAsset;
  final Color glowColor;
  final double heroRadius;
}
