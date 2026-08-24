import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../booking/book_slot_screen.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../hospital/hospital_detail_screen.dart';
import '../messages/components/message_motion.dart';
import '../reviews/reviews_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  bool _favorite = false;

  String get _bio {
    final s = widget.doctor.specialty.toLowerCase();
    if (s.contains('cardio') || s.contains('heart')) {
      return 'Board-certified cardiologist focused on preventive heart care, '
          'hypertension management, and personalized recovery plans.';
    }
    if (s.contains('derma') || s.contains('skin')) {
      return 'Dermatologist specializing in clinical skincare, allergy care, '
          'and evidence-based treatments for lasting results.';
    }
    if (s.contains('neuro')) {
      return 'Neurologist with expertise in headache disorders, neuropathy, '
          'and comprehensive neurological assessments.';
    }
    if (s.contains('ophthal') || s.contains('eye')) {
      return 'Eye specialist delivering precise diagnostics and compassionate '
          'vision care for patients of all ages.';
    }
    return 'Experienced clinician dedicated to clear communication, '
        'accurate diagnosis, and patient-centered treatment plans.';
  }

  List<String> get _services {
    final s = widget.doctor.specialty.toLowerCase();
    if (s.contains('cardio') || s.contains('heart')) {
      return ['ECG', 'Consultation', 'Follow-up', 'Risk screening'];
    }
    if (s.contains('derma')) {
      return ['Skin exam', 'Allergy care', 'Acne plan', 'Follow-up'];
    }
    if (s.contains('neuro')) {
      return ['Neuro exam', 'Headache care', 'EEG consult', 'Follow-up'];
    }
    return ['Consultation', 'Diagnosis', 'Treatment', 'Follow-up'];
  }

  void _openHospital() {
    final match = MockData.hospitalByName(widget.doctor.hospital);
    if (match != null) {
      AppNav.to(HospitalDetailScreen(hospital: match));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final reviews = MockData.reviews.take(2).toList();
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
            child: CustomIconBtn(
              icon: _favorite ? Icons.favorite_rounded : Iconsax.heart,
              iconColor: _favorite ? AppColors.cardioIcon : null,
              onTap: () => setState(() => _favorite = !_favorite),
            ),
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
                      FadeScaleIn(child: _PhotoHeader(doctor: d)),
                      SizedBox(height: 14.h),
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              d.specialty,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            PressScale(
                              onTap: MockData.hospitalByName(d.hospital) != null
                                  ? _openHospital
                                  : null,
                              child: Row(
                                children: [
                                  Icon(
                                    Iconsax.hospital,
                                    size: 14.sp,
                                    color: AppColors.muted,
                                  ),
                                  SizedBox(width: 5.w),
                                  Flexible(
                                    child: Text(
                                      d.hospital,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: AppColors.body,
                                        decoration:
                                            MockData.hospitalByName(d.hospital) !=
                                                    null
                                                ? TextDecoration.underline
                                                : null,
                                        decorationColor: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Iconsax.star, size: 14.sp, color: AppColors.star),
                                SizedBox(width: 4.w),
                                Text(
                                  '${d.rating}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  '  (${d.reviews})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Icon(Iconsax.clock, size: 14.sp, color: AppColors.muted),
                                SizedBox(width: 4.w),
                                Text(
                                  '${d.experienceYears} yrs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: AppColors.body,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${d.fee.toInt()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
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
                        child: Row(
                          children: [
                            _StatTile(label: 'Patients', value: d.patients),
                            SizedBox(width: 8.w),
                            _StatTile(
                              label: 'Experience',
                              value: '${d.experienceYears}y',
                            ),
                            SizedBox(width: 8.w),
                            _StatTile(
                              label: 'Success',
                              value: '${d.successRate}%',
                            ),
                            SizedBox(width: 8.w),
                            _StatTile(label: 'Reviews', value: d.reviews),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      FadeScaleIn(
                        delay: const Duration(milliseconds: 150),
                        child: _SectionCard(
                          title: 'About',
                          child: Text(
                            _bio,
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
                        delay: const Duration(milliseconds: 190),
                        child: _SectionCard(
                          title: 'Services',
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              for (final s in _services)
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
                                    s,
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
                        delay: const Duration(milliseconds: 230),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Reviews',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const Spacer(),
                                PressScale(
                                  onTap: () => AppNav.to(
                                    ReviewsScreen(doctor: d),
                                  ),
                                  child: Text(
                                    'See all',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            for (var i = 0; i < reviews.length; i++) ...[
                              if (i > 0) SizedBox(height: 8.h),
                              _ReviewPreview(review: reviews[i]),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              _StickyBar(
                onMessage: () => Get.snackbar(
                  'Message',
                  'Messaging will be available soon',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.white,
                  colorText: AppColors.ink,
                  margin: EdgeInsets.all(16.w),
                  borderRadius: 12.r,
                ),
                onBook: () => AppNav.to(BookSlotScreen(doctor: d)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          doctor.imageUrl != null
              ? AppImage(path: doctor.imageUrl!, fit: BoxFit.cover)
              : ColoredBox(color: doctor.avatarColor),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 72.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          if (doctor.availableNow)
            Positioned(
              top: 12.h,
              left: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Available now',
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
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
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

class _ReviewPreview extends StatelessWidget {
  const _ReviewPreview({required this.review});

  final ReviewModel review;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              review.initials,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Icon(Iconsax.star, size: 12.sp, color: AppColors.star),
                    SizedBox(width: 3.w),
                    Text(
                      review.rating.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  review.comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.body,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyBar extends StatelessWidget {
  const _StickyBar({required this.onMessage, required this.onBook});

  final VoidCallback onMessage;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          PressScale(
            onTap: onMessage,
            child: Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(Iconsax.message, size: 20.sp, color: AppColors.primary),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: PressScale(
              onTap: onBook,
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
    );
  }
}
