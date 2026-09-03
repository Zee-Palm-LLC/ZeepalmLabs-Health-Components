import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:physio_motion/theme/app_colors.dart';

/// Floating pill bottom nav — dark capsule with glowing lime action.
class PhysioBottomNav extends StatefulWidget {
  const PhysioBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    this.onCenterTap,
  });

  /// Selected tab: 0 Home · 1 Activity · 3 Stats · 4 Profile (2 = center).
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback? onCenterTap;

  static const double barHeight = 64;
  static const double outerBottom = 16;
  static const double horizontalInset = 28;

  /// Space to leave under scroll content so it clears the floating bar.
  static double contentClearance(BuildContext context) {
    return barHeight + outerBottom + MediaQuery.paddingOf(context).bottom + 16;
  }

  @override
  State<PhysioBottomNav> createState() => _PhysioBottomNavState();
}

class _PhysioBottomNavState extends State<PhysioBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        PhysioBottomNav.horizontalInset,
        0,
        PhysioBottomNav.horizontalInset,
        PhysioBottomNav.outerBottom + bottom,
      ),
      child: Container(
        height: PhysioBottomNav.barHeight,
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(PhysioBottomNav.barHeight / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            _NavIcon(
              icon: Iconsax.home_2,
              selected: widget.index == 0,
              onTap: () => widget.onChanged(0),
            ),
            _NavIcon(
              icon: Icons.directions_run_rounded,
              selected: widget.index == 1,
              onTap: () => widget.onChanged(1),
            ),
            _CenterAction(
              glow: _glow,
              onTap: widget.onCenterTap ?? () => widget.onChanged(2),
            ),
            _NavIcon(
              icon: Iconsax.chart_2,
              selected: widget.index == 3,
              onTap: () => widget.onChanged(3),
            ),
            _NavIcon(
              icon: Iconsax.user,
              selected: widget.index == 4,
              onTap: () => widget.onChanged(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.lime.withValues(alpha: 0.12),
        highlightColor: AppColors.lime.withValues(alpha: 0.06),
        child: Center(
          child: AnimatedScale(
            scale: selected ? 1.08 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              child: Icon(
                icon,
                size: 24,
                color: selected
                    ? AppColors.lime
                    : const Color(0xFF8A8A8A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  const _CenterAction({required this.onTap, required this.glow});

  final VoidCallback onTap;
  final Animation<double> glow;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: AnimatedBuilder(
          animation: glow,
          builder: (context, child) {
            final t = glow.value;
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lime.withValues(alpha: 0.28 + t * 0.28),
                    blurRadius: 14 + t * 8,
                    spreadRadius: t * 1.5,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Material(
            color: AppColors.lime,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Iconsax.add,
                  size: 26,
                  color: AppColors.dark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
