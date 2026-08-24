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
import '../doctor/doctor_detail_screen.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_search_field.dart';
import '../home/components/custom_shade.dart';
import 'booking_widgets.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen>
    with SingleTickerProviderStateMixin {
  int _specialty = 0;
  String _query = '';
  late final AnimationController _entrance;

  static const _specialties = [
    'All',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Ophthalmologist',
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  List<DoctorModel> get _doctors {
    final all = [...MockData.topRated, ...MockData.nearMe, MockData.featured];
    final seen = <String>{};
    var list = <DoctorModel>[];
    for (final d in all) {
      if (seen.add(d.id)) list.add(d);
    }

    if (_specialty > 0) {
      final label = _specialties[_specialty].toLowerCase();
      list = list
          .where(
            (d) =>
                d.specialty.toLowerCase().contains(label) ||
                (label.contains('cardio') &&
                    d.specialty.toLowerCase().contains('heart')),
          )
          .toList();
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where(
            (d) =>
                d.name.toLowerCase().contains(q) ||
                d.specialty.toLowerCase().contains(q) ||
                d.hospital.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _doctors;

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
            onTap: () => Get.back(),
          ),
        ),
        title: Text(
          'Book Appointment',
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
          const CustomShade(height: 120),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: BookingFadeSlide(
                    animation: _entrance,
                    begin: 0,
                    end: 0.35,
                    child: const BookingStepBar(step: 1),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 6.h)),
                SoftSliverPadding(
                  child: BookingFadeSlide(
                    animation: _entrance,
                    begin: 0.05,
                    end: 0.4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _HeroBanner(),
                    ),
                  ),
                ),
                SoftSliverPadding(
                  top: 12.h,
                  child: BookingFadeSlide(
                    animation: _entrance,
                    begin: 0.1,
                    end: 0.45,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CustomSearchField(
                        hintText: 'Search doctor or specialty...',
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ),
                ),
                SoftSliverPadding(
                  top: 10.h,
                  child: BookingFadeSlide(
                    animation: _entrance,
                    begin: 0.15,
                    end: 0.5,
                    child: SizedBox(
                      height: 38.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _specialties.length,
                        separatorBuilder: (_, _) => SizedBox(width: 8.w),
                        itemBuilder: (context, i) {
                          final selected = _specialty == i;
                          return GestureDetector(
                            onTap: () => setState(() => _specialty = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                gradient: selected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF4A9AFF),
                                          AppColors.primary,
                                        ],
                                      )
                                    : null,
                                color: selected ? null : Colors.white,
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : AppColors.border.withValues(alpha: 0.8),
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.28),
                                          blurRadius: 10,
                                          offset: Offset(0, 4.h),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  if (i > 0) ...[
                                    Icon(
                                      specialtyIcon(_specialties[i]),
                                      size: 13.sp,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                    SizedBox(width: 5.w),
                                  ],
                                  Text(
                                    _specialties[i],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SoftSliverPadding(
                  top: 12.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text(
                          'Choose your doctor',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${doctors.length} ready',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SoftSliverPadding(top: 8.h, child: const SizedBox.shrink()),
                if (doctors.isEmpty)
                  SoftSliverPadding(
                    top: 48.h,
                    child: Center(
                      child: Text(
                        'No doctors found',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppColors.body,
                        ),
                      ),
                    ),
                  )
                else
                  SoftSliverPadding(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                      child: Column(
                        children: [
                          for (var i = 0; i < doctors.length; i++) ...[
                            if (i > 0) SizedBox(height: 10.h),
                            _LuxuryDoctorCard(
                              doctor: doctors[i],
                              index: i,
                              onTap: () => AppNav.to(
                                DoctorDetailScreen(doctor: doctors[i]),
                              ),
                            ),
                          ],
                        ],
                      ),
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

class SoftSliverPadding extends StatelessWidget {
  const SoftSliverPadding({super.key, required this.child, this.top = 0});

  final Widget child;
  final double top;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: top > 0
          ? Padding(padding: EdgeInsets.only(top: top), child: child)
          : child,
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
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
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Iconsax.calendar_1, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find your specialist',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Book in under 2 minutes with top-rated doctors.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.3,
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

class _LuxuryDoctorCard extends StatefulWidget {
  const _LuxuryDoctorCard({
    required this.doctor,
    required this.index,
    required this.onTap,
  });

  final DoctorModel doctor;
  final int index;
  final VoidCallback onTap;

  @override
  State<_LuxuryDoctorCard> createState() => _LuxuryDoctorCardState();
}

class _LuxuryDoctorCardState extends State<_LuxuryDoctorCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _in;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 420 + (widget.index * 55).clamp(0, 220)),
    )..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final curved = CurvedAnimation(parent: _in, curve: Curves.easeOutCubic);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.55),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14.r),
                                child: SizedBox(
                                  width: 72.w,
                                  height: 78.h,
                                  child: d.imageUrl != null
                                      ? AppImage(
                                          path: d.imageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : ColoredBox(
                                          color: d.avatarColor,
                                          child: Center(
                                            child: Text(
                                              d.initials,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            if (d.availableNow)
                              Positioned(
                                right: 4.w,
                                bottom: 4.h,
                                child: Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E7),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.star,
                                          size: 10.sp,
                                          color: AppColors.star,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          '${d.rating}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                d.specialty,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.hospital,
                                    size: 11.sp,
                                    color: AppColors.muted,
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      d.hospital,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.sp,
                                        color: AppColors.body,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  _MiniStat(
                                    icon: Iconsax.medal_star,
                                    text: '${d.experienceYears} yrs',
                                  ),
                                  SizedBox(width: 8.w),
                                  _MiniStat(
                                    icon: Iconsax.people,
                                    text: d.patients,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                    child: Row(
                      children: [
                        Text(
                          '\$${d.fee.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          ' / visit',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: AppColors.muted,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4A9AFF),
                                AppColors.primary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Select',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 12.sp,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: AppColors.primary),
          SizedBox(width: 3.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.body,
            ),
          ),
        ],
      ),
    );
  }
}
