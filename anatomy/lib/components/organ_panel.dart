import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/organ_controller.dart';
import '../theme/app_colors.dart';

class OrganPanel extends StatelessWidget {
  const OrganPanel({
    super.key,
    required this.selectedOrgan,
    required this.onOrganSelected,
  });

  final String selectedOrgan;
  final ValueChanged<String> onOrganSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 58.w,
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.1),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(OrganController.organIds.length, (index) {
            final organ = OrganController.organIds[index];
            return _OrganItem(
              organ: organ,
              selected: organ == selectedOrgan,
              onTap: () => onOrganSelected(organ),
            );
          }),
        ),
      ),
    );
  }
}

class _OrganItem extends StatelessWidget {
  const _OrganItem({
    required this.organ,
    required this.selected,
    required this.onTap,
  });

  final String organ;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(selected ? 2.w : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: selected
              ? Border.all(color: AppColors.accent, width: 1.5)
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 10.r,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.asset(
            'assets/images/anatomy/$organ/thumb.webp',
            width: 44.w,
            height: 44.w,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
