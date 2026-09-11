import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_colors.dart';
import 'animations.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 22,
    this.tint,
    this.borderColor,
    this.edgeGradient,
    this.blur = 0,
    this.onTap,
    this.glow,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? tint;
  final Color? borderColor;
  final Gradient? edgeGradient;
  /// Kept for API compatibility — blur is disabled for scroll performance.
  final double blur;
  final VoidCallback? onTap;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final corners = BorderRadius.circular(radius.r);

    // Opaque card (no BackdropFilter) — major scroll FPS win.
    Widget surface = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: corners,
        color: tint ?? AppColors.card.withValues(alpha: 0.94),
        border: edgeGradient == null
            ? Border.all(color: borderColor ?? AppColors.stroke)
            : null,
      ),
      child: child,
    );

    if (edgeGradient != null) {
      surface = Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: corners,
          gradient: edgeGradient,
        ),
        child: ClipRRect(
          borderRadius: corners,
          child: ColoredBox(
            color: tint ?? AppColors.card.withValues(alpha: 0.96),
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ),
      );
    }

    if (glow != null) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: corners,
          boxShadow: [
            BoxShadow(
              color: glow!.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: surface,
      );
    }

    return onTap == null
        ? surface
        : PressableScale(onTap: onTap, child: surface);
  }
}
