import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/typography.dart';
import '../../controllers/pre_run_controller.dart';
import '../../controllers/run_summary_controller.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/section_card.dart';
import '../../widgets/staged.dart';
import 'components/metric_grid.dart';
import 'components/pace_chart.dart';
import 'components/route_card.dart';
import 'components/splits_card.dart';
import 'components/summary_hero.dart';
import 'components/zones_card.dart';

class RunSummaryScreen extends StatefulWidget {
  const RunSummaryScreen({super.key});

  @override
  State<RunSummaryScreen> createState() => _RunSummaryScreenState();
}

class _RunSummaryScreenState extends State<RunSummaryScreen>
    with SingleTickerProviderStateMixin {
  final RunSummaryController controller = Get.find<RunSummaryController>();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
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

  void _close() {
    Get.back<void>();
    if (Get.isRegistered<PreRunController>()) {
      Get.find<PreRunController>().pushScene();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final run = controller.run;
    final heroGap = media.size.height * 0.30;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setHeroGap(media.size.height * 0.58, media.padding.top);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.fromLTRB(
                18,
                heroGap,
                18,
                28 + media.padding.bottom,
              ),
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                Staged(
                  animation: _entrance,
                  index: 0,
                  total: 7,
                  shift: const Offset(0, 34),
                  child: SummaryHero(run: run),
                ),
                const SizedBox(height: 14),
                Staged(
                  animation: _entrance,
                  index: 1,
                  total: 7,
                  child: MetricGrid(stats: run.stats),
                ),
                const SizedBox(height: 14),
                Staged(
                  animation: _entrance,
                  index: 2,
                  total: 7,
                  child: SectionCard(
                    title: 'Pace per kilometre',
                    trailing: Text(
                      'AVG ${_pace(run.stats.avgPaceSeconds)}',
                      style: Typo.label(
                        8.5,
                        color: Spectrum.cyan,
                        letterSpacing: 1.2,
                      ),
                    ),
                    child: PaceChart(
                      splits: run.stats.splits,
                      averagePace: run.stats.avgPaceSeconds,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Staged(
                  animation: _entrance,
                  index: 3,
                  total: 7,
                  child: SplitsCard(stats: run.stats),
                ),
                const SizedBox(height: 14),
                Staged(
                  animation: _entrance,
                  index: 4,
                  total: 7,
                  child: ZonesCard(
                    zones: controller.zones,
                    maxHeartRate: run.stats.maxHeartRate,
                  ),
                ),
                const SizedBox(height: 14),
                Staged(
                  animation: _entrance,
                  index: 5,
                  total: 7,
                  child: RouteCard(run: run, progress: controller.progress),
                ),
                const SizedBox(height: 20),
                Staged(
                  animation: _entrance,
                  index: 6,
                  total: 7,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: _SecondaryButton(
                          label: 'SHARE',
                          icon: Icons.ios_share_rounded,
                          onTap: _share,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: GlowButton(
                          label: 'DONE',
                          icon: Icons.check_rounded,
                          height: 58,
                          breathing: false,
                          onTap: _close,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(onClose: _close, onShare: _share),
            ),
          ],
        ),
      ),
    );
  }

  String _pace(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  void _share() {
    Get.snackbar(
      'Shared to your feed',
      'Export and sharing are mocked in this prototype.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xE60B0F18),
      colorText: const Color(0xFFDCE6F7),
      margin: const EdgeInsets.all(16),
      borderRadius: 18,
      duration: const Duration(seconds: 2),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.onShare});

  final VoidCallback onClose;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
        child: Row(
          children: <Widget>[
            IconPill(
              icon: Icons.arrow_back_rounded,
              onTap: onClose,
              size: 38,
              color: Tone.secondary,
            ),
            const Spacer(),
            GlassPill(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                'RUN SUMMARY',
                style: Typo.label(
                  9.5,
                  color: Tone.secondary,
                  letterSpacing: 1.8,
                ),
              ),
            ),
            const Spacer(),
            IconPill(
              icon: Icons.ios_share_rounded,
              onTap: onShare,
              size: 38,
              color: Tone.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0x800B0F18),
          borderRadius: BorderRadius.circular(29),
          border: Border.all(color: Night.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: Tone.secondary),
            const SizedBox(width: 10),
            Text(
              label,
              style: Typo.text(
                13,
                weight: 700,
                color: Tone.primary,
                letterSpacing: 1.8,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
