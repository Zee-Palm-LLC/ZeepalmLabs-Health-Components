import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/bottom_action_bar.dart';
import '../../core/widgets/content_width.dart';
import '../../core/widgets/primary_button.dart';
import 'widgets/name_input_field.dart';
import 'widgets/welcome_banner.dart';

class AboutYouScreen extends StatefulWidget {
  const AboutYouScreen({super.key});

  @override
  State<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  final _nameController = TextEditingController(text: 'Jane');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
            const AmbientBackground(variant: AmbientVariant.aboutYou),
            Column(
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 4.h),
                const _ProgressBar(progress: 0.25),
                SizedBox(
                  height: 52.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        _GlassIconButton(
                          icon: Iconsax.arrow_left,
                          onPressed: Get.back,
                        ),
                        Expanded(
                          child: Text(
                            'About You',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.navTitle,
                          ),
                        ),
                        SizedBox(width: 44.w),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: ContentWidth(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'What is your name?',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.formHeadline,
                                ),
                                SizedBox(height: 14.h),
                                Text(
                                  "Whether it's celebrating achievements, inspiring others, sharing your fitness journey to encourage our community",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body,
                                ),
                                SizedBox(height: 48.h),
                                Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.topCenter,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 40.h),
                                      child: NameInputField(
                                        controller: _nameController,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    Container(
                                      width: 72.w,
                                      height: 72.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.textPrimary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.background,
                                          width: 4.w,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accentPurple
                                                .withValues(alpha: 0.35),
                                            blurRadius: 24,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '👋',
                                        style: TextStyle(fontSize: 32.sp),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 260),
                                  switchInCurve: Curves.easeOutCubic,
                                  child: WelcomeBanner(
                                    key: ValueKey(_nameController.text),
                                    name: _nameController.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                BottomActionBar(
                  children: [
                    PrimaryButton(
                      label: 'Next',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.65),
      shape: CircleBorder(
        side: BorderSide(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44.w,
          height: 44.w,
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.r),
        child: SizedBox(
          height: 3.h,
          child: Row(
            children: [
              Expanded(
                flex: (progress * 100).round().clamp(1, 100),
                child: const ColoredBox(color: AppColors.textPrimary),
              ),
              Expanded(
                flex: ((1 - progress) * 100).round().clamp(1, 100),
                child: const ColoredBox(color: AppColors.progressTrack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
