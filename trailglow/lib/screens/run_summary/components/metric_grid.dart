import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/run_stats.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_panel.dart';

class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.stats});

  final RunStats stats;

  @override
  Widget build(BuildContext context) {
    final items = <_Item>[
      _Item(
        'Duration',
        formatDuration(stats.durationSeconds),
        null,
        Icons.timer_outlined,
        Spectrum.sky,
      ),
      _Item(
        'Avg pace',
        formatPace(stats.avgPaceSeconds),
        '/km',
        Icons.speed_rounded,
        Spectrum.cyan,
      ),
      _Item(
        'Avg heart rate',
        '${stats.heartRate}',
        'bpm',
        Icons.favorite_rounded,
        Spectrum.rose,
      ),
      _Item(
        'Calories',
        '${stats.calories}',
        'kcal',
        Icons.local_fire_department_rounded,
        Spectrum.ember,
      ),
      _Item(
        'Elevation',
        stats.elevationMeters.round().toString(),
        'm',
        Icons.terrain_rounded,
        Spectrum.teal,
      ),
      _Item(
        'Cadence',
        '${stats.cadence}',
        'spm',
        Icons.directions_run_rounded,
        Spectrum.amber,
      ),
    ];

    return GlassPanel(
      radius: 24,
      blur: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _row(items.sublist(0, 3)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: HairlineDivider(),
          ),
          _row(items.sublist(3, 6)),
        ],
      ),
    );
  }

  Widget _row(List<_Item> items) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0)
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 16),
                color: Night.hairlineSoft,
              ),
            Expanded(child: _Cell(item: items[i])),
          ],
        ],
      ),
    );
  }
}

class _Item {
  const _Item(this.label, this.value, this.unit, this.icon, this.color);

  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;
}

class _Cell extends StatelessWidget {
  const _Cell({required this.item});

  final _Item item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(item.icon, size: 14, color: item.color),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Flexible(
                child: Text(
                  item.value,
                  style: Typo.metric(23, weight: 600, letterSpacing: -0.6),
                  maxLines: 1,
                ),
              ),
              if (item.unit != null) ...<Widget>[
                const SizedBox(width: 3),
                Text(
                  item.unit!,
                  style: Typo.text(
                    10,
                    weight: 600,
                    color: Tone.muted,
                    height: 1.0,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 7),
          Text(
            item.label.toUpperCase(),
            style: Typo.label(8.5, letterSpacing: 1.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
