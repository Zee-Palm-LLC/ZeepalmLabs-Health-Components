import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_text.dart';

/// White rounded panel shared by the dashboard, progress and profile screens.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding, this.color, this.radius});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: AppDecoration.card(radius: radius, color: color),
      child: child,
    );
  }
}

/// `icon + title` row that heads most cards in the reference.
class CardHeading extends StatelessWidget {
  const CardHeading({
    super.key,
    required this.title,
    this.icon,
    this.iconColor = AppColors.aquaDeep,
    this.trailing,
    this.showChevron = false,
  });

  final String title;
  final IconData? icon;
  final Color iconColor;
  final Widget? trailing;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 15.r, color: iconColor), SizedBox(width: 5.w)],
        Expanded(
          child: Text(
            title,
            style: AppText.body(13, weight: FontWeight.w500, color: AppColors.textSecondary),
          ),
        ),
        ?trailing,
        if (showChevron)
          Icon(LucideIcons.chevronRight, size: 16.r, color: AppColors.textTertiary),
      ],
    );
  }
}
