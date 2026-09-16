enum OnboardingIllustration { appointments, doctorsWorldwide, topClinics }

class OnboardingPageContent {
  const OnboardingPageContent({
    required this.title,
    required this.subtitle,
    required this.illustration,
  });

  final String title;
  final String subtitle;
  final OnboardingIllustration illustration;
}

const onboardingPages = [
  OnboardingPageContent(
    title: 'Your Health,\nPerfectly Planned',
    subtitle: 'Effortlessly book and organize your\ndoctor visits. Start feeling better now!',
    illustration: OnboardingIllustration.appointments,
  ),
  OnboardingPageContent(
    title: 'Consult Doctors\nAnywhere',
    subtitle: 'Connect with trusted specialists around the\nworld and get care from home.',
    illustration: OnboardingIllustration.doctorsWorldwide,
  ),
  OnboardingPageContent(
    title: 'Stay Updated\nwith Top Clinics',
    subtitle: 'Find top-rated hospitals and specialists near you,\nall tailored to your health needs.',
    illustration: OnboardingIllustration.topClinics,
  ),
];
