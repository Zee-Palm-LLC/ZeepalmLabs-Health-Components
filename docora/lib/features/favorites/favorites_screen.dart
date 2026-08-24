import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/components/custom_shade.dart';
import '../doctor/doctor_detail_screen.dart';
import '../messages/components/message_motion.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<DoctorModel> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = [
      MockData.featured,
      ...MockData.topRated,
      MockData.nearMe.first,
      MockData.upcoming,
    ];
  }

  void _remove(DoctorModel doctor) {
    setState(() => _favorites.removeWhere((d) => d.id == doctor.id));
  }

  @override
  Widget build(BuildContext context) {
    final left = <DoctorModel>[];
    final right = <DoctorModel>[];
    for (var i = 0; i < _favorites.length; i++) {
      (i.isEven ? left : right).add(_favorites[i]);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 56.h,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favorites',
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.2,
              ),
            ),
            Text(
              '${_favorites.length} saved doctors',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.body,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const CustomShade(height: 96),
          SafeArea(
            child: _favorites.isEmpty
                ? const _EmptyFavorites()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 118.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              for (var i = 0; i < left.length; i++) ...[
                                if (i > 0) SizedBox(height: 10.h),
                                FadeScaleIn(
                                  delay: Duration(milliseconds: 40 + i * 90),
                                  child: _FavoriteCard(
                                    doctor: left[i],
                                    tall: i.isEven,
                                    onRemove: () => _remove(left[i]),
                                    onTap: () => AppNav.to(
                                      DoctorDetailScreen(doctor: left[i]),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 18.h),
                              for (var i = 0; i < right.length; i++) ...[
                                if (i > 0) SizedBox(height: 10.h),
                                FadeScaleIn(
                                  delay: Duration(milliseconds: 90 + i * 90),
                                  child: _FavoriteCard(
                                    doctor: right[i],
                                    tall: i.isOdd,
                                    onRemove: () => _remove(right[i]),
                                    onTap: () => AppNav.to(
                                      DoctorDetailScreen(doctor: right[i]),
                                    ),
                                  ),
                                ),
                              ],
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

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.doctor,
    required this.tall,
    required this.onRemove,
    this.onTap,
  });

  final DoctorModel doctor;
  final bool tall;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: tall ? 132.h : 108.h,
                  width: double.infinity,
                  child: doctor.imageUrl == null
                      ? ColoredBox(color: doctor.avatarColor)
                      : AppImage(path: doctor.imageUrl!, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: PressScale(
                    onTap: onRemove,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 14.sp,
                        color: AppColors.cardioIcon,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    doctor.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.body,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Iconsax.star, size: 12.sp, color: AppColors.star),
                      SizedBox(width: 3.w),
                      Text(
                        doctor.rating.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${doctor.fee.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.heart, size: 28.sp, color: AppColors.muted),
          SizedBox(height: 8.h),
          Text(
            'No favorites yet',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
