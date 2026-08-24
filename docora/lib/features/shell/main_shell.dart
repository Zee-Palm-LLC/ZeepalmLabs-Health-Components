import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../booking/book_appointment_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../hospital/hospital_screen.dart';
import '../settings/settings_screen.dart';

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
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: const [
              HomeScreen(),
              HospitalScreen(),
              SizedBox.shrink(),
              FavoritesScreen(),
              SettingsScreen(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _LuxuryFloatingNav(
              currentIndex: _index,
              onChanged: (i) {
                if (i == 2) return;
                setState(() => _index = i);
              },
              onBook: () {
                Get.to(
                  () => const BookAppointmentScreen(),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryFloatingNav extends StatelessWidget {
  const _LuxuryFloatingNav({
    required this.currentIndex,
    required this.onChanged,
    required this.onBook,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottom + 12.h),
      child: SizedBox(
        height: 92.h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Floating pill bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 68.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.r),
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.7),
                    width: 0.8.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: Offset(0, 12.h),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: Offset(0, 6.h),
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
                    SizedBox(width: 64.w),
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
                        icon: Iconsax.setting_2,
                        label: 'Settings',
                        selected: currentIndex == 4,
                        onTap: () => onChanged(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center book button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _CenterBookButton(onTap: onBook),
              ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 68.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 12.w : 8.w,
                vertical: selected ? 6.h : 5.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: selected
                    ? AppColors.primaryLight.withValues(alpha: 0.9)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                size: 22.sp,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterBookButton extends StatefulWidget {
  const _CenterBookButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CenterBookButton> createState() => _CenterBookButtonState();
}

class _CenterBookButtonState extends State<_CenterBookButton>
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
          final glow = 0.28 + (_pulse.value * 0.20);
          return AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A9AFF),
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                border: Border.all(color: Colors.white, width: 3.5.w),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: glow),
                    blurRadius: 20,
                    spreadRadius: 1,
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
        child: Icon(
          Iconsax.add,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
    );
  }
}
