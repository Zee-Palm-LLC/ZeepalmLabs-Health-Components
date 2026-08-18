import 'package:flutter/material.dart';
import 'package:vital_weight/screens/weight/weight_screen.dart';
import 'package:vital_weight/theme/app_theme.dart';

class UnitToggle extends StatelessWidget {
  final WeightUnit unit;
  final ValueChanged<WeightUnit> onChanged;
  const UnitToggle({super.key, required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton('kg', WeightUnit.kg),
          _toggleButton('lbs', WeightUnit.lbs),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, WeightUnit value) {
    final bool active = unit == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppType.body(
            size: 13.5,
            weight: FontWeight.w700,
            color: active ? Colors.white : AppColors.softGrey,
          ),
        ),
      ),
    );
  }
}
