import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../messages/components/message_motion.dart';
import 'appointment_detail_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  int _tab = 0;

  static const _tabs = ['Upcoming', 'Completed', 'Cancelled'];
  static const _statuses = ['upcoming', 'completed', 'cancelled'];

  List<AppointmentModel> get _list => MockData.appointments
      .where((a) => a.status == _statuses[_tab])
      .toList();

  @override
  Widget build(BuildContext context) {
    final list = _list;

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
          'My Appointments',
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
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                  child: FadeScaleIn(
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        children: [
                          for (var i = 0; i < _tabs.length; i++)
                            Expanded(
                              child: PressScale(
                                onTap: () => setState(() => _tab = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    gradient: _tab == i
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF4A9AFF),
                                              AppColors.primary,
                                            ],
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    _tabs[i],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _tab == i
                                          ? Colors.white
                                          : AppColors.body,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: FadeScaleIn(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.calendar,
                                    size: 28.sp, color: AppColors.muted),
                                SizedBox(height: 8.h),
                                Text(
                                  'No ${_tabs[_tab].toLowerCase()} appointments',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: AppColors.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final a = list[index];
                            return FadeScaleIn(
                              delay: Duration(milliseconds: 40 + index * 50),
                              child: PressScale(
                                onTap: () => AppNav.to(
                                  AppointmentDetailScreen(appointment: a),
                                ),
                                child: _AppointmentCard(appointment: a),
                              ),
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

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

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

  @override
  Widget build(BuildContext context) {
    final d = appointment.doctor;
    return Container(
      padding: EdgeInsets.all(12.w),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        appointment.status[0].toUpperCase() +
                            appointment.status.substring(1),
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Iconsax.calendar, size: 12.sp, color: AppColors.muted),
                    SizedBox(width: 4.w),
                    Text(
                      appointment.date,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.body,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(Iconsax.clock, size: 12.sp, color: AppColors.muted),
                    SizedBox(width: 4.w),
                    Text(
                      appointment.time,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.body,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      appointment.visitType == 'Video'
                          ? Iconsax.video
                          : Iconsax.hospital,
                      size: 12.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      appointment.visitType,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
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
