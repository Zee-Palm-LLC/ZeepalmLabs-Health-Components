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
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../messages/components/message_motion.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key, required this.appointment});

  final AppointmentModel appointment;

  Color get _statusColor {
    switch (appointment.status) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.cardioIcon;
      default:
        return AppColors.primary;
    }
  }

  void _snack(String title) {
    Get.snackbar(
      title,
      'This action is visual for now',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: AppColors.ink,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final d = a.doctor;
    final upcoming = a.status == 'upcoming';
    final isVideo = a.visitType == 'Video';

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
          'Appointment',
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
              child: Column(
                children: [
                  FadeScaleIn(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.65),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              a.status[0].toUpperCase() + a.status.substring(1),
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: _statusColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Booking ID',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            a.bookingId,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          _InfoRow(icon: Iconsax.calendar, label: 'Date', value: a.date),
                          SizedBox(height: 8.h),
                          _InfoRow(icon: Iconsax.clock, label: 'Time', value: a.time),
                          SizedBox(height: 8.h),
                          _InfoRow(
                            icon: isVideo ? Iconsax.video : Iconsax.hospital,
                            label: 'Visit type',
                            value: a.visitType,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 70),
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.65),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: SizedBox(
                              width: 64.w,
                              height: 64.w,
                              child: d.imageUrl != null
                                  ? AppImage(path: d.imageUrl!, fit: BoxFit.cover)
                                  : ColoredBox(color: d.avatarColor),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  d.specialty,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: AppColors.body,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  d.hospital,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      children: [
                        if (upcoming && isVideo) ...[
                          _ActionBtn(
                            icon: Iconsax.video,
                            label: 'Join Video Call',
                            primary: true,
                            onTap: () => _snack('Join Video'),
                          ),
                          SizedBox(height: 8.h),
                        ],
                        if (upcoming) ...[
                          _ActionBtn(
                            icon: Iconsax.calendar,
                            label: 'Reschedule',
                            onTap: () => _snack('Reschedule'),
                          ),
                          SizedBox(height: 8.h),
                          _ActionBtn(
                            icon: Iconsax.close_circle,
                            label: 'Cancel Appointment',
                            danger: true,
                            onTap: () => _snack('Cancel'),
                          ),
                          SizedBox(height: 8.h),
                        ],
                        _ActionBtn(
                          icon: Iconsax.message,
                          label: 'Message Doctor',
                          onTap: () => _snack('Message'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: AppColors.muted),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.muted),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppColors.cardioIcon
        : primary
            ? Colors.white
            : AppColors.ink;
    return PressScale(
      onTap: onTap,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFF4A9AFF), AppColors.primary],
                )
              : null,
          color: primary
              ? null
              : danger
                  ? AppColors.cardio.withValues(alpha: 0.35)
                  : Colors.white,
          border: primary
              ? null
              : Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
