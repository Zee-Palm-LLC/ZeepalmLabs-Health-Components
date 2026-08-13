import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../components/organ_model_viewer.dart';
import '../data/organs_data.dart';
import '../models/organ.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OrganDetailScreen extends StatelessWidget {
  const OrganDetailScreen({super.key, required this.organId});

  final String organId;

  @override
  Widget build(BuildContext context) {
    final organ = organById(organId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.mistGradient),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 420.h,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: _CircleIconButton(
                  icon: Iconsax.arrow_left_2,
                  onTap: () => Get.back(),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _CircleIconButton(
                    icon: Iconsax.bookmark,
                    onTap: () {},
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        SizedBox(height: 48.h),
                        Expanded(
                          child: OrganModelViewer(
                            organ: organ.id,
                            height: 320.h,
                            compact: true,
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -18.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28.r),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: organ.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            organ.system.toUpperCase(),
                            style: AppTypography.overline(size: 10),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        organ.name,
                        style: AppTypography.display(size: 34),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${organ.scientificName}  ·  ${organ.poetic}',
                        style: AppTypography.body(
                          size: 14,
                          color: AppColors.muted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        organ.description,
                        style: AppTypography.body(
                          size: 15,
                          height: 1.55,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'Key landmarks',
                        style: AppTypography.title(size: 20),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap a region on the model or explore below',
                        style: AppTypography.body(
                          size: 13,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ...organ.hotspots.map(
                        (hotspot) => _HotspotTile(hotspot: hotspot),
                      ),
                      SizedBox(height: 24.h),
                      _StudyActions(organ: organ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotspotTile extends StatelessWidget {
  const _HotspotTile({required this.hotspot});

  final Hotspot hotspot;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: hotspot.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: hotspot.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotspot.label,
                  style: AppTypography.body(
                    size: 15,
                    weight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  hotspot.detail,
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Iconsax.arrow_right_3,
            size: 18.sp,
            color: AppColors.mutedLight,
          ),
        ],
      ),
    );
  }
}

class _StudyActions extends StatelessWidget {
  const _StudyActions({required this.organ});

  final Organ organ;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Start lesson',
            icon: Iconsax.play,
            filled: true,
            onTap: () {},
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _ActionButton(
            label: 'Compare',
            icon: Iconsax.arrange_square,
            filled: false,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.accent : AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: filled ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: filled ? Colors.white : AppColors.accentDeep,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTypography.label(
                  size: 13,
                  weight: FontWeight.w700,
                  color: filled ? Colors.white : AppColors.accentDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(icon, size: 20.sp, color: AppColors.ink),
        ),
      ),
    );
  }
}
