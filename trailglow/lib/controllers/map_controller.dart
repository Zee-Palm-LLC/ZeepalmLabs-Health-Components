import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/mock/city_grid.dart';
import '../data/models/heatmap_data.dart';
import '../data/models/route_point.dart';
import '../services/map_scene.dart';
import '../services/map_support.dart';
import '../utils/geo.dart';

class MapController extends GetxController {
  final Rx<MapScene> scene = MapScene(
    camera: const CameraRequest(instant: true),
  ).obs;

  int _token = 0;
  double ornamentInset = 28;

  void setOrnamentInset(double value) {
    final clamped = value.clamp(20.0, 520.0).toDouble();
    if ((ornamentInset - clamped).abs() < 6) return;
    ornamentInset = clamped;
    scene.value = scene.value.withOrnamentInset(clamped);
  }

  MapCamera get initialCamera => MapCamera(
    center: CityGrid.at(82, 200),
    zoom: 12.1,
    bearing: -18,
    pitch: MapSupport.usesMapbox ? 38 : 0,
  );

  int get nextToken => ++_token;

  double get _pitch => MapSupport.usesMapbox ? 1.0 : 0.0;

  double followInset = 0;

  void setFollowInset(double value) {
    final clamped = value.clamp(0.0, 620.0).toDouble();
    if ((followInset - clamped).abs() < 8) return;
    followInset = clamped;
  }

  EdgeInsets previewPadding = const EdgeInsets.fromLTRB(36, 150, 36, 380);

  void showRoutePreview(
    RunRoute route, {
    EdgeInsets? padding,
    bool instant = false,
  }) {
    final insets = padding ?? previewPadding;
    scene.value = MapScene(
      lines: <TrailLine>[
        TrailLine(id: route.id, path: route.positions, width: 5.2),
      ],
      markers: <MapMarker>[
        MapMarker(id: 'start', position: route.start, kind: MarkerKind.start),
      ],
      ornamentInset: ornamentInset,
      camera: CameraRequest(
        fit: route.bounds,
        padding: insets,
        bearing: -18,
        pitch: 44 * _pitch,
        duration: const Duration(milliseconds: 1400),
        instant: instant,
        token: nextToken,
      ),
    );
  }

  void follow(
    RunRoute route,
    double progress,
    PathSample cameraTarget, {
    bool moveCamera = true,
    Duration duration = const Duration(milliseconds: 1050),
  }) {
    final current = scene.value;
    scene.value = MapScene(
      lines: <TrailLine>[
        TrailLine(
          id: route.id,
          path: route.positions,
          progress: progress,
          width: 5.6,
        ),
      ],
      markers: <MapMarker>[
        MapMarker(id: 'start', position: route.start, kind: MarkerKind.start),
      ],
      interactive: false,
      ornamentInset: ornamentInset,
      camera: moveCamera
          ? CameraRequest(
              camera: MapCamera(
                center: cameraTarget.position,
                zoom: 15.2,
                bearing: cameraTarget.bearing,
                pitch: 58 * _pitch,
              ),
              padding: EdgeInsets.only(bottom: followInset),
              duration: duration,
              token: nextToken,
            )
          : current.camera,
    );
  }

  EdgeInsets summaryPadding = const EdgeInsets.fromLTRB(48, 120, 48, 560);

  void showSummary(RunRoute route, double progress) {
    final travelled = route.sliceTo(progress);
    scene.value = MapScene(
      lines: <TrailLine>[
        TrailLine(
          id: '${route.id}_done',
          path: travelled,
          width: 5.4,
          style: TrailStyle.ember,
        ),
      ],
      markers: <MapMarker>[
        MapMarker(id: 'start', position: route.start, kind: MarkerKind.start),
        MapMarker(
          id: 'finish',
          position: travelled.last,
          kind: MarkerKind.finish,
        ),
      ],
      ornamentInset: ornamentInset,
      camera: CameraRequest(
        fit: GeoBounds.of(travelled),
        padding: summaryPadding,
        bearing: -12,
        pitch: 0,
        duration: const Duration(milliseconds: 1500),
        token: nextToken,
      ),
    );
  }

  EdgeInsets heatmapPadding = const EdgeInsets.fromLTRB(24, 140, 24, 430);

  void showHeatmap(HeatmapData data, GeoBounds bounds) {
    scene.value = MapScene(
      heatmap: data,
      ornamentInset: ornamentInset,
      camera: CameraRequest(
        fit: bounds,
        padding: heatmapPadding,
        bearing: -18,
        pitch: 32 * _pitch,
        duration: const Duration(milliseconds: 1400),
        token: nextToken,
      ),
    );
  }

  void recenter(CameraRequest request) {
    final current = scene.value;
    scene.value = MapScene(
      lines: current.lines,
      markers: current.markers,
      heatmap: current.heatmap,
      interactive: current.interactive,
      dim: current.dim,
      ornamentInset: current.ornamentInset,
      camera: CameraRequest(
        camera: request.camera,
        fit: request.fit,
        padding: request.padding,
        bearing: request.bearing,
        pitch: request.pitch,
        duration: request.duration,
        instant: request.instant,
        token: nextToken,
      ),
    );
  }
}
