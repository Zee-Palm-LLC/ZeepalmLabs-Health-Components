import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../controllers/pre_run_controller.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/count_up.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/glow_button.dart';
import '../../../widgets/metric_tile.dart';
import 'goal_picker.dart';
import 'route_strip.dart';

class PreRunPanel extends StatelessWidget {
  const PreRunPanel({super.key, required this.onStart, this.compact = false});

  final VoidCallback onStart;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PreRunController>();

    return GlassPanel(
      radius: 30,
      padding: EdgeInsets.fromLTRB(
        20,
        compact ? 16 : 20,
        20,
        compact ? 18 : 22,
      ),
      child: Obx(() {
        final plan = controller.plan;
        final route = plan.route;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Spectrum.teal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${plan.label.toUpperCase()}  ·  ${route.area.toUpperCase()}',
                    style: Typo.label(9.5, color: Tone.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${controller.routeIndex.value + 1} / ${controller.routeCount}',
                  style: Typo.label(9.5, color: Tone.faint, letterSpacing: 1.0),
                ),
              ],
            ),
            SizedBox(height: compact ? 10 : 13),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    route.name,
                    style: Typo.text(
                      21,
                      weight: 700,
                      color: Tone.bright,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                StatBadge(
                  icon: Icons.terrain_rounded,
                  text: '${route.elevationGain.round()} m',
                  color: Spectrum.teal,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              plan.note,
              style: Typo.text(
                12.5,
                weight: 400,
                color: Tone.muted,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: compact ? 14 : 18),
            _Metrics(
              distanceKm: route.distanceKm,
              seconds: plan.estimatedSeconds,
              pace: plan.targetPaceSeconds,
            ),
            SizedBox(height: compact ? 14 : 18),
            const RouteStrip(),
            SizedBox(height: compact ? 12 : 16),
            const GoalPicker(),
            SizedBox(height: compact ? 14 : 18),
            GlowButton(
              label: 'START RUN',
              height: compact ? 58 : 62,
              onTap: onStart,
            ),
          ],
        );
      }),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({
    required this.distanceKm,
    required this.seconds,
    required this.pace,
  });

  final double distanceKm;
  final int seconds;
  final int pace;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: MetricTile(
            label: 'Distance',
            unit: 'km',
            value: CountUp(
              value: distanceKm,
              format: (v) => formatDistance(v),
              style: Typo.statValue,
              duration: const Duration(milliseconds: 760),
            ),
          ),
        ),
        const _Rule(),
        Expanded(
          child: MetricTile(
            label: 'Est. time',
            unit: 'min',
            value: CountUp(
              value: seconds / 60,
              format: (v) => v.round().toString(),
              style: Typo.statValue,
              duration: const Duration(milliseconds: 760),
            ),
          ),
        ),
        const _Rule(),
        Expanded(
          child: MetricTile(
            label: 'Target pace',
            unit: '/km',
            value: Text(formatPace(pace), style: Typo.statValue),
          ),
        ),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 30,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0x00FFFFFF), Night.hairline, Color(0x00FFFFFF)],
        stops: <double>[0.0, 0.5, 1.0],
      ),
    ),
  );
}
