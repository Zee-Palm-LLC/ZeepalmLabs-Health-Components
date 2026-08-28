import 'package:aira_health/voice/symptom_voice_view.dart';
import 'package:aira_health/dashboard/widgets/ai_insight_card.dart';
import 'package:aira_health/dashboard/widgets/daily_focus_card.dart';
import 'package:aira_health/dashboard/widgets/dashboard_ambient_glow.dart';
import 'package:aira_health/dashboard/widgets/dashboard_header.dart';
import 'package:aira_health/dashboard/widgets/health_check_fab.dart';
import 'package:aira_health/dashboard/widgets/health_stats_row.dart';
import 'package:aira_health/dashboard/widgets/plan_hero_card.dart';
import 'package:aira_health/dashboard/widgets/quick_access_section.dart';
import 'package:aira_health/dashboard/widgets/quick_action_pills.dart';
import 'package:aira_health/dashboard/widgets/recent_activity_section.dart';
import 'package:aira_health/dashboard/widgets/upcoming_reminder_card.dart';
import 'package:aira_health/dashboard/widgets/weekly_health_chart.dart';
import 'package:aira_health/dashboard/widgets/wellness_banner.dart';
import 'package:aira_health/onboarding/components/fade_reveal.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.avatarAsset,
  });

  final String avatarAsset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButton: FadeReveal(
        delay: const Duration(milliseconds: 380),
        offsetY: 16,
        child: HealthCheckFab(
          onPressed: () {
            Get.to(
              () => const SymptomVoiceView(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 360),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: PrimaryBg(
        child: Stack(
          children: [
            const DashboardAmbientGlow(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                child: Column(
                  children: [
                    FadeReveal(
                      delay: Duration.zero,
                      duration: const Duration(milliseconds: 420),
                      child: DashboardHeader(avatarAsset: avatarAsset),
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 100.h),
                        child: Column(
                          children: [
                            const FadeReveal(
                              delay: Duration(milliseconds: 40),
                              child: QuickActionPills(),
                            ),
                            SizedBox(height: 14.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 70),
                              child: WellnessBanner(),
                            ),
                            SizedBox(height: 14.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 110),
                              child: DailyFocusCard(),
                            ),
                            SizedBox(height: 14.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 150),
                              child: HealthStatsRow(),
                            ),
                            SizedBox(height: 14.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 190),
                              child: WeeklyHealthChart(),
                            ),
                            SizedBox(height: 14.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 230),
                              child: UpcomingReminderCard(),
                            ),
                            SizedBox(height: 14.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 270),
                              child: PlanHeroCard(),
                            ),
                            SizedBox(height: 14.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 310),
                              child: AiInsightCard(),
                            ),
                            SizedBox(height: 22.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 350),
                              child: QuickAccessSection(),
                            ),
                            SizedBox(height: 22.h),
                            const FadeReveal(
                              delay: Duration(milliseconds: 390),
                              child: RecentActivitySection(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
