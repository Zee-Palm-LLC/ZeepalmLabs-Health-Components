import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_text_styles.dart';

class SpecialistChip extends StatelessWidget {
  const SpecialistChip({super.key, required this.model});

  final SpecialistModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: model.background,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(model.icon, color: model.iconColor, size: 26.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            model.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardSubtitle.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
