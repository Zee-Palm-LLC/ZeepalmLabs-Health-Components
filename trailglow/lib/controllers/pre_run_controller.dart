import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/mock/routes.dart';
import '../data/mock/runs.dart';
import '../data/models/run_model.dart';
import 'map_controller.dart';

enum GoalMode { free, distance, time }

class PreRunController extends GetxController {
  final MapController map = Get.find<MapController>();

  final RxInt routeIndex = 0.obs;
  final Rx<GoalMode> goal = GoalMode.free.obs;
  final RxDouble targetDistance = 8.4.obs;
  final RxInt targetMinutes = 45.obs;

  PlannedRun get plan => MockRuns.planFor(routeIndex.value);

  int get routeCount => MockRoutes.all.length;

  String get goalSummary => switch (goal.value) {
    GoalMode.free => 'Open run',
    GoalMode.distance => '${targetDistance.value.toStringAsFixed(1)} km goal',
    GoalMode.time => '${targetMinutes.value} min goal',
  };

  @override
  void onReady() {
    super.onReady();
    pushScene();
  }

  void setBottomInset(double value) {
    final padding = map.previewPadding;
    if ((padding.bottom - value).abs() < 6) return;
    map.previewPadding = EdgeInsets.fromLTRB(
      padding.left,
      padding.top,
      padding.right,
      value,
    );
    pushScene();
  }

  void pushScene({bool instant = false}) {
    map.showRoutePreview(plan.route, instant: instant);
  }

  void selectRoute(int index) {
    if (index == routeIndex.value) return;
    routeIndex.value = index % routeCount;
    pushScene();
  }

  void nextRoute() => selectRoute(routeIndex.value + 1);

  void previousRoute() =>
      selectRoute((routeIndex.value - 1 + routeCount) % routeCount);

  void setGoal(GoalMode mode) => goal.value = mode;

  void nudgeDistance(double delta) {
    targetDistance.value = (targetDistance.value + delta)
        .clamp(1.0, 42.0)
        .toDouble();
  }

  void nudgeMinutes(int delta) {
    targetMinutes.value = (targetMinutes.value + delta).clamp(5, 240);
  }

  void recenterOnRoute() => pushScene();
}
