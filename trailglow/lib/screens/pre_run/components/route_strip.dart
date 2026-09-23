import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/motion.dart';
import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../controllers/pre_run_controller.dart';
import '../../../data/mock/routes.dart';
import '../../../widgets/press_scale.dart';

class RouteStrip extends StatelessWidget {
  const RouteStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PreRunController>();
    return SizedBox(
      height: 34,
      child: ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: <double>[0.0, 0.88, 1.0],
        ).createShader(rect),
        blendMode: BlendMode.dstIn,
        child: Obx(() {
          final current = controller.routeIndex.value;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: MockRoutes.all.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final route = MockRoutes.all[index];
              final selected = current == index;
              return PressScale(
                onTap: () => controller.selectRoute(index),
                scale: 0.94,
                child: AnimatedContainer(
                  duration: Motion.quick,
                  curve: Motion.enter,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    color: selected
                        ? Spectrum.blue.withValues(alpha: 0.18)
                        : const Color(0x33070A11),
                    border: Border.all(
                      color: selected
                          ? Spectrum.sky.withValues(alpha: 0.55)
                          : Night.hairlineSoft,
                    ),
                  ),
                  child: Text(
                    route.name,
                    style: Typo.text(
                      12,
                      weight: selected ? 700 : 500,
                      color: selected ? Tone.bright : Tone.secondary,
                      height: 1.0,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
