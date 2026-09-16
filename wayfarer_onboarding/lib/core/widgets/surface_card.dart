import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.radius = 14,
    this.padding = EdgeInsets.zero,
    this.elevated = false,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: elevated ? AppShadows.raised : AppShadows.card,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
