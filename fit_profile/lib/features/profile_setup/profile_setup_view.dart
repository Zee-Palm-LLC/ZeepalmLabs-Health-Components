import 'package:fit_profile/core/controllers/profile_setup_controller.dart';
import 'package:fit_profile/core/motion/app_motion.dart';
import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:fit_profile/core/theme/primary_bg.dart';
import 'package:fit_profile/features/profile_setup/widgets/age_step.dart';
import 'package:fit_profile/features/profile_setup/widgets/gender_step.dart';
import 'package:fit_profile/features/profile_setup/widgets/height_step.dart';
import 'package:fit_profile/features/profile_setup/widgets/setup_nav_bar.dart';
import 'package:fit_profile/features/profile_setup/widgets/setup_progress_bar.dart';
import 'package:fit_profile/features/profile_setup/widgets/weight_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileSetupView extends StatelessWidget {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileSetupController());

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PrimaryBg(
        child: SafeArea(
          child: Obx(() {
          final step = c.step.value;
          final stepDuration = AppMotion.dur(context, AppMotion.step);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 0),
                child: SetupProgressBar(
                  progress: c.progress,
                  onBack: c.back,
                ),
              ),
              SizedBox(height: 28.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: RepaintBoundary(
                    child: AnimatedSwitcher(
                      duration: stepDuration,
                      switchInCurve: AppMotion.curve,
                      switchOutCurve: AppMotion.curveOut,
                      transitionBuilder: (child, animation) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: AppMotion.curve,
                        );
                        final fade = Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(0, 0.85, curve: AppMotion.curve),
                          ),
                        );

                        return FadeTransition(
                          opacity: fade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.035),
                              end: Offset.zero,
                            ).animate(curved),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.97, end: 1).animate(
                                curved,
                              ),
                              child: child,
                            ),
                          ),
                        );
                      },
                      layoutBuilder: (current, previous) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            ...previous,
                            ?current,
                          ],
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(step),
                        child: _buildStep(c, step),
                      ),
                    ),
                  ),
                ),
              ),
              SetupNavBar(
                isLast: step == ProfileSetupController.totalSteps - 1,
                onNext: () {
                  if (step == ProfileSetupController.totalSteps - 1) {
                    Get.snackbar(
                      'Profile ready',
                      'Gender · Age · Weight · Height saved',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.surface,
                      colorText: AppColors.title,
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12.r,
                      animationDuration: AppMotion.normal,
                    );
                  } else {
                    c.next();
                  }
                },
              ),
            ],
          );
          }),
        ),
      ),
    );
  }

  Widget _buildStep(ProfileSetupController c, int step) {
    switch (step) {
      case 0:
        return GenderStep(
          selected: c.gender.value,
          onChanged: c.setGender,
        );
      case 1:
        return AgeStep(
          age: c.age.value,
          onChanged: c.setAge,
        );
      case 2:
        return WeightStep(
          weightKg: c.weightKg.value,
          onChanged: c.setWeight,
        );
      case 3:
      default:
        return HeightStep(
          heightCm: c.heightCm.value,
          onChanged: c.setHeight,
        );
    }
  }
}
