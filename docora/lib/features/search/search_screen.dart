import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../doctor/doctor_detail_screen.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../hospital/hospital_detail_screen.dart';
import '../messages/components/message_motion.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  late String _query;

  static const _recent = [
    'Cardiologist',
    'City Heart',
    'Dermatologist',
    'Dr. Esther',
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<DoctorModel> get _doctors {
    if (_query.trim().isEmpty) return const [];
    final q = _query.toLowerCase();
    return MockData.allDoctors
        .where(
          (d) =>
              d.name.toLowerCase().contains(q) ||
              d.specialty.toLowerCase().contains(q) ||
              d.hospital.toLowerCase().contains(q),
        )
        .toList();
  }

  List<HospitalModel> get _hospitals {
    if (_query.trim().isEmpty) return const [];
    final q = _query.toLowerCase();
    return MockData.hospitals
        .where(
          (h) =>
              h.name.toLowerCase().contains(q) ||
              h.address.toLowerCase().contains(q) ||
              h.departments.any((d) => d.toLowerCase().contains(q)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _doctors;
    final hospitals = _hospitals;
    final hasQuery = _query.trim().isNotEmpty;
    final empty = hasQuery && doctors.isEmpty && hospitals.isEmpty;

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
          'Search',
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
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.7),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Row(
                        children: [
                          Icon(Iconsax.search_normal_1,
                              size: 18.sp, color: AppColors.muted),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              onChanged: (v) => setState(() => _query = v),
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: AppColors.ink,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Doctors, hospitals, specialty...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: AppColors.muted,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            PressScale(
                              onTap: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                              child: Icon(
                                Iconsax.close_circle,
                                size: 18.sp,
                                color: AppColors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                    children: [
                      if (!hasQuery) ...[
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 50),
                          child: Text(
                            'Recent searches',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 80),
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              for (final r in _recent)
                                PressScale(
                                  onTap: () {
                                    _controller.text = r;
                                    setState(() => _query = r);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: AppColors.border
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    child: Text(
                                      r,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: AppColors.body,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ] else if (empty)
                        FadeScaleIn(
                          child: Padding(
                            padding: EdgeInsets.only(top: 48.h),
                            child: Column(
                              children: [
                                Icon(Iconsax.search_normal_1,
                                    size: 28.sp, color: AppColors.muted),
                                SizedBox(height: 10.h),
                                Text(
                                  'No results found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        if (doctors.isNotEmpty) ...[
                          FadeScaleIn(
                            child: Text(
                              'Doctors',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          for (var i = 0; i < doctors.length; i++) ...[
                            if (i > 0) SizedBox(height: 8.h),
                            FadeScaleIn(
                              delay: Duration(milliseconds: 40 + i * 40),
                              child: PressScale(
                                onTap: () => AppNav.to(
                                  DoctorDetailScreen(doctor: doctors[i]),
                                ),
                                child: _ResultDoctor(doctor: doctors[i]),
                              ),
                            ),
                          ],
                          SizedBox(height: 16.h),
                        ],
                        if (hospitals.isNotEmpty) ...[
                          FadeScaleIn(
                            child: Text(
                              'Hospitals',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          for (var i = 0; i < hospitals.length; i++) ...[
                            if (i > 0) SizedBox(height: 8.h),
                            FadeScaleIn(
                              delay: Duration(milliseconds: 60 + i * 40),
                              child: PressScale(
                                onTap: () => AppNav.to(
                                  HospitalDetailScreen(hospital: hospitals[i]),
                                ),
                                child: _ResultHospital(hospital: hospitals[i]),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ],
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

class _ResultDoctor extends StatelessWidget {
  const _ResultDoctor({required this.doctor});

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
                  '${doctor.specialty} · ${doctor.hospital}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.body,
                  ),
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

class _ResultHospital extends StatelessWidget {
  const _ResultHospital({required this.hospital});

  final HospitalModel hospital;

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
              child: AppImage(path: hospital.imagePath, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '${hospital.address} · ${hospital.distance}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.body,
                  ),
                ),
              ],
            ),
          ),
          Icon(Iconsax.hospital, size: 16.sp, color: AppColors.primary),
        ],
      ),
    );
  }
}
