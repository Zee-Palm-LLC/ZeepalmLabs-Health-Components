import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/motion.dart';
import '../../controllers/pre_run_controller.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/measure_size.dart';
import '../../widgets/staged.dart';
import '../../widgets/trailglow_map.dart';
import 'components/conditions_chip.dart';
import 'components/last_run_card.dart';
import 'components/pre_run_panel.dart';

class PreRunScreen extends StatefulWidget {
  const PreRunScreen({super.key});

  @override
  State<PreRunScreen> createState() => _PreRunScreenState();
}

class _PreRunScreenState extends State<PreRunScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PreRunController>();
    final media = MediaQuery.of(context);
    final compact = media.size.height < 780;
    final roomy = media.size.width >= 392;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Staged(
                animation: _entrance,
                index: 0,
                total: 6,
                shift: const Offset(0, -16),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Wordmark(
                        tagline: roomy ? 'Real routes. Higher you.' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const ConditionsChip(),
                    const SizedBox(width: 10),
                    IconPill(
                      icon: Icons.tune_rounded,
                      onTap: () => _showSettings(context),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Staged(
                      animation: _entrance,
                      index: 1,
                      total: 6,
                      shift: const Offset(-18, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: LastRunCard(
                          onTap: () => Get.toNamed(Routes.summary),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Staged(
                      animation: _entrance,
                      index: 2,
                      total: 6,
                      shift: const Offset(18, 0),
                      child: const MapFallbackBadge(),
                    ),
                    const SizedBox(height: 10),
                    Staged(
                      animation: _entrance,
                      index: 3,
                      total: 6,
                      shift: const Offset(18, 0),
                      child: MapControls(
                        onRecenter: controller.recenterOnRoute,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MeasureSize(
              onChange: (size) {
                controller.setBottomInset(size.height + 24);
                controller.map.setOrnamentInset(size.height + 8);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: media.size.height * 0.66,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                      child: Staged(
                        animation: _entrance,
                        index: 4,
                        total: 6,
                        shift: const Offset(0, 40),
                        child: PreRunPanel(
                          compact: compact,
                          onStart: () => Get.toNamed(Routes.liveRun),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Staged(
                    animation: _entrance,
                    index: 5,
                    total: 6,
                    shift: const Offset(0, 26),
                    child: DockedNav(
                      index: 0,
                      onChanged: (i) {
                        if (i == 1) Get.toNamed(Routes.lifetime);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Get.snackbar(
      'Trailglow',
      'Preferences live in the full app. This prototype keeps the run front and centre.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xE60B0F18),
      colorText: const Color(0xFFDCE6F7),
      margin: const EdgeInsets.all(16),
      borderRadius: 18,
      duration: Motion.slow * 4,
    );
  }
}
