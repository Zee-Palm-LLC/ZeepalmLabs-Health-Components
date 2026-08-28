import 'dart:ui';

import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceChromeButton extends StatelessWidget {
  const VoiceChromeButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final box = size ?? 52.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: box,
        height: box,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B8AAE).withValues(alpha: 0.14),
              blurRadius: 16,
              offset: Offset(0, 6.h),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.7),
              blurRadius: 1,
              offset: Offset(0, -1.h),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.72),
                    Colors.white.withValues(alpha: 0.42),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: (box * 0.42).sp,
                color: PrimaryBgColors.title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
