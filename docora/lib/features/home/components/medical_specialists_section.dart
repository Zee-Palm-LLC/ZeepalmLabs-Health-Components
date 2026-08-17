import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/data/mock_data.dart';

class MedicalSpecialistsSection extends StatelessWidget {
  const MedicalSpecialistsSection({
    super.key,
    this.specialists = MockData.specialists,
    this.onViewAll,
    this.onSpecialistTap,
  });

  final List<SpecialistModel> specialists;
  final VoidCallback? onViewAll;
  final ValueChanged<SpecialistModel>? onSpecialistTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medical Specialists',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 42.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: specialists.length,
            separatorBuilder: (context, index) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final specialist = specialists[index];
              return SpecialistCategoryCard(
                model: specialist,
                onTap: () => onSpecialistTap?.call(specialist),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SpecialistCategoryCard extends StatelessWidget {
  const SpecialistCategoryCard({super.key, required this.model, this.onTap});

  final SpecialistModel model;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 0.5.w,
          ),
          borderRadius: BorderRadius.circular(6.r),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30.h,
              width: 30.h,
              decoration: BoxDecoration(
                color: model.iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(model.icon, size: 16.sp, color: model.iconColor),
            ),
            SizedBox(width: 8.w),
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Text(
                model.label,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
