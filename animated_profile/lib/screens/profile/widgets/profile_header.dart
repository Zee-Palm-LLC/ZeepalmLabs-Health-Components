import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dr. Sarah Mitchell',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                ),
                child: const Icon(
                  Iconsax.verify,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 5; i++)
                const Icon(
                  Iconsax.star,
                  color: AppColors.starColor,
                  size: 17,
                ),
              const SizedBox(width: 8),
              const Text(
                '4.9',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                '(2.4k reviews)',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Cardiologist • MD, FACC',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.onlineDot.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.onlineDot,
                ),
                child: SizedBox(width: 7, height: 7),
              ),
              SizedBox(width: 7),
              Text(
                'AVAILABLE NOW',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
