import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../controllers/live_run_controller.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/metric_tile.dart';
import 'pace_sparkline.dart';

class LiveHud extends StatelessWidget {
  const LiveHud({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveRunController>();
    return GlassPanel(
      radius: 30,
      padding: EdgeInsets.fromLTRB(
        22,
        compact ? 16 : 20,
        22,
        compact ? 16 : 20,
      ),
      child: Obx(() {
        final pace = controller.paceSeconds.value;
        final progress = controller.progress.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('CURRENT PACE', style: Typo.label(9.5, color: Tone.muted)),
                const Spacer(),
                StatBadge(
                  icon: Icons.bolt_rounded,
                  text: _zoneFor(pace, controller.targetPaceSeconds),
                  color: _zoneColor(pace, controller.targetPaceSeconds),
                ),
              ],
            ),
            SizedBox(height: compact ? 2 : 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  formatPace(pace),
                  style: Typo.metric(
                    compact ? 62 : 72,
                    weight: 700,
                    letterSpacing: -3.2,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '/km',
                    style: Typo.text(
                      14,
                      weight: 600,
                      color: Tone.muted,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 2 : 6),
            PaceSparkline(
              progress: progress,
              targetPace: controller.targetPaceSeconds,
              height: compact ? 38 : 48,
            ),
            SizedBox(height: compact ? 12 : 16),
            const HairlineDivider(),
            SizedBox(height: compact ? 12 : 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: MetricTile(
                    label: 'Distance',
                    unit: 'km',
                    dense: compact,
                    value: Text(
                      formatDistance(controller.distanceKm.value),
                      style: Typo.statValue,
                    ),
                  ),
                ),
                Expanded(
                  child: MetricTile(
                    label: 'Duration',
                    dense: compact,
                    value: Text(
                      formatDuration(controller.elapsed.value),
                      style: Typo.statValue,
                    ),
                  ),
                ),
                Expanded(
                  child: MetricTile(
                    label: 'Heart rate',
                    unit: 'bpm',
                    dense: compact,
                    value: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        HeartBeat(bpm: controller.heartRate.value),
                        const SizedBox(width: 7),
                        Text(
                          '${controller.heartRate.value}',
                          style: Typo.statValue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 14 : 18),
            _ProgressBar(progress: progress, total: controller.totalKm),
          ],
        );
      }),
    );
  }

  static String _zoneFor(int pace, int target) {
    if (pace <= target - 14) return 'THRESHOLD';
    if (pace <= target + 12) return 'TEMPO';
    return 'AEROBIC';
  }

  static Color _zoneColor(int pace, int target) {
    if (pace <= target - 14) return Spectrum.amber;
    if (pace <= target + 12) return Spectrum.cyan;
    return Spectrum.teal;
  }
}

class HeartBeat extends StatefulWidget {
  const HeartBeat({super.key, required this.bpm, this.size = 14});

  final int bpm;
  final double size;

  @override
  State<HeartBeat> createState() => _HeartBeatState();
}

class _HeartBeatState extends State<HeartBeat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _beat.repeat();
  }

  @override
  void didUpdateWidget(HeartBeat oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ms = (60000 / math.max(40, widget.bpm)).round();
    if (_beat.duration?.inMilliseconds != ms) {
      _beat.duration = Duration(milliseconds: ms);
      _beat.repeat();
    }
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _beat,
      builder: (context, _) {
        final t = _beat.value;
        final pop = t < 0.18 ? t / 0.18 : math.max(0.0, 1 - (t - 0.18) / 0.5);
        return Transform.scale(
          scale: 1.0 + pop * 0.28,
          child: Icon(
            Icons.favorite_rounded,
            size: widget.size,
            color: Color.lerp(Spectrum.rose, Colors.white, pop * 0.4),
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.total});

  final double progress;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              children: <Widget>[
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0x33101827),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 5,
                  width: math.max(5, width * progress.clamp(0.0, 1.0)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: <Color>[
                        Spectrum.deep,
                        Spectrum.blue,
                        Spectrum.cyan,
                      ],
                      stops: <double>[0.0, 0.55, 1.0],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Spectrum.cyan.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 9),
        Row(
          children: <Widget>[
            Text(
              '${(progress * 100).round()}% COMPLETE',
              style: Typo.label(9, color: Tone.muted, letterSpacing: 1.3),
            ),
            const Spacer(),
            Text(
              '${formatDistance(total * (1 - progress))} km to go',
              style: Typo.text(
                10.5,
                weight: 500,
                color: Tone.faint,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
