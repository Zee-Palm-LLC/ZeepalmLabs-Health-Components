import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/doctor_hero_photo.dart';
import '../booking/book_slot_screen.dart';
import '../hospital/hospital_detail_screen.dart';
import '../messages/components/message_motion.dart';
import '../reviews/reviews_screen.dart';

export '../../core/widgets/doctor_hero_photo.dart' show doctorPhotoHeroTag;

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({
    super.key,
    required this.doctor,
    this.heroScope = 'detail',
  });

  final DoctorModel doctor;
  /// Must match the list card [DoctorHeroPhoto.scope] that opened this page.
  final String heroScope;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final _scroll = ScrollController();
  bool _favorite = false;
  double _collapse = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final h = 260.h;
    final next = (_scroll.offset / h).clamp(0.0, 1.0);
    if ((next - _collapse).abs() > 0.01) {
      setState(() => _collapse = next);
    }
  }

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

  List<_ServiceItem> get _services {
    final s = widget.doctor.specialty.toLowerCase();
    if (s.contains('cardio') || s.contains('heart')) {
      return [
        _ServiceItem('ECG', Iconsax.heart, '15 min'),
        _ServiceItem('Consult', Iconsax.message, '30 min'),
        _ServiceItem('Follow-up', Iconsax.refresh, '20 min'),
        _ServiceItem('Screening', Iconsax.chart_success, '25 min'),
      ];
    }
    if (s.contains('derma')) {
      return [
        _ServiceItem('Skin exam', Iconsax.scan, '25 min'),
        _ServiceItem('Allergy', Iconsax.health, '20 min'),
        _ServiceItem('Acne plan', Iconsax.magic_star, '30 min'),
        _ServiceItem('Follow-up', Iconsax.refresh, '15 min'),
      ];
    }
    if (s.contains('neuro')) {
      return [
        _ServiceItem('Neuro exam', Iconsax.cpu, '40 min'),
        _ServiceItem('Headache', Iconsax.headphone, '25 min'),
        _ServiceItem('EEG', Iconsax.activity, '45 min'),
        _ServiceItem('Follow-up', Iconsax.refresh, '20 min'),
      ];
    }
    return [
      _ServiceItem('Consult', Iconsax.message, '30 min'),
      _ServiceItem('Diagnosis', Iconsax.search_normal_1, '40 min'),
      _ServiceItem('Treatment', Iconsax.hospital, '35 min'),
      _ServiceItem('Follow-up', Iconsax.refresh, '20 min'),
    ];
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
    final heroH = 300.h;
    final titleOpacity = Curves.easeOut.transform(_collapse);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _collapse > 0.45
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Plain Hero target (not inside FlexibleSpaceBar) so flight works.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: heroH,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DoctorHeroPhoto(doctor: d, scope: widget.heroScope),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 110.h,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.background.withValues(alpha: 0.55),
                                  AppColors.background,
                                ],
                                stops: const [0, 0.55, 1],
                              ),
                            ),
                          ),
                        ),
                        if (d.availableNow)
                          Positioned(
                            left: 16.w,
                            bottom: 28.h,
                            child: _AvailableChip(),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: Offset(0, -14.h),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 120),
                            child: _IdentityCard(
                              doctor: d,
                              onHospitalTap:
                                  MockData.hospitalByName(d.hospital) != null
                                      ? _openHospital
                                      : null,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 170),
                            child: _StatsRow(doctor: d),
                          ),
                          SizedBox(height: 12.h),
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 210),
                            child: _SectionCard(
                              title: 'About',
                              child: Text(
                                _bio,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5.sp,
                                  color: AppColors.body,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 250),
                            child: _ServicesGrid(services: _services),
                          ),
                          SizedBox(height: 10.h),
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 280),
                            child: _WeekHeatmap(),
                          ),
                          SizedBox(height: 10.h),
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 310),
                            child: _ReviewsBlock(
                              doctor: d,
                              reviews: reviews,
                            ),
                          ),
                          SizedBox(height: 100.h + topPad * 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Collapsing top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: EdgeInsets.only(top: topPad),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: titleOpacity),
                  boxShadow: titleOpacity > 0.85
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: SizedBox(
                  height: 52.h,
                  child: Row(
                    children: [
                      SizedBox(width: 12.w),
                      _GlassIconBtn(
                        icon: Iconsax.arrow_left_2,
                        onTap: AppNav.back,
                        light: _collapse < 0.45,
                      ),
                      Expanded(
                        child: Opacity(
                          opacity: titleOpacity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Text(
                              d.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _GlassIconBtn(
                        icon: _favorite
                            ? Icons.favorite_rounded
                            : Iconsax.heart,
                        iconColor: _favorite ? AppColors.cardioIcon : null,
                        onTap: () => setState(() => _favorite = !_favorite),
                        light: _collapse < 0.45,
                      ),
                      SizedBox(width: 6.w),
                      _GlassIconBtn(
                        icon: Iconsax.share,
                        onTap: () => Get.snackbar(
                          'Share',
                          'Profile link copied',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: AppColors.ink,
                          margin: EdgeInsets.all(16.w),
                          borderRadius: 12.r,
                        ),
                        light: _collapse < 0.45,
                      ),
                      SizedBox(width: 12.w),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeScaleIn(
                delay: const Duration(milliseconds: 280),
                child: _StickyBar(
                  fee: d.fee,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconBtn extends StatelessWidget {
  const _GlassIconBtn({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.light = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: light
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: light
                    ? Colors.white.withValues(alpha: 0.35)
                    : AppColors.border.withValues(alpha: 0.7),
              ),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: iconColor ??
                  (light ? Colors.white : AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailableChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'Available now',
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.doctor, this.onHospitalTap});

  final DoctorModel doctor;
  final VoidCallback? onHospitalTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  doctor.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            doctor.specialty,
            style: GoogleFonts.poppins(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),
          PressScale(
            onTap: onHospitalTap,
            child: Row(
              children: [
                Icon(Iconsax.hospital, size: 14.sp, color: AppColors.muted),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    doctor.hospital,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5.sp,
                      color: AppColors.body,
                      decoration: onHospitalTap != null
                          ? TextDecoration.underline
                          : null,
                      decorationColor: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border.withValues(alpha: 0.7),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(Iconsax.star, size: 15.sp, color: AppColors.star),
              SizedBox(width: 5.w),
              Text(
                '${doctor.rating}',
                style: GoogleFonts.poppins(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '  (${doctor.reviews})',
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  color: AppColors.muted,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Iconsax.clock, size: 14.sp, color: AppColors.muted),
              SizedBox(width: 5.w),
              Text(
                '${doctor.experienceYears} yrs exp',
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  color: AppColors.body,
                ),
              ),
              const Spacer(),
              Text(
                '\$${doctor.fee.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceItem {
  const _ServiceItem(this.label, this.icon, this.duration);

  final String label;
  final IconData icon;
  final String duration;
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(label: 'Patients', value: doctor.patients, icon: Iconsax.people),
        SizedBox(width: 8.w),
        _StatTile(
          label: 'Experience',
          value: '${doctor.experienceYears}y',
          icon: Iconsax.briefcase,
        ),
        SizedBox(width: 8.w),
        _StatTile(
          label: 'Success',
          value: '${doctor.successRate}%',
          icon: Iconsax.chart_success,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(height: 5.h),
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
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
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

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.services});

  final List<_ServiceItem> services;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 2.55,
            ),
            itemBuilder: (context, i) {
              final s = services[i];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        s.icon,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            s.duration,
                            style: GoogleFonts.poppins(
                              fontSize: 9.5.sp,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// GitHub-style contribution heatmap for weekly open slots.
class _WeekHeatmap extends StatelessWidget {
  /// Rows = time bands (AM / Mid / PM), cols = Mon–Sun.
  /// Level 0 = off, 1 = light, 2 = open, 3 = peak availability.
  static const _grid = [
    [2, 3, 2, 3, 2, 1, 0], // Morning
    [3, 2, 3, 2, 3, 0, 0], // Midday
    [1, 2, 1, 2, 1, 1, 0], // Evening
  ];
  static const _bands = ['AM', 'MD', 'PM'];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Color _cellColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFB7D6FF);
      case 2:
        return const Color(0xFF5AA3FF);
      case 3:
        return AppColors.primaryDark;
      default:
        return const Color(0xFFEEF1F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final openDays = _grid
        .expand((r) => r.asMap().entries)
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toSet()
        .length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'This week',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$openDays days open',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Slot density by time of day',
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              SizedBox(
                width: 28.w,
                child: Column(
                  children: [
                    SizedBox(height: 18.h),
                    for (var r = 0; r < _bands.length; r++) ...[
                      if (r > 0) SizedBox(height: 5.h),
                      SizedBox(
                        height: 22.h,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _bands[r],
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (var c = 0; c < _days.length; c++) ...[
                          if (c > 0) SizedBox(width: 5.w),
                          Expanded(
                            child: Text(
                              _days[c],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.body,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    for (var r = 0; r < _grid.length; r++) ...[
                      if (r > 0) SizedBox(height: 5.h),
                      Row(
                        children: [
                          for (var c = 0; c < _grid[r].length; c++) ...[
                            if (c > 0) SizedBox(width: 5.w),
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(
                                  milliseconds: 280 + (r * 40) + (c * 20),
                                ),
                                curve: Curves.easeOutCubic,
                                builder: (context, t, _) {
                                  return Opacity(
                                    opacity: t,
                                    child: Transform.scale(
                                      scale: 0.85 + (0.15 * t),
                                      child: Container(
                                        height: 22.h,
                                        decoration: BoxDecoration(
                                          color: _cellColor(_grid[r][c]),
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Text(
                'Less',
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  color: AppColors.muted,
                ),
              ),
              SizedBox(width: 6.w),
              for (final level in [0, 1, 2, 3]) ...[
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _cellColor(level),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(width: 4.w),
              ],
              Text(
                'More',
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              Text(
                'Off · Soft · Open · Peak',
                style: GoogleFonts.poppins(
                  fontSize: 8.5.sp,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewsBlock extends StatelessWidget {
  const _ReviewsBlock({required this.doctor, required this.reviews});

  final DoctorModel doctor;
  final List<ReviewModel> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              onTap: () => AppNav.to(ReviewsScreen(doctor: doctor)),
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
        SizedBox(height: 8.h),
        for (var i = 0; i < reviews.length; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          _ReviewPreview(review: reviews[i]),
        ],
      ],
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
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              review.initials,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
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
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Icon(Iconsax.star, size: 11.sp, color: AppColors.star),
                    SizedBox(width: 2.w),
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
                SizedBox(height: 3.h),
                Text(
                  review.comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.body,
                    height: 1.35,
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
  const _StickyBar({
    required this.fee,
    required this.onMessage,
    required this.onBook,
  });

  final double fee;
  final VoidCallback onMessage;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16.w,
            10.h,
            16.w,
            10.h + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: Border(
              top: BorderSide(
                color: AppColors.border.withValues(alpha: 0.7),
              ),
            ),
          ),
          child: Row(
            children: [
              PressScale(
                onTap: onMessage,
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Iconsax.message,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: PressScale(
                  onTap: onBook,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
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
                          blurRadius: 12,
                          offset: Offset(0, 5.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Book · \$${fee.toInt()}',
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
        ),
      ),
    );
  }
}
