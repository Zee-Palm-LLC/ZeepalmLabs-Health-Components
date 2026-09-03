import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:physio_motion/theme/app_colors.dart';

class WelcomeStartButton extends StatefulWidget {
  const WelcomeStartButton({
    super.key,
    this.size = 140,
    this.onTap,
    this.ambient,
  });

  final double size;
  final VoidCallback? onTap;

  /// Optional 0↔1 looping animation for living lime glow.
  final Animation<double>? ambient;

  @override
  State<WelcomeStartButton> createState() => _WelcomeStartButtonState();
}

class _WelcomeStartButtonState extends State<WelcomeStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.92,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ambient = widget.ambient;

    Widget button = GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _press.reverse(),
      onTapCancel: widget.onTap == null ? null : () => _press.forward(),
      onTapUp: widget.onTap == null
          ? null
          : (_) async {
              await _press.forward();
              widget.onTap?.call();
            },
      child: ScaleTransition(
        scale: _press,
        child: Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lime, width: 1.5),
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.dark,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'START',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    height: 1,
                    color: AppColors.lime,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'YOUR JOURNEY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.lime,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ambient == null) return button;

    return AnimatedBuilder(
      animation: ambient,
      builder: (context, child) {
        final t = ambient.value;
        final glow = 0.28 + (t * 0.42);
        final breathe = 1 + (math.sin(t * math.pi) * 0.025);

        return Transform.scale(
          scale: breathe,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lime.withValues(alpha: glow * 0.55),
                  blurRadius: 28 + (t * 18),
                  spreadRadius: 2 + (t * 4),
                ),
                BoxShadow(
                  color: AppColors.lime.withValues(alpha: glow * 0.25),
                  blurRadius: 48 + (t * 24),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: button,
    );
  }
}
