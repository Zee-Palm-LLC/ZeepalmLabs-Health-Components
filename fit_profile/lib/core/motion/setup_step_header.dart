import 'package:fit_profile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetupStepHeader extends StatelessWidget {
  const SetupStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title),
        SizedBox(height: 8.h),
        Text(subtitle, style: AppTextStyles.subtitle),
      ],
    );
  }
}
