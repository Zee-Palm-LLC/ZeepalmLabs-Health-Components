import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FitonistLogo extends StatelessWidget {
  const FitonistLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.textPrimary,
              Color(0xFFD4CCFF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'fitonist',
            style: AppTextStyles.logo.copyWith(color: AppColors.textPrimary),
          ),
        ),
        SizedBox(height: 8.h),
        Text('Your Personal Workouts', style: AppTextStyles.tagline),
      ],
    );
  }
}
