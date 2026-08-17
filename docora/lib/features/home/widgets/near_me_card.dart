import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/shared_widgets.dart';

class NearMeCard extends StatelessWidget {
  const NearMeCard({
    super.key,
    required this.doctor,
    required this.onTap,
    required this.onBook,
    this.compact = false,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        padding: EdgeInsets.all(compact ? 14.w : 18.w),
        radius: compact ? 18 : 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAvatar(
                  initials: doctor.initials,
                  color: doctor.avatarColor,
                  size: compact ? 52 : 64,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              doctor.name,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: compact ? 15.sp : 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          const VerifiedBadge(),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(doctor.specialty, style: AppTextStyles.cardSubtitle),
                      SizedBox(height: 6.h),
                      RatingBadge(
                        rating: doctor.rating,
                        reviews: doctor.reviews,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              SizedBox(height: 18.h),
              const Divider(color: AppColors.border, height: 1),
              SizedBox(height: 16.h),
            ] else
              SizedBox(height: 14.h),
            if (doctor.availableNow)
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Available Now',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Iconsax.video, size: 18.sp, color: AppColors.primary),
                ],
              ),
            if (!compact) SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Experience',
                    value: '${doctor.experienceYears} years',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _InfoTile(
                    label: 'Consultation fee',
                    value: '\$${doctor.fee.toStringAsFixed(0)}.00',
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              SizedBox(height: 18.h),
              _BookButton(onTap: onBook),
            ] else ...[
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: _CompactBookChip(onTap: onBook),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.statLabel),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.statValue.copyWith(fontSize: 14.sp)),
        ],
      ),
    );
  }
}

class _CompactBookChip extends StatelessWidget {
  const _CompactBookChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'Book',
          style: AppTextStyles.badge.copyWith(fontSize: 12.sp),
        ),
      ),
    );
  }
}

class _BookButton extends StatefulWidget {
  const _BookButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BookButton> createState() => _BookButtonState();
}

class _BookButtonState extends State<_BookButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text('Book Appointment', style: AppTextStyles.button),
        ),
      ),
    );
  }
}
