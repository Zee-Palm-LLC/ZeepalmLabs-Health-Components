import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../widgets/app_chrome.dart';

class HeatLegend extends StatelessWidget {
  const HeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPill(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'LESS',
            style: Typo.label(8, color: Tone.faint, letterSpacing: 1.2),
          ),
          const SizedBox(width: 9),
          Container(
            width: 86,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: const LinearGradient(
                colors: Spectrum.heat,
                stops: Spectrum.heatStops,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            'MORE',
            style: Typo.label(8, color: Tone.faint, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}
