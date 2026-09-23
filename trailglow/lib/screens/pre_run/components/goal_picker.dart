import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/motion.dart';
import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../controllers/pre_run_controller.dart';
import '../../../widgets/press_scale.dart';
import '../../../widgets/segmented_selector.dart';

class GoalPicker extends StatelessWidget {
  const GoalPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PreRunController>();
    return Obx(() {
      final mode = controller.goal.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SegmentedSelector(
            items: const <String>['FREE RUN', 'DISTANCE', 'TIME'],
            index: GoalMode.values.indexOf(mode),
            onChanged: (i) => controller.setGoal(GoalMode.values[i]),
            height: 38,
          ),
          AnimatedSize(
            duration: Motion.quick,
            curve: Motion.enter,
            alignment: Alignment.topCenter,
            child: mode == GoalMode.free
                ? const SizedBox(width: double.infinity, height: 0)
                : Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _Stepper(mode: mode, controller: controller),
                  ),
          ),
        ],
      );
    });
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.mode, required this.controller});

  final GoalMode mode;
  final PreRunController controller;

  @override
  Widget build(BuildContext context) {
    final distance = mode == GoalMode.distance;
    final value = distance
        ? controller.targetDistance.value.toStringAsFixed(1)
        : '${controller.targetMinutes.value}';
    final unit = distance ? 'km' : 'min';

    return Row(
      children: <Widget>[
        _Round(
          icon: Icons.remove_rounded,
          onTap: () => distance
              ? controller.nudgeDistance(-0.5)
              : controller.nudgeMinutes(-5),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                value,
                style: Typo.metric(34, weight: 600, letterSpacing: -1.2),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: Typo.text(
                    13,
                    weight: 600,
                    color: Tone.muted,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        _Round(
          icon: Icons.add_rounded,
          onTap: () => distance
              ? controller.nudgeDistance(0.5)
              : controller.nudgeMinutes(5),
        ),
      ],
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.88,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x33070A11),
          border: Border.all(color: Night.hairline),
        ),
        child: Icon(icon, size: 18, color: Tone.primary),
      ),
    );
  }
}
