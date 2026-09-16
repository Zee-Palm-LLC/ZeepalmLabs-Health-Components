import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    required this.initials,
    required this.color,
    this.asset,
    this.diameter = 22,
    this.ringWidth = 2,
  });

  final String initials;
  final Color color;
  final String? asset;
  final double diameter;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        initials,
        style: AppTypography.micro.copyWith(
          fontSize: diameter * 0.36,
          fontWeight: FontWeight.w700,
          color: AppColors.surface,
          height: 1,
        ),
      ),
    );

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: ringWidth > 0 ? Border.all(color: AppColors.surface, width: ringWidth) : null,
        boxShadow: AppShadows.card,
      ),
      child: asset == null
          ? fallback
          : ClipOval(
              child: Image.asset(
                asset!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
            ),
    );
  }
}
