import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../data/mock/runs.dart';
import '../data/models/route_point.dart';
import '../utils/geo.dart';
import 'map_controller.dart';
import 'pre_run_controller.dart';

class LiveRunController extends GetxController {
  LiveRunController({required this.route, required this.targetPaceSeconds});

  factory LiveRunController.fromPlan() {
    final plan = Get.find<PreRunController>().plan;
    return LiveRunController(
      route: plan.route,
      targetPaceSeconds: plan.targetPaceSeconds,
    );
  }

  final RunRoute route;
  final int targetPaceSeconds;

  static const double simulationSpeed = 12.0;

  final MapController map = Get.find<MapController>();

  final RxBool running = true.obs;
  final RxInt elapsed = 0.obs;
  final RxDouble distanceKm = 0.0.obs;
  final RxInt paceSeconds = 0.obs;
  final RxInt heartRate = 118.obs;
  final RxInt calories = 0.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool finished = false.obs;

  Ticker? _ticker;
  Duration _last = Duration.zero;
  double _simSeconds = 0;
  double _sceneClock = 0;
  double _cameraClock = 0;
  double get totalKm => route.distanceKm;

  @override
  void onInit() {
    super.onInit();
    paceSeconds.value = targetPaceSeconds;
    _ticker = Ticker(_onTick)..start();
  }

  @override
  void onReady() {
    super.onReady();
    map.follow(
      route,
      0,
      route.sampleAt(0.004),
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void onClose() {
    _ticker?.dispose();
    _ticker = null;
    super.onClose();
  }

  void _onTick(Duration now) {
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    if (!running.value || finished.value || dt <= 0) return;

    final sim = math.min(dt, 0.05) * simulationSpeed;
    _simSeconds += sim;
    _sceneClock += dt;
    _cameraClock += dt;

    final pace = targetPaceSeconds * MockRuns.paceFactorAt(progress.value);
    final advance = sim / pace / math.max(0.1, totalKm);
    final next = (progress.value + advance).clamp(0.0, 1.0);
    progress.value = next;

    final seconds = _simSeconds.floor();
    if (seconds != elapsed.value) {
      elapsed.value = seconds;
      heartRate.value = MockRuns.heartRateAt(next);
    }

    final km = totalKm * next;
    if ((km - distanceKm.value).abs() >= 0.01) {
      distanceKm.value = km;
      calories.value = (km * 72.7).round();
    }
    paceSeconds.value = pace.round();

    if (_sceneClock >= 0.12) {
      _sceneClock = 0;
      final moveCamera = _cameraClock >= 1.0;
      if (moveCamera) _cameraClock = 0;
      map.follow(route, next, _lookahead(next, pace), moveCamera: moveCamera);
    }

    if (next >= 1.0) finish();
  }

  PathSample _lookahead(double current, double pace) {
    final sim = 1.05 * simulationSpeed;
    final ahead = sim / pace / math.max(0.1, totalKm);
    return route.sampleAt(math.min(1.0, current + ahead));
  }

  void togglePause() {
    if (finished.value) return;
    running.value = !running.value;
  }

  void finish() {
    if (finished.value) return;
    running.value = false;
    finished.value = true;
  }

  double get completion => progress.value;
}
