import 'package:flutter/material.dart';

/// Top bar with a back button and a slim progress indicator.
class TopNav extends StatelessWidget {
  final double progress; // 0..1
  const TopNav({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1C1F1E)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE9ECE9),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF2FBF6D)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
