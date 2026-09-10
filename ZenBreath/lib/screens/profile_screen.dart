import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/app_data.dart';
import 'home_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/gold_button.dart';
import '../widgets/count_up_text.dart';
import '../widgets/motion.dart';
import '../widgets/shimmer_sweep.dart';
import '../widgets/section_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AppTopBar(title: 'Profile & Settings'),
      body: StaggeredList(
        padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 22.h),
        children: [
          const _ProfileIdentity(),
          SizedBox(height: 16.h),
          const _DailyGoalCard(),
          SizedBox(height: 12.h),
          const _SettingsGroup(rows: kPreferenceRows),
          SizedBox(height: 12.h),
          const _SettingsGroup(rows: kSupportRows),
          SizedBox(height: 18.h),
          GoldButton(
            label: 'Manage Premium',
            leadingIcon: LucideIcons.crown,
            height: 48.h,
            fontSize: 16,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarBadge(diameter: 58.r),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sarah Khan', style: AppText.body(19, weight: FontWeight.w600)),
              SizedBox(height: 1.h),
              Text(
                'sarah.khan@gmail.com',
                style: AppText.body(12.5, color: AppColors.textSecondary),
              ),
              SizedBox(height: 7.h),
              const _PremiumBadge(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return ShimmerSweep(
      period: const Duration(milliseconds: 5200),
      strength: 0.45,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.goldWash,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.crown, size: 13.r, color: AppColors.goldDark),
            SizedBox(width: 5.w),
            Text(
              'Premium Member',
              style: AppText.body(11, weight: FontWeight.w500, color: AppColors.textOnGold),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard();

  static const _progress = 5 / 7;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.all(13.w),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: AppColors.blueWash,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(LucideIcons.target, size: 18.r, color: AppColors.blueDeep),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Daily Goal',
                        style: AppText.body(14.5, weight: FontWeight.w600),
                      ),
                    ),
                    CountUpText(
                      value: 5,
                      prefix: '(',
                      suffix: ' of 7 days)',
                      style: AppText.body(11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '10 min meditation',
                  style: AppText.body(11.5, color: AppColors.textSecondary),
                ),
                SizedBox(height: 7.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 4.h,
                      backgroundColor: AppColors.track,
                      valueColor: const AlwaysStoppedAnimation(AppColors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});

  final List<SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Entrance(
              delay: AppMotion.stagger * i,
              offset: 10,
              child: _SettingsTile(row: rows[i]),
            ),
            if (i != rows.length - 1) Divider(height: 1, thickness: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.row});

  final SettingsRow row;

  @override
  Widget build(BuildContext context) {
    final lines = row.value?.split('\n') ?? const <String>[];

    return SizedBox(
      height: 50.h,
      child: Row(
        children: [
          Icon(row.icon, size: 19.r, color: AppColors.blueDeep),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(row.title, style: AppText.body(13.5, weight: FontWeight.w500)),
          ),
          if (lines.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(lines.first, style: AppText.body(11.5, color: AppColors.textSecondary)),
                if (lines.length > 1)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lines[1], style: AppText.body(11.5, color: row.valueColor)),
                      if (row.showDot) ...[
                        SizedBox(width: 4.w),
                        Container(
                          width: 5.r,
                          height: 5.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          if (row.showChevron)
            Icon(LucideIcons.chevronRight, size: 17.r, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
