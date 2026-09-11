import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/app_motion.dart';

class NavItem {
  const NavItem(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const kNavItems = <NavItem>[
  NavItem(Iconsax.home_2, Iconsax.home_25, 'Home'),
  NavItem(Iconsax.chart_21, Iconsax.chart_215, 'Insights'),
  NavItem(Iconsax.trend_up, Iconsax.trend_up5, 'Trends'),
  NavItem(Iconsax.user, Iconsax.user5, 'Profile'),
];

/// Solid black, edge-to-edge bottom bar — no floating dock.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int>? onChanged;

  static double get barHeight => 64.h;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          SizedBox(
            height: barHeight,
            child: Row(
              children: [
                for (var i = 0; i < kNavItems.length; i++)
                  Expanded(
                    child: _NavTab(
                      item: kNavItems[i],
                      active: i == currentIndex,
                      onTap: () {
                        if (i == currentIndex) return;
                        HapticFeedback.selectionClick();
                        onChanged?.call(i);
                      },
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : const Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.06),
      highlightColor: Colors.transparent,
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: AppMotion.enter,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: child,
              ),
              child: Icon(
                active ? item.activeIcon : item.icon,
                key: ValueKey('${item.label}-$active'),
                size: 22.sp,
                color: color,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                height: 1,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.1,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
