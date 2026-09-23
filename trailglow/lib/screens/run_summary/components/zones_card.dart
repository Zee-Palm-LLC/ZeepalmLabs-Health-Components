import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../data/mock/runs.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/section_card.dart';

class ZonesCard extends StatelessWidget {
  const ZonesCard({super.key, required this.zones, required this.maxHeartRate});

  final List<HeartRateZone> zones;
  final int maxHeartRate;

  static const List<Color> _colors = <Color>[
    Spectrum.rose,
    Spectrum.ember,
    Spectrum.amber,
    Spectrum.cyan,
    Spectrum.sky,
  ];

  @override
  Widget build(BuildContext context) {
    final peak = zones.map((z) => z.share).reduce(math.max);
    return SectionCard(
      title: 'Heart rate zones',
      trailing: Text(
        'MAX $maxHeartRate BPM',
        style: Typo.label(8.5, color: Spectrum.rose, letterSpacing: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < zones.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == zones.length - 1 ? 0 : 11),
              child: _ZoneRow(
                zone: zones[i],
                color: _colors[i % _colors.length],
                fraction: zones[i].share / peak,
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({
    required this.zone,
    required this.color,
    required this.fraction,
  });

  final HeartRateZone zone;
  final Color color;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 24,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: Text(
            zone.tag,
            style: Typo.text(8.5, weight: 700, color: color, height: 1.0),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 62,
          child: Text(
            zone.name,
            style: Typo.text(
              11,
              weight: 500,
              color: Tone.secondary,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: <Widget>[
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0x22101827),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  height: 6,
                  width: math.max(4, constraints.maxWidth * fraction),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: <Color>[color.withValues(alpha: 0.35), color],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text(
            '${(zone.share * 100).round()}%',
            textAlign: TextAlign.right,
            style: Typo.text(11, weight: 600, color: Tone.primary, height: 1.0),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            formatDuration(zone.seconds),
            textAlign: TextAlign.right,
            style: Typo.text(10.5, weight: 500, color: Tone.faint, height: 1.0),
          ),
        ),
      ],
    );
  }
}
