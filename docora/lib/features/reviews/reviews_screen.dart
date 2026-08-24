import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../messages/components/message_motion.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final reviews = MockData.reviews;
    final avg = reviews.fold<double>(0, (s, r) => s + r.rating) / reviews.length;

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
          'Reviews',
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
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
              children: [
                FadeScaleIn(
                  child: Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.65),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: Offset(0, 5.h),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              avg.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                for (var i = 0; i < 5; i++)
                                  Icon(
                                    Iconsax.star,
                                    size: 14.sp,
                                    color: i < avg.round()
                                        ? AppColors.star
                                        : AppColors.border,
                                  ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${reviews.length} reviews',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20.w),
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
                              Text(
                                doctor.specialty,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: AppColors.body,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Based on patient feedback for consultations and follow-ups.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: AppColors.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                for (var i = 0; i < reviews.length; i++) ...[
                  if (i > 0) SizedBox(height: 10.h),
                  FadeScaleIn(
                    delay: Duration(milliseconds: 50 + i * 50),
                    child: _ReviewCard(review: reviews[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(
                      review.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      review.timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < 5; i++)
                    Icon(
                      Iconsax.star,
                      size: 12.sp,
                      color: i < review.rating.round()
                          ? AppColors.star
                          : AppColors.border,
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            review.comment,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: AppColors.body,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
