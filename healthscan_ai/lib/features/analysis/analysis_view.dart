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
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
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
              SizedBox(height: 16.h),
              AppCard(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
                radius: 20.r,
                child: Column(
                  children: [
                    SizedBox(
                      height: 190.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(child: RecommendationsSection()),
                          SizedBox(width: 10.w),
                          const Expanded(child: WeeklyImprovementChart()),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    LuxuryTap(
                      onTap: () {},
                      scale: 0.98,
                      enableHaptic: true,
                      child: Container(
                        height: 54.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF2E5BFF),
                              Color(0xFF3B82F6),
                              Color(0xFF22D3EE),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: Offset(0, 8.h),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Container(
                                width: 34.w,
                                height: 34.w,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Iconsax.document_text,
                                  size: 18.sp,
                                  color: AppColors.white,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'View Full Health Report',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 16.sp,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
