import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/run_model.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_panel.dart';
import 'route_thumbnail.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({super.key, required this.run, required this.progress});

  final RunModel run;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final path = run.route.sliceTo(progress);
    return GlassPanel(
      radius: 24,
      blur: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          RouteThumbnail(path: path, size: const Size(92, 80)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  run.route.name,
                  style: Typo.text(
                    15,
                    weight: 600,
                    color: Tone.bright,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  run.route.area,
                  style: Typo.text(
                    11,
                    weight: 400,
                    color: Tone.faint,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    _Mini(
                      value: formatDistance(run.stats.distanceKm),
                      unit: 'km',
                    ),
                    const SizedBox(width: 16),
                    _Mini(value: formatDuration(run.stats.durationSeconds)),
                    const SizedBox(width: 16),
                    _Mini(
                      value: formatPace(run.stats.avgPaceSeconds),
                      unit: '/km',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.value, this.unit});

  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(value, style: Typo.metric(16, weight: 600, letterSpacing: -0.3)),
        if (unit != null) ...<Widget>[
          const SizedBox(width: 2),
          Text(
            unit!,
            style: Typo.text(9.5, weight: 600, color: Tone.muted, height: 1.0),
          ),
        ],
      ],
    );
  }
}
