import 'package:flutter/material.dart';

import '../app/theme/palette.dart';
import '../app/theme/typography.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.accent = Tone.bright,
    this.valueStyle,
    this.align = CrossAxisAlignment.start,
    this.dense = false,
  });

  final String label;
  final Widget value;
  final String? unit;
  final Color accent;
  final TextStyle? valueStyle;
  final CrossAxisAlignment align;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Flexible(child: value),
            if (unit != null) ...<Widget>[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit!, style: Typo.statUnit),
              ),
            ],
          ],
        ),
        SizedBox(height: dense ? 5 : 7),
        Text(label.toUpperCase(), style: Typo.statLabel),
      ],
    );
  }
}

class StatBadge extends StatelessWidget {
  const StatBadge({
    super.key,
    required this.icon,
    required this.text,
    this.color = Spectrum.cyan,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Typo.text(11.5, weight: 600, color: color, height: 1.0),
          ),
        ],
      ),
    );
  }
}
