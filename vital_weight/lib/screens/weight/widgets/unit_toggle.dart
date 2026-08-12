import 'package:flutter/material.dart';
import 'package:vital_weight/screens/weight/weight_screen.dart';

class UnitToggle extends StatelessWidget {
  final WeightUnit unit;
  final ValueChanged<WeightUnit> onChanged;
  const UnitToggle({super.key, required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF1EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF1C1F1E) : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
