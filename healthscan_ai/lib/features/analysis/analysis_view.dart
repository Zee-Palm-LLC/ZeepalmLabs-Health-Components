import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/motion/luxury_tap.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:healthscan_ai/features/analysis/widgets/analysis_app_bar.dart';
import 'package:healthscan_ai/features/analysis/widgets/body_scan_hero.dart';
import 'package:healthscan_ai/features/analysis/widgets/category_stats_row.dart';
import 'package:healthscan_ai/features/analysis/widgets/recommendations_section.dart';
import 'package:healthscan_ai/features/analysis/widgets/weekly_improvement_chart.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AnalysisAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'AI Analysis Complete',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.successText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              const BodyScanHero(),
              SizedBox(height: 16.h),
              const CategoryStatsRow(),
              SizedBox(height: 20.h),
              const RecommendationsSection(),
              SizedBox(height: 20.h),
              const WeeklyImprovementChart(),
              SizedBox(height: 20.h),
              LuxuryTap(
                onTap: () {},
                scale: 0.98,
                enableHaptic: true,
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.document_text,
                        size: 18.sp,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'View Full Health Report',
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
    );
  }
}
