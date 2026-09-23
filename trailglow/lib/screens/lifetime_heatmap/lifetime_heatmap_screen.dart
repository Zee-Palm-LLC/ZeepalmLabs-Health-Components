import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/typography.dart';
import '../../controllers/lifetime_heatmap_controller.dart';
import '../../controllers/pre_run_controller.dart';
import '../../data/models/heatmap_data.dart';
import '../../data/models/run_stats.dart';
import '../../data/mock/heatmap.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/section_card.dart';
import '../../widgets/segmented_selector.dart';
import '../../widgets/measure_size.dart';
import '../../widgets/staged.dart';
import '../../widgets/trailglow_map.dart';
import 'components/heat_legend.dart';
import 'components/lifetime_stats_grid.dart';
import 'components/volume_chart.dart';

class LifetimeHeatmapScreen extends StatefulWidget {
  const LifetimeHeatmapScreen({super.key});

  @override
  State<LifetimeHeatmapScreen> createState() => _LifetimeHeatmapScreenState();
}

class _LifetimeHeatmapScreenState extends State<LifetimeHeatmapScreen>
    with SingleTickerProviderStateMixin {
  final LifetimeHeatmapController controller =
      Get.find<LifetimeHeatmapController>();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _goToRun() {
    Get.back<void>();
    if (Get.isRegistered<PreRunController>()) {
      Get.find<PreRunController>().pushScene();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToRun();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Staged(
                  animation: _entrance,
                  index: 0,
                  total: 5,
                  shift: const Offset(0, -16),
                  child: Row(
                    children: <Widget>[
                      IconPill(
                        icon: Icons.arrow_back_rounded,
                        onTap: _goToRun,
                        size: 38,
                        color: Tone.secondary,
                      ),
                      const Spacer(),
                      GlassPill(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        child: Text(
                          'LIFETIME HEATMAP',
                          style: Typo.label(
                            9.5,
                            color: Tone.secondary,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 38),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Staged(
                        animation: _entrance,
                        index: 1,
                        total: 5,
                        shift: const Offset(0, -12),
                        child: const HeatLegend(),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Staged(
                            animation: _entrance,
                            index: 2,
                            total: 5,
                            shift: const Offset(-16, 0),
                            child: Obx(
                              () =>
                                  _CoverageChip(range: controller.range.value),
                            ),
                          ),
                          Staged(
                            animation: _entrance,
                            index: 2,
                            total: 5,
                            shift: const Offset(16, 0),
                            child: const MapFallbackBadge(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              MeasureSize(
                onChange: (size) {
                  controller.setBottomInset(size.height + 20);
                  controller.map.setOrnamentInset(size.height + 8);
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: media.size.height * 0.46,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                    physics: const BouncingScrollPhysics(),
                    child: Staged(
                      animation: _entrance,
                      index: 3,
                      total: 5,
                      shift: const Offset(0, 38),
                      child: Obx(() {
                        final stats = controller.stats;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SegmentedSelector(
                              items: HeatmapRange.values
                                  .map((r) => r.label)
                                  .toList(growable: false),
                              index: controller.rangeIndex,
                              onChanged: controller.selectRange,
                              height: 42,
                              fontSize: 11,
                            ),
                            const SizedBox(height: 14),
                            LifetimeStatsGrid(stats: stats),
                            const SizedBox(height: 14),
                            SectionCard(
                              title: 'Monthly volume',
                              trailing: Text(
                                'KM',
                                style: Typo.label(8.5, letterSpacing: 1.4),
                              ),
                              child: VolumeChart(values: stats.monthly),
                            ),
                            const SizedBox(height: 14),
                            _Records(stats: stats),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Staged(
                animation: _entrance,
                index: 4,
                total: 5,
                shift: const Offset(0, 24),
                child: DockedNav(
                  index: 1,
                  onChanged: (i) {
                    if (i == 0) _goToRun();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverageChip extends StatelessWidget {
  const _CoverageChip({required this.range});

  final HeatmapRange range;

  @override
  Widget build(BuildContext context) {
    final runs = MockHeatmap.runCounts[range] ?? 0;
    return GlassPill(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.layers_rounded, size: 13, color: Spectrum.sky),
          const SizedBox(width: 8),
          Text(
            '$runs routes mapped',
            style: Typo.text(11, weight: 600, color: Tone.primary, height: 1.0),
          ),
        ],
      ),
    );
  }
}

class _Records extends StatelessWidget {
  const _Records({required this.stats});

  final LifetimeStats stats;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Personal bests',
      child: Row(
        children: <Widget>[
          Expanded(
            child: _Record(
              label: 'Longest run',
              value: formatDistance(stats.longestRunKm, digits: 1),
              unit: 'km',
              color: Spectrum.teal,
            ),
          ),
          Container(width: 1, height: 34, color: Night.hairlineSoft),
          Expanded(
            child: _Record(
              label: 'Best pace',
              value: formatPace(stats.bestPaceSeconds),
              unit: '/km',
              color: Spectrum.amber,
            ),
          ),
          Container(width: 1, height: 34, color: Night.hairlineSoft),
          Expanded(
            child: _Record(
              label: 'Avg per run',
              value: formatDistance(stats.distanceKm / stats.runs, digits: 1),
              unit: 'km',
              color: Spectrum.cyan,
            ),
          ),
        ],
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Flexible(
              child: Text(
                value,
                style: Typo.metric(
                  20,
                  weight: 600,
                  letterSpacing: -0.5,
                  color: color,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              unit,
              style: Typo.text(
                9.5,
                weight: 600,
                color: Tone.muted,
                height: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          label.toUpperCase(),
          style: Typo.label(8.5, letterSpacing: 1.2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
