import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../home/home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          _PlaceholderTab(label: 'Hospital'),
          SizedBox.shrink(),
          _PlaceholderTab(label: 'Favorites'),
          _PlaceholderTab(label: 'Profile'),
        ],
      ),
      bottomNavigationBar: _FloatingBottomNav(
        currentIndex: _index,
        onChanged: (i) {
          if (i == 2) {
            return;
          }
          setState(() => _index = i);
        },
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label, style: AppTextStyles.sectionTitle));
  }
}

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, bottom + 14.h),
      child: SizedBox(
        height: 78.h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 64.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.65),
                  width: 0.6.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: Offset(0, 10.h),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Iconsax.home_2,
                      label: 'Home',
                      selected: currentIndex == 0,
                      onTap: () => onChanged(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Iconsax.hospital,
                      label: 'Hospital',
                      selected: currentIndex == 1,
                      onTap: () => onChanged(1),
                    ),
                  ),
                  SizedBox(width: 56.w),
                  Expanded(
                    child: _NavItem(
                      icon: Iconsax.heart,
                      label: 'Favorites',
                      selected: currentIndex == 3,
                      onTap: () => onChanged(3),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Iconsax.user,
                      label: 'Profile',
                      selected: currentIndex == 4,
                      onTap: () => onChanged(4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: _SearchFab(onTap: () => onChanged(2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: selected ? 42.w : 36.w,
              height: selected ? 30.h : 28.h,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryLight.withValues(alpha: 0.85)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: selected ? 1.05 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(icon, size: 20.sp, color: color),
              ),
            ),
            SizedBox(height: 3.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10.sp,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFab extends StatefulWidget {
  const _SearchFab({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SearchFab> createState() => _SearchFabState();
}

class _SearchFabState extends State<_SearchFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (!Get.testMode) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final glow = 0.28 + (_pulse.value * 0.18);
          return AnimatedScale(
            scale: _pressed ? 0.94 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 3.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: glow),
                    blurRadius: 20,
                    offset: Offset(0, 8.h),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Icon(Iconsax.search_normal_1, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
