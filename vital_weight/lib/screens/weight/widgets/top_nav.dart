import 'package:flutter/material.dart';
import 'package:vital_weight/theme/app_theme.dart';

/// Top bar with a frosted back button and a slim progress indicator.
class TopNav extends StatelessWidget {
  final double progress; // 0..1
  const TopNav({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C1F1E).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 19,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xFF2FBF6D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
