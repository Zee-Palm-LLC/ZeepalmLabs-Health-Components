import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_chrome.dart';

class ConditionsChip extends StatelessWidget {
  const ConditionsChip({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return GlassPill(
      padding: const EdgeInsets.fromLTRB(11, 7, 13, 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.nightlight_round, size: 13, color: Spectrum.sky),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '13°  Clear',
                style: Typo.text(
                  11.5,
                  weight: 600,
                  color: Tone.primary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDate(now),
                style: Typo.text(
                  9.5,
                  weight: 500,
                  color: Tone.faint,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
