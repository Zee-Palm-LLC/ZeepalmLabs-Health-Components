import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vital_heart/core/controllers/heart_controller.dart';
import 'package:vital_heart/core/motion/app_motion.dart';
import 'package:vital_heart/core/motion/luxury_tap.dart';
import 'package:vital_heart/core/motion/stagger_column.dart';
import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:vital_heart/core/theme/app_text_styles.dart';
import 'package:vital_heart/core/theme/primary_bg.dart';
import 'package:vital_heart/features/heart_analytics/widgets/heart_bar_chart.dart';
import 'package:vital_heart/features/heart_analytics/widgets/history_card.dart';
import 'package:vital_heart/features/heart_analytics/widgets/period_segment.dart';
import 'package:vital_heart/features/shared/widgets/heart_app_bar.dart';

class HeartAnalyticsView extends StatelessWidget {
  const HeartAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HeartController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      appBar: HeartAppBar(
        title: 'Heart Analytics',
        showBack: true,
        onBack: Get.back,
      ),
      body: PrimaryBg(
        child: SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: StaggerColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PeriodSegment(
                    selected: c.period.value,
                    onChanged: c.setPeriod,
                  ),
                  SizedBox(height: 16.h),
                  Text(c.periodLabel, style: AppTextStyles.sectionTitle),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Average',
                          value: '${c.averageBpm}',
                          unit: 'BPM',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatCard(
                          label: 'Max',
                          value: '${c.maxBpm}',
                          unit: 'BPM',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  HeartBarChart(
                    key: ValueKey(c.period.value),
                    values: c.chartBars,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text('Tue, March 26', style: AppTextStyles.sectionTitle),
                      const Spacer(),
                      LuxuryTap(
                        onTap: () {},
                        child: Text(
                          'See All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  for (var i = 0; i < HeartController.history.length; i++)
                    HistoryCard(
                      record: HeartController.history[i],
                      index: i,
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.curve,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: StatBlock(label: label, value: value, unit: unit),
    );
  }
}
