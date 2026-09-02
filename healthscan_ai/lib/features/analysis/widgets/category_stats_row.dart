import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CategoryStatsRow extends StatelessWidget {
  const CategoryStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
        Expanded(
          child: _CategoryCard(
            icon: Iconsax.heart,
            iconColor: AppColors.heart,
            iconBg: AppColors.heartSoft,
            barColor: AppColors.heart,
            label: 'Heart Health',
            value: 92,
            status: 'Excellent',
          ),
        ),
        _CardGap(),
        Expanded(
          child: _CategoryCard(
            icon: Iconsax.activity,
            iconColor: AppColors.success,
            iconBg: AppColors.successSoft,
            barColor: AppColors.success,
            label: 'Activity Level',
            value: 85,
            status: 'Very Good',
          ),
        ),
        _CardGap(),
        Expanded(
          child: _CategoryCard(
            icon: Iconsax.moon,
            iconColor: AppColors.bp,
            iconBg: AppColors.bpSoft,
            barColor: AppColors.bp,
            label: 'Sleep Quality',
            value: 78,
            status: 'Good',
          ),
        ),
        _CardGap(),
        Expanded(
          child: _CategoryCard(
            icon: Icons.psychology_rounded,
            iconColor: AppColors.stress,
            iconBg: AppColors.stressSoft,
            barColor: AppColors.stress,
            label: 'Stress Level',
            value: 20,
            status: 'Low',
          ),
        ),
        ],
      ),
    );
  }
}

class _CardGap extends StatelessWidget {
  const _CardGap();

  @override
  Widget build(BuildContext context) => SizedBox(width: 8.w);
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.barColor,
    required this.label,
    required this.value,
    required this.status,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color barColor;
  final String label;
  final int value;
  final String status;

  @override
  Widget build(BuildContext context) {
    final progress = value / 100;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            iconBg.withValues(alpha: 0.55),
            AppColors.card,
            AppColors.card,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18.sp,
              color: iconColor,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 28.h,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '$value%',
            style: AppTextStyles.cardValue.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            status,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          SizedBox(height: 10.h),
          _CategoryProgressBar(
            progress: progress,
            color: barColor,
          ),
        ],
      ),
    );
  }
}

class _CategoryProgressBar extends StatelessWidget {
  const _CategoryProgressBar({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 5.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.border),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
