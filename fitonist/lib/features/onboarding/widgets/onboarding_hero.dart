import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/widgets/ambient_background.dart';

class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    super.key,
    required this.imageAsset,
    required this.glowColor,
    required this.pageOffset,
    this.heroRadius = 0,
  });

  final String imageAsset;
  final Color glowColor;
  final double pageOffset;
  final double heroRadius;

  @override
  Widget build(BuildContext context) {
    final distance = pageOffset.abs().clamp(0.0, 1.0);
    final focus = 1 - distance;
    final scale = 0.86 + (focus * 0.14);
    final translateX = pageOffset * 42.w;
    final translateY = distance * 22.h;
    final rotateY = pageOffset * 0.14;
    final opacity = (1 - distance * 0.55).clamp(0.45, 1.0);
    final blur = distance * 3.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content = Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.scale(
              scale: 0.92 + (focus * 0.08),
              child: HeroGlow(
                color: glowColor.withValues(alpha: 0.55 + focus * 0.45),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(heroRadius.r),
              child: Image.asset(
                imageAsset,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ],
        );

        if (blur > 0.1) {
          content = ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
              tileMode: TileMode.decal,
            ),
            child: content,
          );
        }

        return Center(
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(translateX, translateY),
              child: Transform.scale(
                scale: scale,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateY(rotateY),
                  child: content,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gentle idle float layered on top of page scroll transforms.
class FloatingHeroWrapper extends StatefulWidget {
  const FloatingHeroWrapper({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<FloatingHeroWrapper> createState() => _FloatingHeroWrapperState();
}

class _FloatingHeroWrapperState extends State<FloatingHeroWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    if (widget.enabled && !Get.testMode) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_float.value);
        final dy = math.sin(t * math.pi) * 6.h;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}
