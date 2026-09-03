import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:physio_motion/components/fade_slide_in.dart';
import 'package:physio_motion/theme/app_colors.dart';

class WelcomeHeadline extends StatelessWidget {
  const WelcomeHeadline({super.key, this.animation});

  /// Parent 0→1 entrance animation for staggered lines.
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final headline = GoogleFonts.spaceGrotesk(
      fontSize: 34,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      height: 0.92,
      letterSpacing: -2,
    );

    final lines = <(String, Color)>[
      ('MOVE', AppColors.textPrimary),
      ('BETTER.', AppColors.textPrimary),
      ('LIVE', AppColors.lime),
      ('STRONGER.', AppColors.lime),
    ];

    Widget line(String text, Color color) => Text(
          text,
          style: headline.copyWith(color: color),
        );

    final body = Text(
      'Personalized recovery\nplans. Real progress.\nStronger you.',
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      ),
    );

    if (animation == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines) line(l.$1, l.$2),
          const SizedBox(height: 20),
          body,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++)
          FadeSlideIn(
            animation: animation!,
            begin: 0.12 + (i * 0.08),
            end: 0.38 + (i * 0.08),
            offset: const Offset(-16, 22),
            child: line(lines[i].$1, lines[i].$2),
          ),
        const SizedBox(height: 20),
        FadeSlideIn(
          animation: animation!,
          begin: 0.42,
          end: 0.62,
          offset: const Offset(0, 14),
          child: body,
        ),
      ],
    );
  }
}
