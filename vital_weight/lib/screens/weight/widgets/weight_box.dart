import 'package:flutter/material.dart';
import 'package:vital_weight/screens/weight/weight_screen.dart';
import 'package:vital_weight/theme/app_theme.dart';

/// Glass card that displays the currently selected weight value.
class WeightBox extends StatelessWidget {
  final double value;
  final WeightUnit unit;
  const WeightBox({super.key, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.55),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.round().toString(),
            style: AppType.display(size: 34),
          ),
          const SizedBox(height: 4),
          Text(
            unit == WeightUnit.kg ? 'kilograms' : 'pounds',
            style: AppType.body(size: 10.5, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
