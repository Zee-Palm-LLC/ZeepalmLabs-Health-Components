import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vital_heart/core/motion/luxury_tap.dart';
import 'package:vital_heart/core/motion/stagger_column.dart';
import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:vital_heart/core/theme/primary_bg.dart';
import 'package:vital_heart/features/heart_analytics/heart_analytics_view.dart';
import 'package:vital_heart/features/heart_rate/widgets/ecg_waveform.dart';
import 'package:vital_heart/features/heart_rate/widgets/heart_hero_card.dart';
import 'package:vital_heart/features/heart_rate/widgets/heart_home_stats.dart';
import 'package:vital_heart/features/shared/widgets/heart_app_bar.dart';

class HeartRateView extends StatelessWidget {
  const HeartRateView({super.key});

  void _openAnalytics() {
    Get.to(() => const HeartAnalyticsView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      appBar: HeartAppBar(title: 'Heart Rate'),
      body: PrimaryBg(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: StaggerColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HeartHeroCard(),
                SizedBox(height: 16.h),
                const HeartHomeStats(),
                SizedBox(height: 16.h),
                Column(
                  children: [
                    Row(
                      children: [
                        _LiveDot(),
                        SizedBox(width: 8.w),
                        Text(
                          'ECG Waveform',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtitle,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Real-time',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    const EcgWaveform(),
                  ],
                ),
                SizedBox(height: 16.h),
                LuxuryTap(
                  onTap: _openAnalytics,
                  scale: 0.98,
                  enableHaptic: true,
                  child: Container(
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.heartGlow,
                          AppColors.accent,
                          AppColors.accentDeep,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.38),
                          blurRadius: 20,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Analytics',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(
                  alpha: 0.3 + _controller.value * 0.5,
                ),
                blurRadius: 6,
              ),
            ],
          ),
        );
      },
    );
  }
}
