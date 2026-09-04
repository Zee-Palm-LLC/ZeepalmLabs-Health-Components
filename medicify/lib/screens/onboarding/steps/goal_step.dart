import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:medicify/components/onboarding_scaffold.dart';
import 'package:medicify/components/option_tile.dart';
import 'package:medicify/components/staggered_item.dart';
import 'package:medicify/screens/onboarding/onboarding_data.dart';
import 'package:medicify/screens/onboarding/onboarding_flow.dart';
import 'package:medicify/theme/app_colors.dart';

class GoalStep extends StatelessWidget {
  const GoalStep({
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
      eyebrow: 'Your goals',
      title: 'What would you like\nto achieve?',
      subtitle: 'Choose what matters most to you right now.',
      onBack: onBack,
      onContinue: onContinue,
      canContinue: data.goal != null,
      continueHint: 'Choose a goal to continue',
      child: _GoalOptions(data: data, onChanged: onChanged),
    );
  }
}

class _GoalOptions extends StatelessWidget {
  const _GoalOptions({required this.data, required this.onChanged});

  final OnboardingData data;
  final VoidCallback onChanged;

  static const _options = [
    (Iconsax.weight, 'Lose weight', 'Steady, sustainable progress', Color(0xFFE8F8F0)),
    (Iconsax.judge, 'Maintain my weight', 'Stay consistent & balanced', Color(0xFFEEF2FF)),
    (Iconsax.calendar_1, 'Build healthier habits', 'Daily routines that stick', Color(0xFFFFF0E8)),
    (Iconsax.magic_star, 'Feel better day to day', 'Energy, mood & clarity', Color(0xFFF3E8FF)),
    (Iconsax.heart, 'Improve my overall health', 'Long-term wellbeing', Color(0xFFFFECEC)),
  ];

  @override
  Widget build(BuildContext context) {
    final enter = OnboardingScaffold.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _options.length; i++)
          () {
            final (icon, label, subtitle, tint) = _options[i];
            final selected = data.goal == label;
            final tile = OptionTile(
              label: label,
              subtitle: subtitle,
              selected: selected,
              leadingBg: tint,
              leading: Icon(
                icon,
                size: 22,
                color: selected ? AppColors.purpleDeep : AppColors.textPrimary,
              ),
              onTap: () {
                data.goal = label;
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
