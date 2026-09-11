import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';
import '../../core/app_motion.dart';
import '../../core/app_text.dart';
import '../../widgets/animations.dart';
import '../../widgets/charts.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/heart_visual.dart';
import '../../widgets/status_badge.dart';

class HeartTopBar extends StatelessWidget {
  const HeartTopBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIconButton(icon: Iconsax.arrow_left_2, onTap: onBack),
        Expanded(
          child: Text(
            'Heart Health',
            textAlign: TextAlign.center,
            style: AppText.h2(),
          ),
        ),
        GlassIconButton(icon: Iconsax.more, onTap: () {}),
      ],
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 38,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.r),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Icon(icon, size: 17.sp, color: Colors.white),
      ),
    );
  }
}

class HeartHero extends StatelessWidget {
  const HeartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 4.h,
            child: ScaleIn(
              from: 0.86,
              duration: const Duration(milliseconds: 760),
              child: HeartVisual(size: 206.w),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: const FadeSlideIn(
              delay: Duration(milliseconds: 260),
              child: StatusBadge(
                label: 'Live',
                color: AppColors.green,
                showDot: true,
                pulse: true,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 360),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedCountText(
                        value: 82,
                        style: GoogleFonts.poppins(
                          fontSize: 38.sp,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.6,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: AppColors.rose.withValues(alpha: 0.45),
                              blurRadius: 26,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 5.h),
                        child: Text(
                          'BPM',
                          style: AppText.overline().copyWith(
                            color: AppColors.rose,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  const EcgLine(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCardData {
  const MetricCardData({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.unit,
    required this.badge,
    required this.decimals,
    this.series,
    this.meter,
  });

  final IconData icon;
  final Color color;
  final String title;
  final double value;
  final String unit;
  final String badge;
  final int decimals;
  final List<double>? series;
  final double? meter;
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.data, required this.index});

  final MetricCardData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: AppMotion.stagger(index, step: 90, from: 420),
      child: GlassCard(
        radius: 20,
        onTap: () {},
        edgeGradient: AppColors.tintedEdge(data.color),
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 3.5.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      data.color,
                      data.color.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              data.color.withValues(alpha: 0.26),
                              data.color.withValues(alpha: 0.07),
                            ],
                          ),
                          border: Border.all(
                            color: data.color.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Icon(
                          data.icon,
                          size: 16.sp,
                          color: data.color,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption(),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                AnimatedCountText(
                                  value: data.value,
                                  decimals: data.decimals,
                                  style: AppText.metric()
                                      .copyWith(fontSize: 20.sp),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  data.unit,
                                  style: AppText.caption()
                                      .copyWith(fontSize: 9.5.sp),
                                ),
                                SizedBox(width: 8.w),
                                StatusBadge(
                                  label: data.badge,
                                  color: AppColors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                      if (data.series != null)
                        Sparkline(
                          values: data.series!,
                          color: data.color,
                          size: Size(74.w, 34.h),
                        )
                      else if (data.meter != null)
                        SegmentedMeter(
                          progress: data.meter!,
                          color: data.color,
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

class TrendsCard extends StatefulWidget {
  const TrendsCard({super.key});

  @override
  State<TrendsCard> createState() => _TrendsCardState();
}

class _TrendsCardState extends State<TrendsCard> {
  static const _ranges = ['7D', '30D', '90D'];
  int _range = 0;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Resting Trends', style: AppText.h3()),
              const Spacer(),
              RangeSelector(
                options: _ranges,
                selected: _range,
                onChanged: (i) => setState(() => _range = i),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          const TrendBarChart(
            values: [46, 58, 40, 66, 52, 74, 92],
            labels: ['Apr 14', '15', '16', '17', '18', '19', '20'],
            unit: 'bpm',
            initialIndex: 6,
          ),
        ],
      ),
    );
  }
}

class RangeSelector extends StatelessWidget {
  const RangeSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.strokeSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final active = i == selected;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (active) return;
              HapticFeedback.selectionClick();
              onChanged(i);
            },
            child: AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.emphasized,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                gradient: active
                    ? LinearGradient(
                        colors: [
                          AppColors.violet.withValues(alpha: 0.85),
                          AppColors.indigo.withValues(alpha: 0.85),
                        ],
                      )
                    : null,
              ),
              child: AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textTertiary,
                ),
                child: Text(options[i]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      tint: AppColors.green.withValues(alpha: 0.09),
      edgeGradient: AppColors.tintedEdge(AppColors.green),
      padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11.r),
              color: AppColors.green.withValues(alpha: 0.18),
              border: Border.all(
                color: AppColors.green.withValues(alpha: 0.32),
              ),
            ),
            child: Icon(
              Iconsax.shield_tick,
              size: 15.sp,
              color: AppColors.green,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Heart health is on track!', style: AppText.h3()),
                SizedBox(height: 4.h),
                Text(
                  'Your heart rate and HRV are within a healthy range.',
                  style: AppText.body().copyWith(fontSize: 10.sp, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
