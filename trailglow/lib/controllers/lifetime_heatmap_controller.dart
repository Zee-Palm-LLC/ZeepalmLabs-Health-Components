import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/mock/heatmap.dart';
import '../data/models/heatmap_data.dart';
import '../data/models/run_stats.dart';
import 'map_controller.dart';

class LifetimeHeatmapController extends GetxController {
  final MapController map = Get.find<MapController>();

  final Rx<HeatmapRange> range = HeatmapRange.all.obs;

  HeatmapData get data => MockHeatmap.forRange(range.value);

  LifetimeStats get stats => data.stats;

  int get rangeIndex => HeatmapRange.values.indexOf(range.value);

  @override
  void onReady() {
    super.onReady();
    pushScene();
  }

  void selectRange(int index) {
    final next = HeatmapRange.values[index.clamp(0, 3)];
    if (next == range.value) return;
    range.value = next;
    pushScene();
  }

  void setBottomInset(double value) {
    final padding = map.heatmapPadding;
    if ((padding.bottom - value).abs() < 6) return;
    map.heatmapPadding = EdgeInsets.fromLTRB(
      padding.left,
      padding.top,
      padding.right,
      value,
    );
    pushScene();
  }

  void pushScene() {
    map.showHeatmap(data, MockHeatmap.cityBounds);
  }
}
