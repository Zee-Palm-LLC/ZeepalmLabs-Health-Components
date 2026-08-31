import 'package:fit_profile/core/motion/app_motion.dart';
import 'package:flutter/material.dart';

/// Smooth numeric/text transitions without extra controllers.
class AnimatedValueText extends StatelessWidget {
  const AnimatedValueText({
    super.key,
    required this.value,
    required this.style,
    this.format,
  });

  final double value;
  final TextStyle style;
  final String Function(double value)? format;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.dur(context, AppMotion.normal);

    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(end: value),
      duration: duration,
      curve: AppMotion.curve,
      builder: (context, animated, _) {
        final text = format != null
            ? format!(animated)
            : animated == animated.roundToDouble()
                ? '${animated.toInt()}'
                : animated.toStringAsFixed(1);

        return Text(text, style: style);
      },
    );
  }
}
