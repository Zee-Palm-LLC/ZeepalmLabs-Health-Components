import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  static const List<({IconData icon, IconData activeIcon, String label})>
      _items = [
    (icon: Iconsax.home_1, activeIcon: Iconsax.home, label: 'Home'),
    (icon: Iconsax.discover, activeIcon: Iconsax.discover_1, label: 'Explore'),
    (icon: Iconsax.book_1, activeIcon: Iconsax.book_saved, label: 'Learn'),
    (icon: Iconsax.bookmark, activeIcon: Iconsax.bookmark_2, label: 'Saved'),
    (icon: Iconsax.user, activeIcon: Iconsax.user_tick, label: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h + bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.08),
              blurRadius: 24.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onIndexChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accentSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.05 : 1,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            selected ? item.activeIcon : item.icon,
                            size: 22.sp,
                            color: selected
                                ? AppColors.accentDeep
                                : AppColors.mutedLight,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: AppTypography.label(
                            size: 10,
                            weight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? AppColors.accentDeep
                                : AppColors.mutedLight,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
