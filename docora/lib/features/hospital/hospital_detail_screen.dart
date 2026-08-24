import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../booking/book_appointment_screen.dart';
import '../booking/book_slot_screen.dart';
import '../doctor/doctor_detail_screen.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../messages/components/message_motion.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({super.key, required this.hospital});

  final HospitalModel hospital;

  List<DoctorModel> get _doctors {
    final name = hospital.name.toLowerCase();
    final words = name.split(RegExp(r'\s+')).where((w) => w.length > 3).toList();
    return MockData.allDoctors.where((d) {
      final h = d.hospital.toLowerCase();
      if (h.contains(name) || name.contains(h)) return true;
      return words.any((w) => h.contains(w));
    }).toList();
  }

  void _book() {
    final docs = _doctors;
    if (docs.isNotEmpty) {
      AppNav.to(BookSlotScreen(doctor: docs.first));
    } else {
      AppNav.to(const BookAppointmentScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = hospital;
    final doctors = _doctors;
    final topPad = MediaQuery.paddingOf(context).top;

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
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CustomIconBtn(icon: Iconsax.location, onTap: () {}),
          ),
        ],
      ),
      body: Stack(
        children: [
          const CustomShade(height: 140),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, topPad + 56.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeScaleIn(
                        child: Container(
                          height: 190.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 18,
                                offset: Offset(0, 8.h),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppImage(path: h.imagePath, fit: BoxFit.cover),
                              if (h.isEmergency)
                                Positioned(
                                  top: 12.h,
                                  left: 12.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardioIcon,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      'Emergency',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.location,
                                  size: 14.sp,
                                  color: AppColors.muted,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    h.address,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: AppColors.body,
                                    ),
                                  ),
                                ),
                                Text(
                                  h.distance,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Iconsax.star, size: 14.sp, color: AppColors.star),
                                SizedBox(width: 4.w),
                                Text(
                                  '${h.rating}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  '  (${h.reviews})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Icon(Iconsax.clock, size: 14.sp, color: AppColors.muted),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    h.openHours,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: AppColors.body,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 110),
                        child: _CardBlock(
                          title: 'About',
                          child: Text(
                            h.about,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.body,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 150),
                        child: _CardBlock(
                          title: 'Departments',
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              for (final dept in h.departments)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 7.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    dept,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 180),
                        child: _CardBlock(
                          title: 'Contact',
                          child: Row(
                            children: [
                              Container(
                                width: 42.w,
                                height: 42.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Iconsax.call,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Call hospital',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    Text(
                                      h.phone,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: AppColors.body,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 16.sp,
                                color: AppColors.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 220),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doctors at this hospital',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            if (doctors.isEmpty)
                              Text(
                                'No matched doctors in mock data',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: AppColors.muted,
                                ),
                              )
                            else
                              for (var i = 0; i < doctors.length; i++) ...[
                                if (i > 0) SizedBox(height: 8.h),
                                PressScale(
                                  onTap: () => AppNav.to(
                                    DoctorDetailScreen(doctor: doctors[i]),
                                  ),
                                  child: _DoctorRow(doctor: doctors[i]),
                                ),
                              ],
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  12.h,
                  16.w,
                  12.h + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: Offset(0, -4.h),
                    ),
                  ],
                ),
                child: PressScale(
                  onTap: _book,
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4A9AFF),
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Book Appointment',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  const _DoctorRow({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 48.w,
              height: 48.w,
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  doctor.specialty,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.body,
                  ),
                ),
              ],
            ),
          ),
          Icon(Iconsax.star, size: 12.sp, color: AppColors.star),
          SizedBox(width: 3.w),
          Text(
            '${doctor.rating}',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
