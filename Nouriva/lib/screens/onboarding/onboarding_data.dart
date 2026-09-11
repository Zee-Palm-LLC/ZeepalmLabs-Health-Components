class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.body,
    required this.video,
    required this.layout,
  });

  final String title;
  final String body;
  final String video;
  final OnboardingLayout layout;
}

enum OnboardingLayout { bottomStart, topCenter }

const kOnboardingPages = <OnboardingPage>[
  OnboardingPage(
    title: 'Good Food,\nGood You',
    body:
        'Nutritious ingredients, thoughtfully\nchosen to fuel your body and mind.',
    video: 'assets/images/onboarding_one.mp4',
    layout: OnboardingLayout.bottomStart,
  ),
  OnboardingPage(
    title: 'Healthy choices,\nmade simple',
    body:
        'Personalized recommendations,\nmeal plans and insights for\na better you.',
    video: 'assets/images/onboarding_two.mp4',
    layout: OnboardingLayout.topCenter,
  ),
  OnboardingPage(
    title: 'Nourish\nEvery Day',
    body:
        'Build gentle habits, track what matters,\nand feel lighter with every meal.',
    video: 'assets/images/onboarding_three.mp4',
    layout: OnboardingLayout.topCenter,
  ),
];
