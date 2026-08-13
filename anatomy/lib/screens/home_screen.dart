import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../components/home/app_bottom_nav.dart';
import '../components/home/organ_card.dart';
import '../components/home/section_header.dart';
import '../components/home/stat_card.dart';
import '../components/organ_model_viewer.dart';
import '../controllers/organ_controller.dart';
import '../data/organs_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'organ_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}) {
    Get.put(OrganController());
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.mistGradient),
        child: SafeArea(
          bottom: false,
          child: GetBuilder<OrganController>(
            builder: (controller) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverToBoxAdapter(child: _buildHero(context, controller)),
                  SliverToBoxAdapter(child: _buildStats()),
                  SliverToBoxAdapter(child: _buildSystems(controller)),
                  SliverToBoxAdapter(child: _buildExploreHeader(controller)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14.h,
                        crossAxisSpacing: 14.w,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final visible = controller.visibleOrgans;
                          final organ = visible[index];
                          return OrganCard(
                            organ: organ,
                            selected: controller.selected == organ.id,
                            onTap: () {
                              if (controller.selected == organ.id) {
                                Get.to(
                                  () => OrganDetailScreen(organId: organ.id),
                                  transition: Transition.cupertino,
                                );
                              } else {
                                controller.select(organ.id);
                              }
                            },
                          );
                        },
                        childCount: controller.visibleOrgans.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 110.h + MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: GetBuilder<OrganController>(
        builder: (controller) => AppBottomNav(
          currentIndex: controller.navIndex,
          onIndexChanged: controller.setNavIndex,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.muted,
                    weight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Anatomy Atelier',
                  style: AppTypography.display(size: 26),
                ),
              ],
            ),
          ),
          _HeaderChip(
            icon: Iconsax.global,
            label: 'EN',
            onTap: () {},
          ),
          SizedBox(width: 10.w),
          const _ProfileAvatar(),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, OrganController controller) {
    final organ = controller.selectedOrgan;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentDeep.withValues(alpha: 0.35),
              blurRadius: 28.r,
              offset: Offset(0, 14.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -40.h,
              right: -30.w,
              child: Container(
                width: 160.w,
                height: 160.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 40.h,
              left: -50.w,
              child: Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                  child: Row(
                    children: [
                      Text(
                        'STUDIO SPECIMEN',
                        style: AppTypography.overline(
                          size: 10,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          organ.system,
                          style: AppTypography.label(
                            size: 10,
                            color: Colors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                OrganModelViewer(
                  organ: controller.selected,
                  height: 300.h,
                  compact: true,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 18.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              child: Text(
                                organ.name,
                                key: ValueKey(organ.id),
                                style: AppTypography.display(
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${organ.scientificName}  ·  ${organ.poetic}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                size: 12,
                                color: Colors.white.withValues(alpha: 0.78),
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _OpenButton(
                        onTap: () => Get.to(
                          () => OrganDetailScreen(organId: organ.id),
                          transition: Transition.cupertino,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
      child: Row(
        children: [
          StatCard(
            icon: Iconsax.d_cube_scan,
            value: '${organs.length}',
            label: 'Organs',
            color: AppColors.accent,
          ),
          SizedBox(width: 10.w),
          StatCard(
            icon: Iconsax.hierarchy_2,
            value: '${bodySystems.length}',
            label: 'Systems',
            color: AppColors.accentMuted,
          ),
          SizedBox(width: 10.w),
          StatCard(
            icon: Iconsax.flash_1,
            value: '7',
            label: 'Streak',
            color: AppColors.highlight,
          ),
        ],
      ),
    );
  }

  Widget _buildSystems(OrganController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 0),
          child: const SectionHeader(
            title: 'Body systems',
            subtitle: 'Learn by system',
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 42.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: bodySystems.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final system = bodySystems[index];
              final selected = controller.activeSystem == system.name;
              final accent = organById(system.organIds.first).accent;
              return GestureDetector(
                onTap: () => controller.toggleSystem(system.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent
                        : AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        system.name,
                        style: AppTypography.label(
                          size: 12,
                          weight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExploreHeader(OrganController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 14.h),
      child: SectionHeader(
        title: 'Explore organs',
        subtitle: 'Specimen library',
        actionLabel: controller.activeSystem != null ? 'Clear' : null,
        onActionTap: controller.clearSystemFilter,
      ),
    );
  }
}

class _OpenButton extends StatelessWidget {
  const _OpenButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Open',
                style: AppTypography.label(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.accentDeep,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Iconsax.arrow_right_3,
                size: 16.sp,
                color: AppColors.accentDeep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: AppColors.accent),
              SizedBox(width: 5.w),
              Text(
                label,
                style: AppTypography.label(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.avatarGradient,
        border: Border.all(color: Colors.white, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withValues(alpha: 0.25),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Icon(Iconsax.user, size: 20.sp, color: Colors.white),
    );
  }
}
