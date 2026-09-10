import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bar_chart.dart';
import '../widgets/count_up_text.dart';
import '../widgets/motion.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_card.dart';
import '../widgets/sparkline.dart';

const _ranges = ['7D', '30D', '90D'];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _range = 0;

  void _selectRange(int value) {
    if (value == _range) return;
    HapticFeedback.selectionClick();
    setState(() => _range = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AppTopBar(title: 'Progress & Insights'),
      body: StaggeredList(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 22.h),
        children: [
          _RangeSelector(selected: _range, onChanged: _selectRange),
          SizedBox(height: 14.h),

          KeyedSubtree(
            key: ValueKey(_range),
            child: Column(
              children: [
                const _CalmScoreCard(),
                SizedBox(height: 12.h),
                const _StreakCard(),
                SizedBox(height: 12.h),
                const _BreathingMinutesCard(),
                SizedBox(height: 12.h),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(child: _StressTrendCard()),
                      SizedBox(width: 12.w),
                      const Expanded(child: _SleepImprovementCard()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          const _InsightsCard(),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: selected.toDouble()),
            duration: AppMotion.tab,
            curve: Curves.easeOutCubic,
            builder: (context, position, child) => Align(
              alignment: Alignment(position / (_ranges.length - 1) * 2 - 1, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / _ranges.length,
                heightFactor: 1,
                child: child,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.chip),
                boxShadow: AppShadows.card,
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < _ranges.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: AppMotion.tab,
                        style: AppText.body(
                          13.5,
                          weight: i == selected ? FontWeight.w600 : FontWeight.w400,
                          color: i == selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        child: Text(_ranges[i]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalmScoreCard extends StatelessWidget {
  const _CalmScoreCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Calm Score', style: AppText.body(14.5, weight: FontWeight.w500)),
          SizedBox(height: 12.h),
          Row(
            children: [
              ProgressRing(
                diameter: 74.r,
                value: 0.82,
                color: AppColors.green,
                strokeWidth: 6.r,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountUpText(
                      value: 82,
                      style: AppText.body(26, weight: FontWeight.w600, height: 1.1),
                    ),
                    Text('Good', style: AppText.body(10.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CountUpText(
                      value: 12,
                      prefix: '+',
                      suffix: '%',
                      style: AppText.body(17, weight: FontWeight.w600, color: AppColors.green),
                    ),
                    Text(
                      'vs. last week',
                      style: AppText.body(11, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'You’re becoming\nmore present.\nKeep going!',
                      style: AppText.body(11, color: AppColors.textSecondary, height: 1.5),
                    ),
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

class _StreakCard extends StatelessWidget {
  const _StreakCard();
  static const _completed = 5;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mindfulness Streak', style: AppText.body(14.5, weight: FontWeight.w500)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    for (var i = 0; i < _weekdays.length; i++)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _weekdays[i],
                              style: AppText.body(10, color: AppColors.textTertiary),
                            ),
                            SizedBox(height: 6.h),
                            _DayDot(done: i < _completed, index: i),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                children: [
                  CountUpText(
                    value: 5,
                    style: AppText.body(23.5, weight: FontWeight.w600, height: 1.1),
                  ),
                  Text('days', style: AppText.body(10.5, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.done, required this.index});
  final bool done;
  final int index;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.greenWash : Colors.transparent,
        border: Border.all(color: done ? AppColors.green : AppColors.track, width: 1.2.r),
      ),
      child: done ? Icon(LucideIcons.check, size: 11.r, color: AppColors.green) : null,
    );

    if (!done) return circle;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.enter + AppMotion.stagger * index,
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: circle,
    );
  }
}

class _BreathingMinutesCard extends StatelessWidget {
  const _BreathingMinutesCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Breathing Minutes',
                  style: AppText.body(14.5, weight: FontWeight.w500),
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 16.r, color: AppColors.textTertiary),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountUpText(
                value: 42,
                suffix: ' min',
                style: AppText.body(25, weight: FontWeight.w600, height: 1.1),
              ),
              SizedBox(width: 8.w),
              const _DeltaPill(text: '+18%'),
            ],
          ),
          SizedBox(height: 12.h),
          WeeklyBarChart(
            values: const [14, 22, 30, 18, 26, 44, 34],
            labels: _weekdays,
            height: 66.h,
          ),
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.text});
  static const color = AppColors.green;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        text,
        style: AppText.body(11, weight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _StressTrendCard extends StatelessWidget {
  const _StressTrendCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stress Trend', style: AppText.body(13.5, weight: FontWeight.w500)),
          SizedBox(height: 10.h),
          SizedBox(
            height: 34.h,
            child: const Sparkline(
              points: [8, 5, 7, 4, 6, 3, 4, 2],
              color: AppColors.green,
              filled: true,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Decreasing',
                  style: AppText.body(11.5, color: AppColors.textSecondary),
                ),
              ),
              Icon(LucideIcons.arrowDown, size: 12.r, color: AppColors.green),
              SizedBox(width: 2.w),
              CountUpText(
                value: 32,
                suffix: '%',
                style: AppText.body(11.5, weight: FontWeight.w600, color: AppColors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepImprovementCard extends StatelessWidget {
  const _SleepImprovementCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sleep Improvement',
                  style: AppText.body(13.5, weight: FontWeight.w500),
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 15.r, color: AppColors.textTertiary),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              ProgressRing(
                diameter: 42.r,
                value: 0.86,
                color: AppColors.green,
                strokeWidth: 4.r,
                child: Text('86%', style: AppText.body(13, weight: FontWeight.w600)),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CountUpText(
                      value: 14,
                      prefix: '+',
                      suffix: '%',
                      style: AppText.body(14, weight: FontWeight.w600, color: AppColors.green),
                    ),
                    Text(
                      'vs. last week',
                      style: AppText.body(10.5, color: AppColors.textSecondary),
                    ),
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

class _InsightsCard extends StatelessWidget {
  const _InsightsCard();

  static const _lines = [
    'Your stress levels are lower this week.',
    'Your sleep quality has improved by 14%.',
    'Keep up the great work!',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.goldWash,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lightbulb, size: 16.r, color: AppColors.goldDark),
              SizedBox(width: 6.w),
              Text('AI Wellness Insights', style: AppText.body(13.5, weight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8.h),

          for (var i = 0; i < _lines.length; i++)
            Entrance(
              delay: AppMotion.stagger * (i + 2),
              offset: 8,
              child: Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Text(
                  _lines[i],
                  style: AppText.body(11.5, color: AppColors.textSecondary, height: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
