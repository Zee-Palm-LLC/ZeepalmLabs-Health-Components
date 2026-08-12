import 'package:flutter/material.dart';
import 'package:vital_weight/screens/weight/weight_screen.dart';

class WeightBox extends StatelessWidget {
  final double value;
  final WeightUnit unit;
  const WeightBox({super.key, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF3BCF6E), width: 2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3CB46E).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        value.round().toString(),
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1F1E),
        ),
      ),
    );
  }
}
