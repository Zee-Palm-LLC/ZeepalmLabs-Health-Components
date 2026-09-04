import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:medicify/components/onboarding_scaffold.dart';
import 'package:medicify/components/option_tile.dart';
import 'package:medicify/components/staggered_item.dart';
import 'package:medicify/screens/onboarding/onboarding_data.dart';
import 'package:medicify/screens/onboarding/onboarding_flow.dart';
import 'package:medicify/theme/app_colors.dart';

class DiscoveryStep extends StatelessWidget {
  const DiscoveryStep({
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
      eyebrow: 'Discovery',
      title: 'How did you find\nMedicify?',
      subtitle:
          'Just curious — your answer helps us understand how people discover Medicify.',
      onBack: onBack,
      onContinue: onContinue,
      canContinue: data.discovery != null,
      continueHint: 'Tell us how you found Medicify',
      child: _DiscoveryOptions(data: data, onChanged: onChanged),
    );
  }
}

class _DiscoveryOptions extends StatelessWidget {
  const _DiscoveryOptions({required this.data, required this.onChanged});

  final OnboardingData data;
  final VoidCallback onChanged;

  static const _options = [
    (Iconsax.video_play, 'TikTok', 'Short videos & trends', Color(0xFFFFE8F0)),
    (Iconsax.instagram, 'Instagram', 'Stories & creators', Color(0xFFFFF0E8)),
    (Iconsax.youtube, 'YouTube', 'Tutorials & reviews', Color(0xFFFFECEC)),
    (Iconsax.apple, 'App Store', 'Featured or search', Color(0xFFEEF2FF)),
    (Iconsax.search_normal_1, 'Google', 'Search results', Color(0xFFE8F8F0)),
    (Iconsax.people, 'Friend or family', 'Personal recommendation', Color(0xFFF3E8FF)),
    (Iconsax.hospital, 'Healthcare provider', 'Doctor or clinic', Color(0xFFE8F4FF)),
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
            final selected = data.discovery == label;
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
                data.discovery = label;
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
