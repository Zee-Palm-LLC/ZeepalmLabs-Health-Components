import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../theme/app_colors.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoTile(
                icon: Iconsax.hospital,
                label: 'Hospital',
                value: 'City Heart Institute',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: Iconsax.location,
                label: 'Location',
                value: 'Downtown, New York',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoTile(
                icon: Iconsax.language_circle,
                label: 'Languages',
                value: 'English, Spanish',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: Iconsax.wallet_money,
                label: 'Consultation fee',
                value: '\$120 / visit',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
