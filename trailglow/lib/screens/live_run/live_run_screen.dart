import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/motion.dart';
import '../../app/theme/palette.dart';
import '../../app/theme/typography.dart';
import '../../controllers/live_run_controller.dart';
import '../../controllers/pre_run_controller.dart';
import '../../services/map_support.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/measure_size.dart';
import '../../widgets/staged.dart';
import 'components/live_controls.dart';
import 'components/live_hud.dart';
import 'components/runner_puck.dart';

class LiveRunScreen extends StatefulWidget {
  const LiveRunScreen({super.key});

  @override
  State<LiveRunScreen> createState() => _LiveRunScreenState();
}

class _LiveRunScreenState extends State<LiveRunScreen>
    with SingleTickerProviderStateMixin {
  final LiveRunController controller = Get.find<LiveRunController>();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  );
  Worker? _finishWatcher;

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    _finishWatcher = ever<bool>(controller.finished, (done) {
      if (done && mounted) _openSummary();
    });
  }

  @override
  void dispose() {
    _finishWatcher?.dispose();
    _entrance.dispose();
    super.dispose();
  }

  double _puckAnchor(double height) {
    if (!MapSupport.usesMapbox || MapSupport.mapboxFailed.value) return -0.16;
    final inset = controller.map.followInset;
    if (inset <= 0) return -0.16;
    return -(inset / height).clamp(0.0, 0.62);
  }

  void _openSummary() {
    Get.offNamed<void>(
      Routes.summary,
      arguments: SummaryArgs(
        route: controller.route,
        progress: controller.progress.value,
        elapsedSeconds: controller.elapsed.value,
        paceTarget: controller.targetPaceSeconds,
      ),
    );
  }

  void _discard() {
    controller.finish();
    _finishWatcher?.dispose();
    _finishWatcher = null;
    Get.back<void>();
    Get.find<PreRunController>().pushScene();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final compact = media.size.height < 780;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _discard();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment(0, _puckAnchor(media.size.height)),
              child: Obx(() => RunnerPuck(active: controller.running.value)),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: Staged(
                      animation: _entrance,
                      index: 0,
                      total: 4,
                      shift: const Offset(0, -18),
                      child: Row(
                        children: <Widget>[
                          IconPill(
                            icon: Icons.close_rounded,
                            onTap: _discard,
                            size: 38,
                            color: Tone.secondary,
                          ),
                          const Spacer(),
                          const _LiveBadge(),
                          const Spacer(),
                          const SizedBox(width: 38),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  MeasureSize(
                    onChange: (size) {
                      controller.map.setOrnamentInset(size.height + 8);
                      controller.map.setFollowInset(size.height + 30);
                      if (mounted) setState(() {});
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Obx(
                          () => AnimatedOpacity(
                            duration: Motion.quick,
                            opacity: controller.running.value ? 0.0 : 1.0,
                            child: const _PausedChip(),
                          ),
                        ),
                        SizedBox(height: compact ? 10 : 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Staged(
                            animation: _entrance,
                            index: 1,
                            total: 4,
                            shift: const Offset(0, 34),
                            child: LiveHud(compact: compact),
                          ),
                        ),
                        SizedBox(height: compact ? 14 : 20),
                        Staged(
                          animation: _entrance,
                          index: 2,
                          total: 4,
                          shift: const Offset(0, 26),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Obx(
                              () => LiveControls(
                                running: controller.running.value,
                                onToggle: controller.togglePause,
                                onFinish: controller.finish,
                                onMusic: _openMusic,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const HoldHint(),
                      ],
                    ),
                  ),
                  SizedBox(height: 14 + media.padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMusic() {
    Get.snackbar(
      'Night Tempo',
      'Playlist controls are mocked in this prototype.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xE60B0F18),
      colorText: const Color(0xFFDCE6F7),
      margin: const EdgeInsets.all(16),
      borderRadius: 18,
      duration: const Duration(seconds: 2),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveRunController>();
    return GlassPill(
      padding: const EdgeInsets.fromLTRB(14, 9, 16, 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Obx(() => _LiveDot(active: controller.running.value)),
          const SizedBox(width: 9),
          Text(
            'LIVE RUN',
            style: Typo.label(9.5, color: Tone.secondary, letterSpacing: 1.8),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 14, color: Night.hairline),
          const SizedBox(width: 12),
          Obx(
            () => Text(
              formatDuration(controller.elapsed.value),
              style: Typo.metric(17, weight: 600, letterSpacing: -0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.active});

  final bool active;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _blink.repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blink,
      builder: (context, _) {
        final t = widget.active ? 0.35 + _blink.value * 0.65 : 0.25;
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (widget.active ? Spectrum.teal : Tone.muted).withValues(
              alpha: t,
            ),
            boxShadow: widget.active
                ? <BoxShadow>[
                    BoxShadow(
                      color: Spectrum.teal.withValues(alpha: 0.5 * t),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}

class _PausedChip extends StatelessWidget {
  const _PausedChip();

  @override
  Widget build(BuildContext context) {
    return GlassPill(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Text(
        'PAUSED',
        style: Typo.label(10, color: Spectrum.amber, letterSpacing: 2.4),
      ),
    );
  }
}
