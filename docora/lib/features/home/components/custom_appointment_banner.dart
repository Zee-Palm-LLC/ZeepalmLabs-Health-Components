import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';

class AppointmentBannerData {
  const AppointmentBannerData({
    required this.name,
    required this.specialty,
    required this.experienceYears,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.rating,
  });

  final String name;
  final String specialty;
  final int experienceYears;
  final String date;
  final String time;
  final String imageUrl;
  final double rating;
}

class CustomAppointmentBanner extends StatelessWidget {
  const CustomAppointmentBanner({
    super.key,
    this.data = _defaultData,
    this.onJoinTap,
    this.onChatTap,
  });

  final AppointmentBannerData data;
  final VoidCallback? onJoinTap;
  final VoidCallback? onChatTap;

  static const _bannerHeight = 180.0;
  static const _scheduleBarHeight = 46.0;

  static const _defaultData = AppointmentBannerData(
    name: 'Dr. James Wilson',
    specialty: 'Cardiologist',
    experienceYears: 8,
    date: 'Sunday, 23 Oct',
    time: '11:30 - 12:00',
    rating: 4.9,
    imageUrl: AppImages.bannerDoctor,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _bannerHeight.h,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: Offset(0, 10.h),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _BannerBackground(),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 148.w,
                child: _DoctorHeroImage(imageUrl: data.imageUrl),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF0A4FC7).withValues(alpha: 0.97),
                        const Color(0xFF1677FF).withValues(alpha: 0.92),
                        const Color(0xFF1677FF).withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 0.68, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -20.h,
                left: -20.w,
                child: _GlowOrb(size: 80.w, opacity: 0.10),
              ),
              Positioned(
                bottom: 36.h,
                left: 120.w,
                child: _GlowOrb(size: 50.w, opacity: 0.07),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  14.h,
                  12.w,
                  _scheduleBarHeight.h + 6.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _LiveBadge(),
                        SizedBox(width: 8.w),
                        _RatingChip(rating: data.rating),
                        const Spacer(),
                        _JoinNowButton(onTap: onJoinTap),
                        SizedBox(width: 8.w),
                        _ChatButton(onTap: onChatTap),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 118.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.15,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 6.w,
                              runSpacing: 6.h,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _InfoChip(
                                  icon: Iconsax.shield_tick,
                                  label: data.specialty,
                                ),
                                _InfoChip(
                                  icon: Iconsax.health,
                                  label: '${data.experienceYears} yrs exp.',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ScheduleBar(
                  date: data.date,
                  time: data.time,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerBackground extends StatelessWidget {
  const _BannerBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E88FF),
            const Color(0xFF1677FF),
            const Color(0xFF0D5BD7),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 180.w,
          height: 180.h,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.1,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorHeroImage extends StatelessWidget {
  const _DoctorHeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppImage(
          path: imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF1677FF).withValues(alpha: 0.85),
                  const Color(0xFF1677FF).withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.35, 0.75],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 1.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: const Color(0xFF5DFF9A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5DFF9A).withValues(alpha: 0.65),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'Upcoming',
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.star, size: 11.sp, color: AppColors.star),
          SizedBox(width: 4.w),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: Colors.white.withValues(alpha: 0.92)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleBar extends StatelessWidget {
  const _ScheduleBar({required this.date, required this.time});

  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScheduleItem(icon: Iconsax.calendar, label: date),
          ),
          Container(
            width: 1,
            height: 16.h,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            color: Colors.white.withValues(alpha: 0.22),
          ),
          Expanded(
            child: _ScheduleItem(
              icon: Iconsax.clock,
              label: time,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinNowButton extends StatelessWidget {
  const _JoinNowButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.video, size: 13.sp, color: AppColors.primary),
            SizedBox(width: 5.w),
            Text(
              'Join Now',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(Iconsax.message, size: 15.sp, color: Colors.white),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({
    required this.icon,
    required this.label,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Icon(icon, size: 13.sp, color: Colors.white.withValues(alpha: 0.92)),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.96),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
