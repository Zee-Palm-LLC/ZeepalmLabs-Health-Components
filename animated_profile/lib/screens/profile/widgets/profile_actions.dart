import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../theme/app_colors.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({
    super.key,
    required this.isBooked,
    required this.onBook,
    required this.onCall,
  });

  final bool isBooked;
  final VoidCallback onBook;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Iconsax.call, size: 17),
              label: const Text(
                'Call',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                side: const BorderSide(
                  color: AppColors.primaryLight,
                  width: 1.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onBook,
              icon: Icon(
                isBooked ? Iconsax.tick_circle : Iconsax.calendar_1,
                size: 17,
              ),
              label: Text(
                isBooked ? 'Booked' : 'Book Appointment',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    isBooked ? AppColors.primaryDark : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
