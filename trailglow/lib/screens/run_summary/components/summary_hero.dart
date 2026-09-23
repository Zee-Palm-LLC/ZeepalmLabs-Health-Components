import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/run_model.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/count_up.dart';
import '../../../widgets/glass_panel.dart';

class SummaryHero extends StatelessWidget {
  const SummaryHero({super.key, required this.run});

  final RunModel run;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: <Color>[
                      Spectrum.teal.withValues(alpha: 0.22),
                      Spectrum.cyan.withValues(alpha: 0.10),
                    ],
                  ),
                  border: Border.all(
                    color: Spectrum.teal.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Spectrum.teal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'RUN COMPLETE',
                      style: Typo.label(
                        9,
                        color: Spectrum.teal,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${formatDate(run.startedAt)}  ·  ${formatTimeOfDay(run.startedAt)}',
                style: Typo.text(
                  10.5,
                  weight: 500,
                  color: Tone.faint,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              CountUp(
                value: run.stats.distanceKm,
                format: formatDistance,
                style: Typo.hero,
                duration: const Duration(milliseconds: 1100),
                delay: const Duration(milliseconds: 180),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'km',
                  style: Typo.text(
                    17,
                    weight: 600,
                    color: Tone.muted,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Icon(Icons.route_rounded, size: 14, color: Spectrum.sky),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${run.title}  ·  ${run.subtitle}',
                  style: Typo.text(
                    13,
                    weight: 500,
                    color: Tone.secondary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
