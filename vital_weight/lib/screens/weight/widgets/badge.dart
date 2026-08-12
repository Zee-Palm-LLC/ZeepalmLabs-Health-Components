import 'package:flutter/material.dart';

/// Glossy green circular badge icon at the top of the content.
class WeightBadge extends StatelessWidget {
  const WeightBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Color(0xFFBDF0CF),
            Color(0xFF6FE3A3),
            Color(0xFF2FBF6D),
            Color(0xFFBDF0CF),
          ],
          stops: [0.0, 0.3, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3CB46E).withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.7),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
