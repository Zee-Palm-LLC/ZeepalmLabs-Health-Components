import 'package:flutter/material.dart';
import 'package:medicify/components/mascot_bubble.dart';
import 'package:medicify/components/onboarding_scaffold.dart';
import 'package:medicify/components/option_tile.dart';
import 'package:medicify/components/staggered_item.dart';
import 'package:medicify/screens/onboarding/onboarding_data.dart';
import 'package:medicify/screens/onboarding/onboarding_flow.dart';
import 'package:medicify/theme/app_colors.dart';

class LanguageStep extends StatelessWidget {
  const LanguageStep({
    super.key,
    required this.step,
    required this.data,
    required this.onChanged,
    required this.onContinue,
    required this.onBack,
  });

  final int step;
  final OnboardingData data;
  final VoidCallback onChanged;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: step,
      totalSteps: OnboardingFlow.totalSteps,
      eyebrow: 'Personalize',
      title: 'What language feels\nbest for you?',
      subtitle: 'You can change this anytime in Settings.',
      onBack: onBack,
      onContinue: onContinue,
      canContinue: data.language != null,
      continueHint: 'Pick a language to continue',
      footer: const MascotBubble(
        message: 'first things first — let’s make this feel like home.',
      ),
      child: _LanguageOptions(data: data, onChanged: onChanged),
    );
  }
}

class _LanguageOptions extends StatelessWidget {
  const _LanguageOptions({required this.data, required this.onChanged});

  final OnboardingData data;
  final VoidCallback onChanged;

  static const _options = [
    ('🇬🇧', 'English', 'United Kingdom · Default'),
    ('🇪🇸', 'Español', 'Spanish · España'),
    ('🇩🇪', 'Deutsch', 'German · Deutschland'),
    ('🇫🇷', 'Français', 'French · France'),
  ];

  @override
  Widget build(BuildContext context) {
    final enter = OnboardingScaffold.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _options.length; i++)
          () {
            final (flag, label, subtitle) = _options[i];
            final tile = OptionTile(
              label: label,
              subtitle: subtitle,
              selected: data.language == label,
              leading: Text(flag, style: const TextStyle(fontSize: 22)),
              leadingBg: AppColors.bgWarm,
              onTap: () {
                data.language = label;
                onChanged();
              },
            );
            if (enter == null) return tile;
            return StaggeredItem(index: i, animation: enter, child: tile);
          }(),
      ],
    );
  }
}
