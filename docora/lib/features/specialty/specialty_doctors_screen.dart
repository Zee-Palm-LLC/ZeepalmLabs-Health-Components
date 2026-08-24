import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../booking/book_slot_screen.dart';
import '../doctor/doctor_detail_screen.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../messages/components/message_motion.dart';

class SpecialtyDoctorsScreen extends StatelessWidget {
  SpecialtyDoctorsScreen({
    super.key,
    String? specialty,
    this.specialist,
  }) : specialty = specialty ?? specialist?.label ?? 'Specialist';

  final String specialty;
  final SpecialistModel? specialist;

  List<DoctorModel> get _doctors {
    final label = specialty.toLowerCase();
    return MockData.allDoctors.where((d) {
      final s = d.specialty.toLowerCase();
      if (s.contains(label)) return true;
      if ((label.contains('cardio') || label.contains('heart')) &&
          (s.contains('cardio') || s.contains('heart'))) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _doctors;
    final tint = specialist?.background ?? AppColors.primaryLight;
    final iconColor = specialist?.iconColor ?? AppColors.primary;
    final icon = specialist?.icon ?? Icons.favorite_rounded;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leadingWidth: 56.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: CustomIconBtn(
            icon: Iconsax.arrow_left_2,
            onTap: AppNav.back,
          ),
        ),
        title: Text(
          specialty,
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const CustomShade(height: 100),
          SafeArea(
            child: doctors.isEmpty
                ? Center(
                    child: Text(
                      'No doctors found',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    itemCount: doctors.length + 1,
                    separatorBuilder: (_, i) =>
                        SizedBox(height: i == 0 ? 12.h : 10.h),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return FadeScaleIn(
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: tint,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(icon, color: iconColor, size: 20.sp),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                '${doctors.length} specialists available',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: AppColors.body,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final d = doctors[index - 1];
                      return FadeScaleIn(
                        delay: Duration(milliseconds: 40 + (index - 1) * 50),
                        child: PressScale(
                          onTap: () =>
                              AppNav.to(DoctorDetailScreen(doctor: d)),
                          child: _SpecialtyDoctorCard(doctor: d),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyDoctorCard extends StatelessWidget {
  const _SpecialtyDoctorCard({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              width: 72.w,
              height: 72.w,
              child: doctor.imageUrl != null
                  ? AppImage(path: doctor.imageUrl!, fit: BoxFit.cover)
                  : ColoredBox(color: doctor.avatarColor),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  doctor.specialty,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.body,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Iconsax.star, size: 12.sp, color: AppColors.star),
                    SizedBox(width: 3.w),
                    Text(
                      '${doctor.rating}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '\$${doctor.fee.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    PressScale(
                      onTap: () => AppNav.to(BookSlotScreen(doctor: doctor)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Book',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
