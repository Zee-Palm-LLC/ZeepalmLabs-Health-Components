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

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  int _filter = 0;

  static const _filters = ['All', 'Lab', 'Prescription', 'Report'];

  List<MedicalRecordModel> get _records {
    if (_filter == 0) return MockData.medicalRecords;
    final type = _filters[_filter];
    return MockData.medicalRecords.where((r) => r.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;

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
          'Medical Records',
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
            child: Column(
              children: [
                SizedBox(
                  height: 40.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final selected = _filter == index;
                      return PressScale(
                        onTap: () => setState(() => _filter = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Text(
                            _filters[index],
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppColors.body,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: records.isEmpty
                      ? Center(
                          child: Text(
                            'No records found',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                          itemCount: records.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            return FadeScaleIn(
                              delay: Duration(milliseconds: 40 + index * 50),
                              child: _RecordCard(record: records[index]),
                            );
                          },
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

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final MedicalRecordModel record;

  ({Color bg, Color fg, IconData icon}) get _style {
    switch (record.type) {
      case 'Lab':
        return (
          bg: AppColors.primaryLight,
          fg: AppColors.primary,
          icon: Iconsax.document_text,
        );
      case 'Prescription':
        return (
          bg: AppColors.cardio,
          fg: AppColors.cardioIcon,
          icon: Iconsax.document_text,
        );
      default:
        return (
          bg: AppColors.derma,
          fg: AppColors.dermaIcon,
          icon: Iconsax.document_text,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(style.icon, size: 20.sp, color: style.fg),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${record.doctorName} · ${record.date}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.body,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        record.type,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: style.fg,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      record.fileLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Iconsax.arrow_right_3, size: 16.sp, color: AppColors.muted),
        ],
      ),
    );
  }
}
