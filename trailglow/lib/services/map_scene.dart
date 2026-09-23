import 'package:flutter/widgets.dart';

import '../data/models/heatmap_data.dart';
import '../utils/geo.dart';

enum TrailStyle { glow, ghost, ember }

enum MarkerKind { start, finish, runner, pin }

@immutable
class TrailLine {
  const TrailLine({
    required this.id,
    required this.path,
    this.progress = 1.0,
    this.style = TrailStyle.glow,
    this.width = 5.0,
    this.opacity = 1.0,
  });

  final String id;
  final List<LatLng> path;
  final double progress;
  final TrailStyle style;
  final double width;
  final double opacity;

  TrailLine copyWith({double? progress, double? opacity}) => TrailLine(
    id: id,
    path: path,
    progress: progress ?? this.progress,
    style: style,
    width: width,
    opacity: opacity ?? this.opacity,
  );
}

@immutable
class MapMarker {
  const MapMarker({
    required this.id,
    required this.position,
    required this.kind,
    this.bearing = 0,
  });

  final String id;
  final LatLng position;
  final MarkerKind kind;
  final double bearing;
}

@immutable
class MapCamera {
  const MapCamera({
    required this.center,
    required this.zoom,
    this.bearing = 0,
    this.pitch = 0,
  });

  final LatLng center;
  final double zoom;
  final double bearing;
  final double pitch;

  MapCamera copyWith({
    LatLng? center,
    double? zoom,
    double? bearing,
    double? pitch,
  }) => MapCamera(
    center: center ?? this.center,
    zoom: zoom ?? this.zoom,
    bearing: bearing ?? this.bearing,
    pitch: pitch ?? this.pitch,
  );

  bool closeTo(MapCamera other) =>
      (center.lat - other.center.lat).abs() < 1e-6 &&
      (center.lng - other.center.lng).abs() < 1e-6 &&
      (zoom - other.zoom).abs() < 0.01 &&
      (bearing - other.bearing).abs() < 0.1 &&
      (pitch - other.pitch).abs() < 0.1;
}

@immutable
class CameraRequest {
  const CameraRequest({
    this.camera,
    this.fit,
    this.padding = const EdgeInsets.all(48),
    this.bearing = 0,
    this.pitch = 0,
    this.duration = const Duration(milliseconds: 1200),
    this.instant = false,
    this.token = 0,
  });

  final MapCamera? camera;
  final GeoBounds? fit;
  final EdgeInsets padding;
  final double bearing;
  final double pitch;
  final Duration duration;
  final bool instant;
  final int token;
}

@immutable
class MapScene {
  const MapScene({
    this.lines = const <TrailLine>[],
    this.markers = const <MapMarker>[],
    this.heatmap,
    this.camera,
    this.interactive = true,
    this.dim = 0.0,
    this.ornamentInset = 28,
  });

  final List<TrailLine> lines;
  final List<MapMarker> markers;
  final HeatmapData? heatmap;
  final CameraRequest? camera;
  final bool interactive;
  final double dim;
  final double ornamentInset;

  MapScene withOrnamentInset(double value) => MapScene(
    lines: lines,
    markers: markers,
    heatmap: heatmap,
    camera: camera,
    interactive: interactive,
    dim: dim,
    ornamentInset: value,
  );

  String get lineSignature =>
      lines.map((l) => '${l.id}:${l.path.length}:${l.style.index}').join('|');
}
