import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'profile_actions.dart';
import 'profile_header.dart';
import 'profile_info_card.dart';
import 'profile_stats.dart';

class ProfileStagger {
  ProfileStagger({
    required this.header,
    required this.bio,
    required this.stats,
    required this.details,
    required this.actions,
  });

  final Animation<double> header;
  final Animation<double> bio;
  final Animation<double> stats;
  final Animation<double> details;
  final Animation<double> actions;
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.stagger,
    required this.isBooked,
    required this.onBook,
    required this.onCall,
  });

  final ProfileStagger stagger;
  final bool isBooked;
  final VoidCallback onBook;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Reveal(
            animation: stagger.header,
            child: const ProfileHeader(),
          ),
          const SizedBox(height: 16),
          _Reveal(
            animation: stagger.bio,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Board-certified cardiologist with over 12 years of experience. '
                'I help patients prevent and manage heart disease with a calm, '
                'patient-first approach.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13.5,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Reveal(
            animation: stagger.stats,
            child: const ProfileStats(),
          ),
          const SizedBox(height: 22),
          _Reveal(
            animation: stagger.details,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: 'DETAILS'),
                SizedBox(height: 12),
                ProfileInfoCard(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _Reveal(
            animation: stagger.actions,
            child: ProfileActions(
              isBooked: isBooked,
              onBook: onBook,
              onCall: onCall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: animation.value,
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - animation.value)),
        child: child,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
