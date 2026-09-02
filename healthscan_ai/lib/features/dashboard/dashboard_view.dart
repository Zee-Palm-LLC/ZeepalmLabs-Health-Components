import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:healthscan_ai/core/motion/dashboard_motion.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/features/dashboard/widgets/daily_activity_card.dart';
import 'package:healthscan_ai/features/dashboard/widgets/dashboard_app_bar.dart';
import 'package:healthscan_ai/features/dashboard/widgets/dashboard_bottom_nav.dart';
import 'package:healthscan_ai/features/dashboard/widgets/dashboard_period_bar.dart';
import 'package:healthscan_ai/features/dashboard/widgets/health_score_hero.dart';
import 'package:healthscan_ai/features/dashboard/widgets/quick_actions_row.dart';
import 'package:healthscan_ai/features/dashboard/widgets/vital_signs_grid.dart';
import 'package:healthscan_ai/features/dashboard/widgets/water_intake_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const DashboardAppBar(),
      body: DashboardMotionScope(
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MotionEntrance(
                index: 0,
                child: DashboardPeriodBar(),
              ),
              SizedBox(height: 16.h),
              const MotionEntrance(
                index: 1,
                child: HealthScoreHero(),
              ),
              SizedBox(height: 16.h),
              const MotionEntrance(
                index: 2,
                child: VitalSignsGrid(),
              ),
              SizedBox(height: 16.h),
              const MotionEntrance(
                index: 3,
                child: DailyActivityCard(),
              ),
              SizedBox(height: 16.h),
              const MotionEntrance(
                index: 4,
                child: WaterIntakeCard(),
              ),
              SizedBox(height: 20.h),
              MotionEntrance(
                index: 5,
                slide: 10,
                child: QuickActionsRow(onScanTap: () {}),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(onScanTap: () {}),
    );
  }
}
