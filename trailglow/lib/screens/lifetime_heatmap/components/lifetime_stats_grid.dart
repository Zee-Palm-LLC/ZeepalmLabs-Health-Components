import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/run_stats.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/count_up.dart';
import '../../../widgets/glass_panel.dart';

class LifetimeStatsGrid extends StatelessWidget {
  const LifetimeStatsGrid({super.key, required this.stats});

  final LifetimeStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 24,
      blur: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _Cell(
                    icon: Icons.straighten_rounded,
                    color: Spectrum.cyan,
                    label: 'Total distance',
                    unit: 'km',
                    value: CountUp(
                      value: stats.distanceKm,
                      format: (v) => formatThousands(v),
                      style: Typo.metric(26, weight: 600, letterSpacing: -0.8),
                    ),
                  ),
                ),
                const _Rule(),
                Expanded(
                  child: _Cell(
                    icon: Icons.directions_run_rounded,
                    color: Spectrum.teal,
                    label: 'Total runs',
                    value: CountUp(
                      value: stats.runs.toDouble(),
                      format: (v) => v.round().toString(),
                      style: Typo.metric(26, weight: 600, letterSpacing: -0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: HairlineDivider(),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _Cell(
                    icon: Icons.schedule_rounded,
                    color: Spectrum.sky,
                    label: 'Time running',
                    unit: 'h',
                    value: CountUp(
                      value: stats.hours,
                      format: (v) => v.round().toString(),
                      style: Typo.metric(26, weight: 600, letterSpacing: -0.8),
                    ),
                  ),
                ),
                const _Rule(),
                Expanded(
                  child: _Cell(
                    icon: Icons.terrain_rounded,
                    color: Spectrum.amber,
                    label: 'Elevation',
                    unit: 'm',
                    value: CountUp(
                      value: stats.elevationMeters.toDouble(),
                      format: (v) => formatThousands(v),
                      style: Typo.metric(26, weight: 600, letterSpacing: -0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.unit,
  });

  final IconData icon;
  final Color color;
  final String label;
  final Widget value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Flexible(child: value),
              if (unit != null) ...<Widget>[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: Typo.text(
                    11,
                    weight: 600,
                    color: Tone.muted,
                    height: 1.0,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: Typo.label(9, letterSpacing: 1.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    margin: const EdgeInsets.symmetric(vertical: 16),
    color: Night.hairlineSoft,
  );
}
