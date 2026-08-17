import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class FloatingActionOrb extends StatelessWidget {
  const FloatingActionOrb({
    super.key,
    required this.color,
    required this.icon,
    this.size = 48,
    this.iconSize = 22,
    this.iconColor = AppColors.white,
  });

  final Color color;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}
