import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class WellnessBanner extends StatefulWidget {
  const WellnessBanner({super.key});

  @override
  State<WellnessBanner> createState() => _WellnessBannerState();
}

class _WellnessBannerState extends State<WellnessBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnim = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.16, 1, 0.3, 1),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreAnim,
      builder: (context, _) {
        final score = (87 * _scoreAnim.value).round();
        final progress = 0.87 * _scoreAnim.value;

        return GlassSurface(
          borderRadius: 14.r,
          blur: 14,
          opacity: 0.6,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              SizedBox(
                width: 46.w,
                height: 46.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 46.w,
                      height: 46.w,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4.w,
                        backgroundColor:
                            const Color(0xFF7B5FD4).withValues(alpha: 0.12),
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF7B5FD4)),
                      ),
                    ),
                    Text(
                      '$score',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: PrimaryBgColors.title,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Wellness Score',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: PrimaryBgColors.title,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Great progress today · 3 goals completed',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: PrimaryBgColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6ED6A0).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.arrow_up_2,
                      size: 11.sp,
                      color: const Color(0xFF3FAF74),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '+5',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3FAF74),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
