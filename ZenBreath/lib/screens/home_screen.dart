import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/app_image.dart';
import '../widgets/count_up_text.dart';
import '../widgets/glow_orb.dart';
import '../widgets/motion.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_card.dart';
import '../widgets/sparkline.dart';
import 'breathing_session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _headerHeight = 378.0;
  final ValueNotifier<double> _offset = ValueNotifier(0);

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      _offset.value = notification.metrics.pixels;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GreetingBar(offset: _offset, headerHeight: _headerHeight.h),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: StaggeredList(
          padding: EdgeInsets.only(bottom: 22.h),
          children: [
            SizedBox(
              height: _headerHeight.h,
              child: _HomeHeader(offset: _offset),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const _StatGrid(),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Quick Start', style: AppText.sectionTitle()),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const _QuickStartTile(),
            ),
          ],
        ),
      ),
    );
  }
}

class GreetingBar extends StatelessWidget implements PreferredSizeWidget {
  const GreetingBar({super.key, required this.offset, required this.headerHeight});
  final ValueListenable<double> offset;
  final double headerHeight;
  static const _height = 74.0;

  @override
  Size get preferredSize => Size.fromHeight(_height.h);

  @override
  Widget build(BuildContext context) {
    final fadeStart = headerHeight * 0.45;

    return ValueListenableBuilder<double>(
      valueListenable: offset,
      builder: (context, value, child) {
        final t = ((value - fadeStart) / (headerHeight - fadeStart)).clamp(0.0, 1.0);

        return AppBar(
          toolbarHeight: _height.h,
          backgroundColor: const Color(0xFFF6FAFD).withValues(alpha: t),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 20.w,
          title: child,
          actions: [
            AvatarBadge(diameter: 38.r),
            SizedBox(width: 20.w),
          ],
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Good morning,', style: AppText.body(15.5, color: AppColors.textSecondary)),
          SizedBox(height: 1.h),
          Text('Sarah', style: AppText.display(32, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({super.key, required this.diameter});
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: (diameter * 0.045).r),
        boxShadow: AppShadows.card,
      ),
      child: ClipOval(
        child: AppImage(
          source: AppImages.avatar,
          fallback: const [Color(0xFFD8C4B0), Color(0xFFB59B85)],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.offset});
  final ValueListenable<double> offset;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: offset,
      builder: (context, value, child) {
        final overscroll = value < 0 ? -value : 0.0;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(0, value > 0 ? value * 0.45 : 0),
                child: Transform.scale(
                  scale: 1 + overscroll / 320,
                  child: const _HeaderPlate(),
                ),
              ),
              Opacity(
                opacity: (1 - value / 260).clamp(0.0, 1.0),
                child: Transform.translate(offset: Offset(0, value * 0.18), child: child),
              ),
            ],
          ),
        );
      },
      child: const _HeaderContent(),
    );
  }
}

class _HeaderPlate extends StatelessWidget {
  const _HeaderPlate();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AppImage(
          source: AppImages.homeHeader,
          fallback: [Color(0xFFE3EFF6), Color(0xFFC2D8E4), Color(0xFFDDE9F0)],
        ),

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF7FBFD).withValues(alpha: 0.72),
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.78),
                const Color(0xFFF4FAFD),
              ],
              stops: const [0.0, 0.30, 0.66, 0.92],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.paddingOf(context).top + 12.h),

        Flexible(
          child: SizedBox(
            height: 112.h,
            width: double.infinity,
            child: Center(child: GlowOrb(diameter: 96.r)),
          ),
        ),
        const Spacer(),
        Text('Ready for today’s session?', style: AppText.body(17.5, weight: FontWeight.w500)),
        SizedBox(height: 3.h),
        Text(
          'Take a deep breath and reset.',
          style: AppText.body(13.5, color: AppColors.textSecondary),
        ),
        SizedBox(height: 16.h),
        const _StartBreathingButton(),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class _StartBreathingButton extends StatelessWidget {
  const _StartBreathingButton();

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => const BreathingSessionScreen())),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        decoration: BoxDecoration(
          color: AppColors.aqua,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: [
            BoxShadow(
              color: AppColors.aquaDeep.withValues(alpha: 0.30),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.play, size: 14.r, color: AppColors.textPrimary),
            SizedBox(width: 8.w),
            Text('Start Breathing', style: AppText.body(16, weight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: _StressLevelCard()),
              SizedBox(width: 11.w),
              const Expanded(child: _MindScoreCard()),
            ],
          ),
        ),
        SizedBox(height: 11.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: _DailyStreakCard()),
              SizedBox(width: 11.w),
              const Expanded(child: _SleepRecoveryCard()),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({
    required this.value,
    required this.score,
    required this.outOf,
    this.delay = Duration.zero,
  });

  final String value;
  final num score;
  final String outOf;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppText.metric()),
        SizedBox(height: 2.h),
        CountUpText(value: score, suffix: outOf, delay: delay, style: AppText.caption()),
      ],
    );
  }
}

