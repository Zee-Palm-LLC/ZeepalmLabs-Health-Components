import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Frosted glass panel with soft highlight and depth shadows.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = 16,
    this.opacity = 0.58,
    this.borderOpacity = 0.82,
    this.showSpecular = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final bool showSpecular;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 16.r;

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B8AAE).withValues(alpha: 0.14),
              blurRadius: 22,
              offset: Offset(0, 10.h),
            ),
            if (showSpecular)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.55),
                blurRadius: 1,
                offset: Offset(0, -0.5.h),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: opacity + 0.12),
                    Colors.white.withValues(alpha: opacity - 0.08),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: borderOpacity),
                  width: 1.1,
                ),
              ),
              child: padding == null
                  ? child
                  : Padding(padding: padding!, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inset glass tile used inside quick-access cards.
class GlassInset extends StatelessWidget {
  const GlassInset({
    super.key,
    required this.child,
    this.size,
  });

  final Widget child;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final box = size ?? 34.w;

    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white.withValues(alpha: 0.34),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E7FA0).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: Offset(0, 2.h),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.65),
            blurRadius: 4,
            offset: Offset(-1.w, -1.h),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
