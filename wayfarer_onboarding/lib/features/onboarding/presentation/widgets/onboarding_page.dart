import 'package:flutter/widgets.dart';

import '../../../../core/layout/artboard.dart';
import '../../../../core/motion/page_value.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/onboarding_pages.dart';
import '../illustrations/doctors_map_illustration.dart';
import '../illustrations/appointments_illustration.dart';
import '../illustrations/top_clinics_illustration.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.content,
    required this.index,
    required this.controller,
    required this.isActive,
  });

  final OnboardingPageContent content;
  final int index;
  final PageController controller;
  final bool isActive;

  static const double _illustrationParallax = 0.22;
  static const double _copyParallax = 0.45;

  @override
  Widget build(BuildContext context) {
    final illustration = ExcludeSemantics(
      child: RepaintBoundary(
        child: switch (content.illustration) {
          OnboardingIllustration.appointments => AppointmentsIllustration(active: isActive),
          OnboardingIllustration.doctorsWorldwide => DoctorsMapIllustration(active: isActive),
          OnboardingIllustration.topClinics => TopClinicsIllustration(active: isActive),
        },
      ),
    );

    final copy = Column(
      children: [
        Text(content.title, textAlign: TextAlign.center, style: AppTypography.headline),
        const SizedBox(height: 5),
        Text(content.subtitle, textAlign: TextAlign.center, style: AppTypography.body),
      ],
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = index - controller.pageValue;
        final distance = offset.abs().clamp(0.0, 1.0);
        final width = Artboard.size.width;

        return Stack(
          children: [
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(offset * width * _illustrationParallax, 0),
                child: illustration,
              ),
            ),
            Positioned(
              top: 516,
              left: 16,
              right: 16,
              child: Opacity(
                opacity: (1 - distance * 1.6).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(offset * width * _copyParallax, 0),
                  child: copy,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
