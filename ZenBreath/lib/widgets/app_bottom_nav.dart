import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';

class NavDestination {
  const NavDestination(this.icon, this.label);
  final IconData icon;
  final String label;
}

const kNavDestinations = <NavDestination>[
  NavDestination(LucideIcons.house, 'Home'),
  NavDestination(LucideIcons.timer, 'Sessions'),
  NavDestination(LucideIcons.trendingUp, 'Progress'),
  NavDestination(LucideIcons.user, 'Profile'),
];

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onChanged});
  final int currentIndex;
  final ValueChanged<int> onChanged;

  void _select(int index) {
    if (index == currentIndex) return;
    HapticFeedback.lightImpact();
    onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: MediaQuery.paddingOf(context).bottom + 8.h),
      decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppShadows.nav),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: currentIndex.toDouble()),
        duration: AppMotion.tab,
        curve: Curves.easeOutCubic,
        builder: (context, position, _) => Stack(
          children: [
            Positioned.fill(child: _Halo(position: position)),
            Row(
              children: [
                for (var i = 0; i < kNavDestinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      destination: kNavDestinations[i],

                      amount: (1 - (position - i).abs()).clamp(0.0, 1.0),
                      onTap: () => _select(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.position});
  final double position;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slot = constraints.maxWidth / kNavDestinations.length;
        final size = 42.r;

        return Stack(
          children: [
            Positioned(
              left: slot * position + (slot - size) / 2,
              top: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.20),
                      AppColors.gold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.destination, required this.amount, required this.onTap});
  final NavDestination destination;
  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(AppColors.textTertiary, AppColors.gold, amount)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, -3.h * amount),
            child: Transform.scale(
              scale: 1 + 0.10 * amount,
              child: Icon(destination.icon, size: 22.r, color: color),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            destination.label,
            style: AppText.body(
              11.5,
              weight: amount > 0.5 ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
