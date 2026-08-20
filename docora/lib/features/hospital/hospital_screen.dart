import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_search_field.dart';
import '../home/components/custom_shade.dart';

class HospitalModel {
  const HospitalModel({
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.departments,
    required this.imagePath,
    required this.openHours,
    this.isEmergency = false,
    this.isOpen = true,
  });

  final String name;
  final String address;
  final String distance;
  final double rating;
  final String reviews;
  final List<String> departments;
  final String imagePath;
  final String openHours;
  final bool isEmergency;
  final bool isOpen;
}

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen>
    with SingleTickerProviderStateMixin {
  int _filter = 0;
  String _query = '';
  late final AnimationController _entrance;

  static const _filters = ['All', 'Nearby', 'Emergency', 'Top Rated'];

  static const _hospitals = [
    HospitalModel(
      name: 'City Heart Hospital',
      address: 'Downtown Medical Avenue',
      distance: '1.2 km',
      rating: 4.9,
      reviews: '2.4k',
      departments: ['Cardiology', 'Emergency', 'ICU'],
      imagePath: AppImages.hospital1,
      openHours: 'Open 24 Hours',
      isEmergency: true,
    ),
    HospitalModel(
      name: 'The Valley Hospital',
      address: 'Green Park, Sector 12',
      distance: '2.8 km',
      rating: 4.8,
      reviews: '1.8k',
      departments: ['Neurology', 'Ortho', 'Lab'],
      imagePath: AppImages.hospital2,
      openHours: '08:00 - 22:00',
    ),
    HospitalModel(
      name: 'Metro Care Clinic',
      address: 'Lake View Road',
      distance: '3.5 km',
      rating: 4.7,
      reviews: '960',
      departments: ['Dermatology', 'Dental', 'OPD'],
      imagePath: AppImages.hospital3,
      openHours: '09:00 - 20:00',
    ),
    HospitalModel(
      name: 'Vision Care Hospital',
      address: 'Central Business District',
      distance: '4.1 km',
      rating: 4.6,
      reviews: '720',
      departments: ['Eye Care', 'Surgery'],
      imagePath: AppImages.hospital1,
      openHours: 'Open 24 Hours',
      isEmergency: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  List<HospitalModel> get _filtered {
    var list = List<HospitalModel>.from(_hospitals);

    if (_filter == 1) {
      list.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_filter == 2) {
      list = list.where((h) => h.isEmergency).toList();
    } else if (_filter == 3) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where(
            (h) =>
                h.name.toLowerCase().contains(q) ||
                h.address.toLowerCase().contains(q) ||
                h.departments.any((d) => d.toLowerCase().contains(q)),
          )
          .toList();
    }
    return list;
  }

  void _onFilterTap(int index) {
    if (_filter == index) return;
    setState(() => _filter = index);
  }

  @override
  Widget build(BuildContext context) {
    final hospitals = _filtered;
    final featured = _hospitals.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Text(
          'Hospitals',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        actions: [
          CustomIconBtn(icon: Iconsax.map_1, onTap: () {}),
          SizedBox(width: 16.w),
        ],
      ),
      body: Stack(
        children: [
          const CustomShade(height: 100),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Search
                SliverToBoxAdapter(
                  child: _FadeSlide(
                    animation: _entrance,
                    begin: 0.0,
                    end: 0.28,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                      child: CustomSearchField(
                        hintText: 'Search hospital, department...',
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                  ),
                ),

                // Filters
                SoftSliverGap(height: 8.h),
                SoftSliver(
                  child: _FadeSlide(
                    animation: _entrance,
                    begin: 0.08,
                    end: 0.36,
                    child: SizedBox(
                      height: 34.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        primary: false,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _filters.length,
                        separatorBuilder: (context, index) => SizedBox(width: 6.w),
                        itemBuilder: (context, index) {
                          return _SmoothFilterChip(
                            label: _filters[index],
                            selected: _filter == index,
                            onTap: () => _onFilterTap(index),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Featured
                SoftSliverGap(height: 10.h),
                SoftSliver(
                  child: _FadeSlide(
                    animation: _entrance,
                    begin: 0.14,
                    end: 0.48,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _FeaturedHospitalCard(hospital: featured),
                    ),
                  ),
                ),

                // Horizontal nearby strip
                SoftSliverGap(height: 12.h),
                SoftSliver(
                  child: _FadeSlide(
                    animation: _entrance,
                    begin: 0.22,
                    end: 0.55,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Text(
                            'Nearby Hospitals',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'See all',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SoftSliverGap(height: 6.h),
                SoftSliver(
                  child: _FadeSlide(
                    animation: _entrance,
                    begin: 0.28,
                    end: 0.62,
                    child: SizedBox(
                      height: 148.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        primary: false,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _hospitals.length,
                        separatorBuilder: (context, index) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          return _HospitalHCard(hospital: _hospitals[index]);
                        },
                      ),
                    ),
                  ),
                ),

                // Header
                SoftSliverGap(height: 12.h),
                SoftSliver(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text(
                          'All Hospitals',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Text(
                            '${hospitals.length} found',
                            key: ValueKey(hospitals.length),
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.body,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SoftSliverGap(height: 6.h),

                // List with smooth filter transition
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 110.h),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: hospitals.isEmpty
                          ? Padding(
                              key: const ValueKey('empty'),
                              padding: EdgeInsets.symmetric(vertical: 32.h),
                              child: Center(
                                child: Text(
                                  'No hospitals found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: AppColors.body,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              key: ValueKey('list-$_filter-$_query'),
                              children: [
                                for (var i = 0; i < hospitals.length; i++) ...[
                                  if (i > 0) SizedBox(height: 6.h),
                                  _HospitalListCard(
                                    hospital: hospitals[i],
                                    index: i,
                                  ),
                                ],
                              ],
                            ),
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

class SoftSliver extends StatelessWidget {
  const SoftSliver({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: child);
  }
}

class SoftSliverGap extends StatelessWidget {
  const SoftSliverGap({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SoftSliver(child: SizedBox(height: height));
  }
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({
    required this.animation,
    required this.child,
    required this.begin,
    required this.end,
  });

  final AnimationController animation;
  final Widget child;
  final double begin;
  final double end;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, (1 - curved.value) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _SmoothFilterChip extends StatelessWidget {
  const _SmoothFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.025),
              blurRadius: selected ? 8 : 4,
              offset: Offset(0, selected ? 2.h : 1.h),
            ),
          ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.body,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _HospitalHCard extends StatefulWidget {
  const _HospitalHCard({required this.hospital});

  final HospitalModel hospital;

  @override
  State<_HospitalHCard> createState() => _HospitalHCardState();
}

class _HospitalHCardState extends State<_HospitalHCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hospital = widget.hospital;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 132.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 78.h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(path: hospital.imagePath, fit: BoxFit.cover),
                    Positioned(
                      left: 6.w,
                      top: 6.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.star, size: 9.sp, color: AppColors.star),
                            SizedBox(width: 2.w),
                            Text(
                              hospital.rating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hospital.isEmergency)
                      Positioned(
                        right: 6.w,
                        top: 6.h,
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppColors.cardioIcon,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Icon(
                            Iconsax.flash_circle,
                            size: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 10.sp,
                          color: AppColors.muted,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            hospital.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      hospital.departments.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: AppColors.body,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedHospitalCard extends StatefulWidget {
  const _FeaturedHospitalCard({required this.hospital});

  final HospitalModel hospital;

  @override
  State<_FeaturedHospitalCard> createState() => _FeaturedHospitalCardState();
}

class _FeaturedHospitalCardState extends State<_FeaturedHospitalCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hospital = widget.hospital;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 132.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(path: hospital.imagePath, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Featured',
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (hospital.isEmergency)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardioIcon,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '24/7 Emergency',
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      hospital.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Iconsax.location, size: 11.sp, color: Colors.white70),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            '${hospital.address} · ${hospital.distance}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Icon(Iconsax.star, size: 11.sp, color: AppColors.star),
                        SizedBox(width: 2.w),
                        Text(
                          hospital.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HospitalListCard extends StatefulWidget {
  const _HospitalListCard({
    required this.hospital,
    required this.index,
  });

  final HospitalModel hospital;
  final int index;

  @override
  State<_HospitalListCard> createState() => _HospitalListCardState();
}

class _HospitalListCardState extends State<_HospitalListCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _in;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 380 + (widget.index * 40).clamp(0, 180)),
    )..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospital = widget.hospital;
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
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.985 : 1,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOutCubic,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.65),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 6,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: SizedBox(
                          width: 72.w,
                          height: 78.h,
                          child: AppImage(
                            path: hospital.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4.w,
                        top: 4.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: hospital.isOpen
                                ? AppColors.success
                                : AppColors.muted,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            hospital.isOpen ? 'Open' : 'Closed',
                            style: GoogleFonts.poppins(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: SizedBox(
                      height: 78.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hospital.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              if (hospital.isEmergency)
                                Icon(
                                  Iconsax.flash_circle,
                                  size: 13.sp,
                                  color: AppColors.cardioIcon,
                                ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Iconsax.location,
                                size: 11.sp,
                                color: AppColors.muted,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  hospital.address,
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
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Icon(Iconsax.star, size: 11.sp, color: AppColors.star),
                              SizedBox(width: 2.w),
                              Text(
                                hospital.rating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                ' (${hospital.reviews})',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.sp,
                                  color: AppColors.muted,
                                ),
                              ),
                              Container(
                                width: 2.5.w,
                                height: 2.5.w,
                                margin: EdgeInsets.symmetric(horizontal: 5.w),
                                decoration: const BoxDecoration(
                                  color: AppColors.muted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                hospital.distance,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hospital.departments.take(2).join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
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
                                  'Details',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
