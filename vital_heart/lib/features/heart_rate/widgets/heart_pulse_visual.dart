import 'dart:math' as math;

import 'package:vital_heart/core/motion/app_motion.dart';
import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HeartPulseVisual extends StatefulWidget {
  const HeartPulseVisual({super.key});

  @override
  State<HeartPulseVisual> createState() => _HeartPulseVisualState();
}

class _HeartPulseVisualState extends State<HeartPulseVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotionOf(context)) {
      return _HeartStack(
        progress: 0.5,
        ripples: const [0.0, 0.33, 0.66],
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _HeartStack(
        progress: _controller.value,
        ripples: const [0.0, 0.33, 0.66],
      ),
    );
  }
}

class _HeartStack extends StatelessWidget {
  const _HeartStack({
    required this.progress,
    required this.ripples,
  });

  final double progress;
  final List<double> ripples;

  @override
  Widget build(BuildContext context) {
    final beat = Curves.easeInOut.transform(
      math.sin(progress * math.pi * 2) * 0.5 + 0.5,
    );

    const size = 240.0;
    const coreSize = 76.0;
    const iconSize = 68.0;
    const rippleBase = 72.0;

    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.heartGlow.withValues(
                    alpha: 0.2 + beat * 0.22,
                  ),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          for (final offset in ripples)
            _HeartRipple(
              progress: ((progress + offset) % 1.0),
              baseSize: rippleBase.w,
            ),
          for (var i = 2; i >= 0; i--)
            _HeartShade(
              scale: 0.52 + (i * 0.08) + (beat * 0.03),
              opacity: (0.05 + i * 0.04) * (0.45 + beat * 0.55),
              size: size.w,
            ),
          Transform.scale(
            scale: 0.9 + (beat * 0.12),
            child: Container(
              width: coreSize.w,
              height: coreSize.w,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.heartGlow.withValues(alpha: 0.65),
                    blurRadius: 36,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF8CB3),
                    AppColors.heartGlow,
                    AppColors.heartCore,
                    AppColors.accentDeep,
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ).createShader(bounds),
                child: Icon(
                  Iconsax.heart,
                  size: iconSize.w,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartRipple extends StatelessWidget {
  const _HeartRipple({
    required this.progress,
    required this.baseSize,
  });

  final double progress;
  final double baseSize;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final scale = 1.0 + (t * 1.85);
    final opacity = (1 - t) * 0.42;

    return Transform.scale(
      scale: scale,
      child: Icon(
        Iconsax.heart,
        size: baseSize,
        color: AppColors.accent.withValues(alpha: opacity),
      ),
    );
  }
}

class _HeartShade extends StatelessWidget {
  const _HeartShade({
    required this.scale,
    required this.opacity,
    required this.size,
  });

  final double scale;
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Icon(
        Iconsax.heart,
        size: size,
        color: AppColors.accent.withValues(alpha: opacity),
      ),
    );
  }
}