class _StressLevelCard extends StatelessWidget {
  const _StressLevelCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading(title: 'Stress Level', icon: LucideIcons.activity),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatValue(
                value: 'Low',
                score: 28,
                outOf: ' / 100',
                delay: AppMotion.stagger * 2,
              ),
              const Spacer(),
              SizedBox(
                width: 48.w,
                height: 24.h,
                child: const Sparkline(points: [6, 4, 7, 3, 5, 2, 4], color: AppColors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MindScoreCard extends StatelessWidget {
  const _MindScoreCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading(
            title: 'Mind Score',
            icon: LucideIcons.brain,
            iconColor: AppColors.blue,
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatValue(
                value: 'Good',
                score: 78,
                outOf: ' / 100',
                delay: AppMotion.stagger * 2,
              ),
              const Spacer(),
              ProgressRing(
                diameter: 34.r,
                value: 0.78,
                color: AppColors.aquaDeep,
                strokeWidth: 3.4.r,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyStreakCard extends StatelessWidget {
  const _DailyStreakCard();
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _completed = 5;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading(
            title: 'Daily Streak',
            icon: LucideIcons.flame,
            iconColor: AppColors.gold,
          ),
          SizedBox(height: 10.h),
          CountUpText(value: 5, suffix: ' days', style: AppText.metric()),
          SizedBox(height: 10.h),
          Row(
            children: [
              for (var i = 0; i < _days.length; i++)
                Expanded(
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: AppMotion.enter + AppMotion.stagger * i,
                        curve: Curves.easeOutBack,
                        builder: (context, t, child) => Transform.scale(scale: t, child: child),
                        child: Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _completed ? AppColors.gold : AppColors.track,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(_days[i], style: AppText.body(9, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepRecoveryCard extends StatelessWidget {
  const _SleepRecoveryCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading(
            title: 'Sleep Recovery',
            icon: LucideIcons.moon,
            iconColor: AppColors.blue,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountUpText(value: 86, suffix: '%', style: AppText.metric()),
                  SizedBox(height: 2.h),
                  Text('Good', style: AppText.caption()),
                ],
              ),
              const Spacer(),
              ProgressRing(
                diameter: 34.r,
                value: 0.86,
                color: AppColors.green,
                strokeWidth: 3.4.r,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStartTile extends StatelessWidget {
  const _QuickStartTile();

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => const BreathingSessionScreen())),
      child: SectionCard(
        padding: EdgeInsets.all(10.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 46.r,
                height: 46.r,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const AppImage(
                      source: AppImages.quickStart,
                      fallback: [Color(0xFFDCEAF3), Color(0xFFAFC9DA)],
                    ),
                    Center(child: GlowOrb(diameter: 17.r, animate: false, haloScale: 1.6)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('4-7-8 Breathing', style: AppText.body(16, weight: FontWeight.w600)),
                  SizedBox(height: 2.h),
                  Text(
                    'Calm your mind in 2 minutes',
                    style: AppText.body(12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              width: 30.r,
              height: 30.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.aquaWash,
              ),
              child: Icon(LucideIcons.play, size: 13.r, color: AppColors.aquaDeep),
            ),
          ],
        ),
      ),
    );
  }
}
