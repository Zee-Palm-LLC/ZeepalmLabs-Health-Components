import 'package:flutter/material.dart';
import 'package:vital_weight/screens/weight/weight_screen.dart';
import 'package:vital_weight/theme/app_theme.dart';

class WeightBox extends StatelessWidget {
  final double value;
  final WeightUnit unit;
  const WeightBox({super.key, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.45),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              value.round().toString(),
              key: ValueKey(value.round()),
              style: AppType.display(size: 36),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit == WeightUnit.kg ? 'kilograms' : 'pounds',
            style: AppType.body(size: 10.5, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
