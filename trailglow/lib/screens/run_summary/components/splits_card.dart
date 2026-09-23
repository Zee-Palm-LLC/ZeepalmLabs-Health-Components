import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/motion.dart';
import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/run_stats.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/section_card.dart';

class SplitsCard extends StatefulWidget {
  const SplitsCard({super.key, required this.stats});

  final RunStats stats;

  @override
  State<SplitsCard> createState() => _SplitsCardState();
}

class _SplitsCardState extends State<SplitsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 320), () {
      if (mounted) _grow.forward();
    });
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splits = widget.stats.splits;
    final fastest = widget.stats.fastestPace.toDouble();
    final slowest = widget.stats.slowestPace.toDouble();
    final span = math.max(1.0, slowest - fastest);

    return SectionCard(
      title: 'Splits',
      trailing: Text(
        'FASTEST ${formatPace(fastest)}',
        style: Typo.label(8.5, color: Spectrum.amber, letterSpacing: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 24,
                child: Text('KM', style: Typo.label(8, letterSpacing: 1.2)),
              ),
              SizedBox(
                width: 44,
                child: Text('PACE', style: Typo.label(8, letterSpacing: 1.2)),
              ),
              const Spacer(),
              Text('VS AVG', style: Typo.label(8, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < splits.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _SplitRow(
                split: splits[i],
                fraction:
                    0.22 + 0.78 * (slowest - splits[i].paceSeconds) / span,
                delta: splits[i].paceSeconds - widget.stats.avgPaceSeconds,
                isFastest: splits[i].paceSeconds == widget.stats.fastestPace,
                animation: CurvedAnimation(
                  parent: _grow,
                  curve: Interval(
                    (i / math.max(1, splits.length) * 0.55).clamp(0.0, 1.0),
                    ((i / math.max(1, splits.length)) * 0.55 + 0.45).clamp(
                      0.0,
                      1.0,
                    ),
                    curve: Motion.enter,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.split,
    required this.fraction,
    required this.delta,
    required this.isFastest,
    required this.animation,
  });

  final RunSplit split;
  final double fraction;
  final int delta;
  final bool isFastest;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final faster = delta <= 0;
    final deltaColor = faster ? Spectrum.teal : Tone.muted;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 24,
          child: Text(
            '${split.kilometre}',
            style: Typo.text(
              11.5,
              weight: 600,
              color: Tone.secondary,
              height: 1.0,
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            formatPace(split.paceSeconds),
            style: Typo.metric(
              15,
              weight: 600,
              letterSpacing: -0.2,
              color: isFastest ? Spectrum.amber : Tone.bright,
            ),
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: <Widget>[
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0x22101827),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    height: 6,
                    width: math.max(
                      4,
                      constraints.maxWidth * fraction * animation.value,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: isFastest
                            ? const <Color>[Spectrum.blue, Spectrum.amber]
                            : const <Color>[Spectrum.deep, Spectrum.cyan],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 46,
          child: Text(
            '${faster ? '-' : '+'}${formatDuration(delta.abs())}',
            textAlign: TextAlign.right,
            style: Typo.text(11, weight: 600, color: deltaColor, height: 1.0),
          ),
        ),
      ],
    );
  }
}
