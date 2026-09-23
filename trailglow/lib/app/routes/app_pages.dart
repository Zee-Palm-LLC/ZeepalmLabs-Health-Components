import 'package:get/get.dart';

import '../../controllers/lifetime_heatmap_controller.dart';
import '../../controllers/live_run_controller.dart';
import '../../controllers/pre_run_controller.dart';
import '../../controllers/run_summary_controller.dart';
import '../../data/models/route_point.dart';
import '../../screens/lifetime_heatmap/lifetime_heatmap_screen.dart';
import '../../screens/live_run/live_run_screen.dart';
import '../../screens/pre_run/pre_run_screen.dart';
import '../../screens/run_summary/run_summary_screen.dart';
import '../theme/motion.dart';
import 'app_routes.dart';

class SummaryArgs {
  const SummaryArgs({
    required this.route,
    required this.progress,
    required this.elapsedSeconds,
    required this.paceTarget,
  });

  final RunRoute route;
  final double progress;
  final int elapsedSeconds;
  final int paceTarget;
}

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: Routes.preRun,
      page: () => const PreRunScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PreRunController>(PreRunController.new);
      }),
      transition: Transition.fadeIn,
      transitionDuration: Motion.medium,
      curve: Motion.enter,
    ),
    GetPage<void>(
      name: Routes.liveRun,
      page: () => const LiveRunScreen(),
      binding: BindingsBuilder(() {
        Get.put<LiveRunController>(LiveRunController.fromPlan());
      }),
      transition: Transition.fadeIn,
      transitionDuration: Motion.medium,
      curve: Motion.enter,
    ),
    GetPage<void>(
      name: Routes.summary,
      page: () => const RunSummaryScreen(),
      binding: BindingsBuilder(() {
        final args = Get.arguments;
        if (args is SummaryArgs) {
          Get.put<RunSummaryController>(
            RunSummaryController(
              route: args.route,
              progress: args.progress,
              elapsedSeconds: args.elapsedSeconds,
              paceTarget: args.paceTarget,
            ),
          );
        } else {
          Get.put<RunSummaryController>(RunSummaryController());
        }
      }),
      transition: Transition.fadeIn,
      transitionDuration: Motion.medium,
      curve: Motion.enter,
    ),
    GetPage<void>(
      name: Routes.lifetime,
      page: () => const LifetimeHeatmapScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LifetimeHeatmapController>(LifetimeHeatmapController.new);
      }),
      transition: Transition.fadeIn,
      transitionDuration: Motion.medium,
      curve: Motion.enter,
    ),
  ];
}
