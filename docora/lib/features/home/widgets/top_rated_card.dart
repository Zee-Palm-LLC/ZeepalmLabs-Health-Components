import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/shared_widgets.dart';

class TopRatedCard extends StatelessWidget {
  const TopRatedCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        padding: EdgeInsets.all(14.w),
        child: SizedBox(
          width: 140.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorAvatar(
                initials: doctor.initials,
                color: doctor.avatarColor,
                size: 56,
              ),
              SizedBox(height: 12.h),
              Text(
                doctor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(doctor.specialty, style: AppTextStyles.cardSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 8.h),
              RatingBadge(
                rating: doctor.rating,
                reviews: doctor.reviews,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
