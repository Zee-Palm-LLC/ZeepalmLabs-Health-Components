import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class TopRatedDoctorsSection extends StatelessWidget {
  const TopRatedDoctorsSection({
    super.key,
    this.doctors = MockData.topRated,
    this.onViewAll,
    this.onDoctorTap,
  });

  final List<DoctorModel> doctors;
  final VoidCallback? onViewAll;
  final ValueChanged<DoctorModel>? onDoctorTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Rated Doctors',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.body,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 198.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: doctors.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return TopRatedDoctorCard(
                doctor: doctor,
                onTap: () {
                  if (onDoctorTap != null) {
                    onDoctorTap!(doctor);
                  } else {}
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class TopRatedDoctorCard extends StatelessWidget {
  const TopRatedDoctorCard({super.key, required this.doctor, this.onTap});

  final DoctorModel doctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 118.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DoctorPhoto(doctor: doctor),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    doctor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                const _VerifiedBadge(),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                Icon(
                  _specialtyIcon(doctor.specialty),
                  size: 13.sp,
                  color: AppColors.muted,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    doctor.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.body,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Iconsax.star, size: 13.sp, color: AppColors.star),
                SizedBox(width: 4.w),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    '(${doctor.reviews} reviews)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _specialtyIcon(String specialty) {
    final value = specialty.toLowerCase();
    if (value.contains('heart') || value.contains('cardio')) {
      return Iconsax.heart;
    }
    if (value.contains('neuro') || value.contains('brain')) {
      return Iconsax.health;
    }
    if (value.contains('ophthal') || value.contains('eye')) {
      return Iconsax.eye;
    }
    if (value.contains('derma') || value.contains('skin')) {
      return Iconsax.user;
    }
    return Iconsax.hospital;
  }
}

class _DoctorPhoto extends StatelessWidget {
  const _DoctorPhoto({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: 118.w,
        height: 118.w,
        child: doctor.imageUrl == null
            ? ColoredBox(
                color: doctor.avatarColor,
                child: Center(
                  child: Text(
                    doctor.initials,
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              )
            : AppImage(
                path: doctor.imageUrl!,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_rounded, size: 10.sp, color: Colors.white),
    );
  }
}
