import 'package:aira_health/screens/dashboard/dashboard_screen.dart';
import 'package:aira_health/theme/app_theme.dart';
import 'package:aira_health/widgets/chrome.dart';
import 'package:aira_health/widgets/fade_reveal.dart';
import 'package:aira_health/widgets/slide_to_start.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _assistants = [
    'assets/aira.png',
    'assets/avatar_1.png',
    'assets/avatar_2.png',
    'assets/avatar_3.png',
    'assets/avatar_4.png',
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              FadeReveal(
                child: Text(
                  'Choose Your AI Health Assistant.',
                  style: AiraType.body(size: 13),
                ),
              ),
              const Spacer(),
              FadeReveal(
                delay: const Duration(milliseconds: 80),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: const Cubic(0.16, 1, 0.3, 1),
                  child: ClipRRect(
                    key: ValueKey(_selected),
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      _assistants[_selected],
                      height: 280,
                      width: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              FadeReveal(
                delay: const Duration(milliseconds: 140),
                child: Text('Meet Aira Health', style: AiraType.display()),
              ),
              const SizedBox(height: 6),
              FadeReveal(
                delay: const Duration(milliseconds: 180),
                child: Text(
                  'AI-Powered Health Support',
                  style: AiraType.body(),
                ),
              ),
              const SizedBox(height: 22),
              FadeReveal(
                delay: const Duration(milliseconds: 230),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_assistants.length, (i) {
                    final selected = i == _selected;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AiraColors.ink
                                  : Colors.transparent,
                              width: 1.4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: selected ? 18 : 16,
                            backgroundImage: AssetImage(_assistants[i]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              FadeReveal(
                delay: const Duration(milliseconds: 300),
                child: SlideToStart(
                  label: 'Slide to Start',
                  onComplete: () {
                    Navigator.of(context).pushReplacement(
                      SoftFadeRoute(page: const DashboardScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
