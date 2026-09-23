import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../data/mock/runs.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/press_scale.dart';

class LastRunCard extends StatelessWidget {
  const LastRunCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final run = MockRuns.completedRun;
    return PressScale(
      onTap: onTap,
      scale: 0.97,
      child: GlassPanel(
        radius: 18,
        blur: 16,
        padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('LAST RUN', style: Typo.label(8.5, color: Tone.faint)),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      formatDistance(run.stats.distanceKm),
                      style: Typo.metric(20, weight: 600, letterSpacing: -0.6),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'km',
                      style: Typo.text(
                        10.5,
                        weight: 600,
                        color: Tone.muted,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Tone.faint,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      formatDuration(run.stats.durationSeconds),
                      style: Typo.text(
                        12,
                        weight: 600,
                        color: Tone.secondary,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 14),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Tone.muted,
            ),
          ],
        ),
      ),
    );
  }
}
