import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/motion.dart';
import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';

class VolumeChart extends StatelessWidget {
  const VolumeChart({super.key, required this.values, this.height = 96});

  final List<double> values;
  final double height;

  static const List<String> months = <String>[
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];

  @override
  Widget build(BuildContext context) {
    final peak = math.max(1.0, values.reduce(math.max));
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(values.length, (i) {
          final fraction = values[i] / peak;
          final isPeak = values[i] == peak;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AnimatedContainer(
                    duration: Motion.slow,
                    curve: Motion.enter,
                    height: math.max(3, (height - 22) * fraction),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isPeak
                            ? const <Color>[Spectrum.blue, Spectrum.amber]
                            : <Color>[
                                Spectrum.deep.withValues(alpha: 0.75),
                                Spectrum.cyan.withValues(alpha: 0.95),
                              ],
                      ),
                      boxShadow: isPeak
                          ? <BoxShadow>[
                              BoxShadow(
                                color: Spectrum.amber.withValues(alpha: 0.3),
                                blurRadius: 14,
                                spreadRadius: -3,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    months[i % months.length],
                    style: Typo.text(
                      9,
                      weight: 500,
                      color: isPeak ? Tone.secondary : Tone.faint,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
