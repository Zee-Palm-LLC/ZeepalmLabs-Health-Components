import 'package:vital_heart/core/motion/app_motion.dart';
import 'package:vital_heart/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AnimatedBpmText extends StatelessWidget {
  const AnimatedBpmText({
    super.key,
    required this.bpm,
  });

  final int bpm;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.curveOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        '$bpm',
        key: ValueKey(bpm),
        style: AppTextStyles.heroBpm,
      ),
    );
  }
}
