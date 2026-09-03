import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:physio_motion/theme/app_colors.dart';

class WelcomeLoginLink extends StatelessWidget {
  const WelcomeLoginLink({super.key, this.onTap});

  final VoidCallback? onTap;

  static const _purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Already have an account?',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Log in',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _purple,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 14,
                color: _purple,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
