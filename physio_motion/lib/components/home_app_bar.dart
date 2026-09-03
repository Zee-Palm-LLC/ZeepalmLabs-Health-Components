import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:physio_motion/theme/app_colors.dart';

/// Home top bar — blurs as [scrollProgress] goes from 0 → 1.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.scrollProgress = 0,
    this.onMenuTap,
    this.onNotificationTap,
  });

  /// 0 = clear, 1 = fully blurred frosted bar.
  final double scrollProgress;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = scrollProgress.clamp(0.0, 1.0);
    final blur = 16 * t;
    final tint = AppColors.bg.withValues(alpha: 0.55 * t);

    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: onMenuTap ?? () {},
        icon: const Icon(Iconsax.menu_1_copy, color: AppColors.textPrimary),
      ),
      actions: [
        IconButton(
          onPressed: onNotificationTap ?? () {},
          icon: const Icon(Iconsax.notification, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: double.infinity,
            height: double.infinity,
            color: tint,
          ),
        ),
      ),
    );
  }
}
