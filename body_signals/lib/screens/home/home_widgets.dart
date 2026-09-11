
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';
import '../../core/app_motion.dart';
import '../../core/app_text.dart';
import '../../widgets/animations.dart';
import '../../widgets/charts.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_badge.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Good Morning', style: AppText.label()),
                      SizedBox(width: 5.w),
                      Icon(
                        Iconsax.sun_15,
                        size: 13.sp,
                        color: AppColors.amber,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text('Alex Carter', style: AppText.h1()),
                ],
              ),
            ),
            const CircleAction(icon: Iconsax.notification, badged: true),
            SizedBox(width: 10.w),
            const ProfileAvatar(),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          "Here's how your body is doing today.",
          style: AppText.caption().copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }
}

class CircleAction extends StatelessWidget {
  const CircleAction({super.key, required this.icon, this.badged = false});

  final IconData icon;
  final bool badged;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {},
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 16.sp, color: AppColors.textSecondary),
            if (badged)
              Positioned(
                top: 9.h,
                right: 10.w,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.rose,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rose.withValues(alpha: 0.7),
                        blurRadius: 6,
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

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(1.6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cyan, AppColors.violet, AppColors.magenta],
          ),
        ),
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF101A2E),
          ),
          child: Icon(Iconsax.user, size: 16.sp, color: Colors.white),
        ),
      ),
    );
  }
}


class SignalData {
  const SignalData({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.level,
    required this.rising,
    required this.good,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final double level;
  final bool rising;
  final bool good;
}

class SignalGrid extends StatelessWidget {
  const SignalGrid({super.key});

  static const signals = <SignalData>[
    SignalData(
      icon: Iconsax.flash_1,
      color: AppColors.amber,
      title: 'Energy',
      value: 'Low',
      level: 0.34,
      rising: false,
      good: false,
    ),
    SignalData(
      icon: Iconsax.tree,
      color: AppColors.green,
      title: 'Recovery',
      value: 'Good',
      level: 0.78,
      rising: true,
      good: true,
    ),
    SignalData(
      icon: Iconsax.wind,
      color: AppColors.magenta,
      title: 'Stress',
      value: 'High',
      level: 0.72,
      rising: true,
      good: false,
    ),
    SignalData(
      icon: Iconsax.moon,
      color: AppColors.indigo,
      title: 'Sleep',
      value: 'Low',
      level: 0.42,
      rising: false,
      good: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              SignalCard(data: signals[0], index: 0),
              SizedBox(height: 12.h),
              SignalCard(data: signals[2], index: 2),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            children: [
              SignalCard(data: signals[1], index: 1),
              SizedBox(height: 12.h),
              SignalCard(data: signals[3], index: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class SignalCard extends StatelessWidget {
  const SignalCard({super.key, required this.data, required this.index});

  final SignalData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final trendColor = data.good ? AppColors.green : AppColors.rose;

    return FadeSlideIn(
      delay: AppMotion.stagger(index, step: 90, from: 240),
      child: GlassCard(
        radius: 20,
        onTap: () {},
        padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        data.color.withValues(alpha: 0.28),
                        data.color.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: data.color.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Icon(data.icon, size: 14.sp, color: data.color),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: trendColor.withValues(alpha: 0.14),
                  ),
                  child: Icon(
                    data.rising ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                    size: 10.sp,
                    color: trendColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(data.title, style: AppText.caption()),
            SizedBox(height: 2.h),
            Text(data.value, style: AppText.h2()),
            SizedBox(height: 10.h),
            LevelBar(level: data.level, color: data.color),
          ],
        ),
      ),
    );
  }
}

class LevelBar extends StatelessWidget {
  const LevelBar({super.key, required this.level, required this.color});

  final double level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.r),
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: level),
              duration: const Duration(milliseconds: 1100),
              curve: AppMotion.emphasized,
              builder: (_, value, _) => Container(
                height: 4.h,
                width: constraints.maxWidth * value,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.r),
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.45), color],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      onTap: () {},
      glow: AppColors.violet,
      edgeGradient: AppColors.tintedEdge(AppColors.violet),
      padding: EdgeInsets.fromLTRB(15.w, 14.h, 15.w, 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: const LinearGradient(
                    colors: [AppColors.indigo, AppColors.violet],
                  ),
                ),
                child: Icon(
                  Iconsax.magicpen,
                  size: 14.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 11.w),
              Text('AI Insight', style: AppText.h3()),
              SizedBox(width: 8.w),
              const StatusBadge(label: 'NEW', color: AppColors.cyan),
              const Spacer(),
              Icon(
                Iconsax.arrow_right_3,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Text(
            'Your stress levels are higher than usual today. Consider a '
            'short breathing exercise or a light walk.',
            style: AppText.body().copyWith(fontSize: 10.5.sp, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 14.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.r),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.violet, AppColors.cyan],
            ),
          ),
        ),
        SizedBox(width: 9.w),
        Text(title, style: AppText.h2()),
        const Spacer(),
        if (action != null)
          PressableScale(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  action!,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.violet,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 11.sp,
                  color: AppColors.violet,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class OverviewTileData {
  const OverviewTileData({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.unit,
    required this.decimals,
    required this.series,
    required this.delta,
  });

  final IconData icon;
  final Color color;
  final String title;
  final double value;
  final String unit;
  final int decimals;
  final List<double> series;
  final String delta;
}

class OverviewTile extends StatelessWidget {
  const OverviewTile({
    super.key,
    required this.data,
    required this.index,
    this.onTap,
  });

  final OverviewTileData data;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: AppMotion.stagger(index, step: 100, from: 620),
      offset: const Offset(0.12, 0),
      child: SizedBox(
        width: 148.w,
        child: GlassCard(
          radius: 20,
          onTap: onTap,
          padding: EdgeInsets.fromLTRB(13.w, 13.h, 13.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26.w,
                    height: 26.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9.r),
                      color: data.color.withValues(alpha: 0.16),
                      border: Border.all(
                        color: data.color.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Icon(data.icon, size: 13.sp, color: data.color),
                  ),
                  SizedBox(width: 8.w),
                  Text(data.title, style: AppText.caption()),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedCountText(
                    value: data.value,
                    decimals: data.decimals,
                    style: AppText.metric().copyWith(fontSize: 19.sp),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    data.unit,
                    style: AppText.caption().copyWith(fontSize: 9.5.sp),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                data.delta,
                style: AppText.overline().copyWith(
                  color: data.color.withValues(alpha: 0.9),
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 8.h),
              Sparkline(
                values: data.series,
                color: data.color,
                size: Size(double.infinity, 30.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
