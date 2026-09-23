import 'dart:convert';
import 'dart:ui' show Color;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../app/theme/palette.dart';
import '../data/models/heatmap_data.dart';
import '../utils/geo.dart';
import 'map_scene.dart';

const String _heatSource = 'tg_heat_src';
const String _traceSource = 'tg_trace_src';
const String _heatLayer = 'tg_heat';
const String _traceLayer = 'tg_trace';
const String _markerSource = 'tg_marker_src';
const String _markerHalo = 'tg_marker_halo';
const String _markerCore = 'tg_marker_core';

class MapboxSceneRenderer {
  mb.MapboxMap? _map;
  MapScene? _applied;
  bool _styleReady = false;
  int _cameraToken = -1;

  bool get ready => _map != null && _styleReady;

  void attach(mb.MapboxMap map) {
    _map = map;
    _styleReady = false;
    _applied = null;
    map.scaleBar.updateSettings(mb.ScaleBarSettings(enabled: false));
    map.compass.updateSettings(mb.CompassSettings(enabled: false));
  }

  void detach() {
    _map = null;
    _applied = null;
    _styleReady = false;
  }

  Future<void> onStyleLoaded(MapScene scene) async {
    final map = _map;
    if (map == null) return;
    await _configureBasemap(map);
    _styleReady = true;
    _applied = null;
    await apply(scene, force: true);
  }

  Future<void> _configureBasemap(mb.MapboxMap map) async {
    final importIds = <String>[];
    try {
      final imports = await map.style.getStyleImports();
      for (final info in imports) {
        if (info != null) importIds.add(info.id);
      }
    } catch (_) {}
    if (importIds.isEmpty) importIds.add('basemap');

    Future<void> set(String key, Object value) async {
      for (final id in importIds) {
        try {
          await map.style.setStyleImportConfigProperty(id, key, value);
        } catch (_) {}
      }
    }

    await set('showPointOfInterestLabels', false);
    await set('showTransitLabels', false);
    await set('showPedestrianRoads', true);
    await set('showRoadLabels', false);
    await set('showPlaceLabels', false);
    await set('show3dObjects', true);
    await set('theme', 'default');
    await set('lightPreset', 'night');

    try {
      await map.style.setStyleTransition(
        mb.TransitionOptions(
          duration: 320,
          delay: 0,
          enablePlacementTransitions: true,
        ),
      );
    } catch (_) {}
  }

  Future<void> apply(MapScene scene, {bool force = false}) async {
    final map = _map;
    if (map == null || !_styleReady) return;
    final previous = _applied;
    _applied = scene;

    final linesChanged =
        force ||
        previous == null ||
        previous.lineSignature != scene.lineSignature;

    if (linesChanged) {
      await _rebuildLines(map, previous, scene);
    } else {
      for (var i = 0; i < scene.lines.length; i++) {
        final next = scene.lines[i];
        final old = previous.lines[i];
        if ((next.progress - old.progress).abs() > 0.0005) {
          await _setProgress(map, next);
        }
        if ((next.opacity - old.opacity).abs() > 0.01) {
          await _setOpacity(map, next);
        }
      }
    }

    final markersChanged =
        force ||
        previous == null ||
        previous.markers.length != scene.markers.length ||
        _markerSignature(previous.markers) != _markerSignature(scene.markers);
    if (markersChanged) {
      await _rebuildMarkers(map, scene.markers);
    }

    final heatChanged =
        force ||
        previous == null ||
        previous.heatmap?.range != scene.heatmap?.range;
    if (heatChanged) {
      await _rebuildHeatmap(map, scene.heatmap);
    }

    if (previous == null || previous.ornamentInset != scene.ornamentInset) {
      await _placeOrnaments(map, scene.ornamentInset);
    }

    final request = scene.camera;
    if (request != null && request.token != _cameraToken) {
      _cameraToken = request.token;
      await _moveCamera(map, request);
    }
  }

  Future<void> _rebuildLines(
    mb.MapboxMap map,
    MapScene? previous,
    MapScene scene,
  ) async {
    for (final line in previous?.lines ?? const <TrailLine>[]) {
      for (final id in _layerIdsFor(line)) {
        await _removeLayer(map, id);
      }
      await _removeSource(map, _sourceIdFor(line));
    }

    for (final line in scene.lines) {
      if (line.path.length < 2) continue;
      await map.style.addSource(
        mb.GeoJsonSource(
          id: _sourceIdFor(line),
          data: jsonEncode(_lineFeature(line.path)),
          lineMetrics: true,
        ),
      );
      for (final layer in _layersFor(line)) {
        await map.style.addLayer(layer);
      }
      await _setProgress(map, line);
    }
  }

  String _sourceIdFor(TrailLine line) => 'tg_src_${line.id}';

  List<String> _layerIdsFor(TrailLine line) => <String>[
    'tg_${line.id}_halo',
    'tg_${line.id}_glow',
    'tg_${line.id}_core',
  ];

  List<mb.Layer> _layersFor(TrailLine line) {
    final source = _sourceIdFor(line);
    final ids = _layerIdsFor(line);
    if (line.style == TrailStyle.ghost) {
      return <mb.Layer>[
        mb.LineLayer(
          id: ids[2],
          sourceId: source,
          slot: 'middle',
          lineCap: mb.LineCap.ROUND,
          lineJoin: mb.LineJoin.ROUND,
          lineWidth: line.width,
          lineBlur: line.width * 0.8,
          lineColor: Spectrum.blue.toARGB32(),
          lineOpacity: 0.16 * line.opacity,
          lineEmissiveStrength: 1.0,
        ),
      ];
    }

    final accent = line.style == TrailStyle.ember
        ? Spectrum.amber
        : Spectrum.cyan;

    return <mb.Layer>[
      mb.LineLayer(
        id: ids[0],
        sourceId: source,
        slot: 'middle',
        lineCap: mb.LineCap.ROUND,
        lineJoin: mb.LineJoin.ROUND,
        lineWidth: line.width * 6.2,
        lineBlur: line.width * 7.0,
        lineColor: Spectrum.blue.toARGB32(),
        lineOpacity: 0.34 * line.opacity,
        lineEmissiveStrength: 1.0,
      ),
      mb.LineLayer(
        id: ids[1],
        sourceId: source,
        slot: 'top',
        lineCap: mb.LineCap.ROUND,
        lineJoin: mb.LineJoin.ROUND,
        lineWidth: line.width * 2.9,
        lineBlur: line.width * 2.6,
        lineColor: accent.toARGB32(),
        lineOpacity: 0.42 * line.opacity,
        lineEmissiveStrength: 1.0,
      ),
      mb.LineLayer(
        id: ids[2],
        sourceId: source,
        slot: 'top',
        lineCap: mb.LineCap.ROUND,
        lineJoin: mb.LineJoin.ROUND,
        lineWidth: line.width,
        lineOpacity: line.opacity,
        lineEmissiveStrength: 1.0,
        lineTrimColor: 0xFF18243E,
        lineTrimFadeRange: <double>[0.0, 0.06],
        lineGradientExpression: _gradientExpression(line.style),
      ),
    ];
  }

  List<Object> _gradientExpression(TrailStyle style, {double span = 1.0}) {
    final stops = style == TrailStyle.ember
        ? <double>[0.0, 0.35, 0.68, 1.0]
        : <double>[0.0, 0.28, 0.55, 0.78, 1.0];
    final colors = style == TrailStyle.ember
        ? <Color>[Spectrum.deep, Spectrum.blue, Spectrum.amber, Spectrum.ember]
        : <Color>[
            Spectrum.deep,
            Spectrum.blue,
            Spectrum.sky,
            Spectrum.cyan,
            Spectrum.teal,
          ];
    final scale = span.clamp(0.04, 1.0);
    final ramp = <Object>[];
    for (var i = 0; i < stops.length; i++) {
      ramp.add((stops[i] * scale).clamp(0.0, 1.0));
      ramp.add(_rgb(colors[i]));
    }
    if (scale < 0.999) {
      ramp.add((scale + 0.0005).clamp(0.0, 1.0));
      ramp.add(_rgb(colors.last));
    }
    return <Object>[
      'interpolate',
      <Object>['linear'],
      <Object>['line-progress'],
      ...ramp,
    ];
  }

  List<Object> _rgb(Color color) => <Object>[
    'rgb',
    (color.r * 255).round(),
    (color.g * 255).round(),
    (color.b * 255).round(),
  ];

  Future<void> _setProgress(mb.MapboxMap map, TrailLine line) async {
    final ids = _layerIdsFor(line);
    final progress = line.progress.clamp(0.0, 1.0);
    final trim = <double>[progress, 1.0];
    for (final id in ids) {
      if (!await _layerExists(map, id)) continue;
      if (progress >= 0.999) {
        await map.style.setStyleLayerProperty(id, 'line-trim-offset', <double>[
          0,
          0,
        ]);
      } else {
        await map.style.setStyleLayerProperty(id, 'line-trim-offset', trim);
      }
    }
    if (line.style == TrailStyle.ghost) return;
    await map.style.setStyleLayerProperty(
      ids[2],
      'line-gradient',
      _gradientExpression(line.style, span: progress),
    );
  }

  Future<void> _setOpacity(mb.MapboxMap map, TrailLine line) async {
    final ids = _layerIdsFor(line);
    const factors = <double>[0.34, 0.42, 1.0];
    for (var i = 0; i < ids.length; i++) {
      if (!await _layerExists(map, ids[i])) continue;
      await map.style.setStyleLayerProperty(
        ids[i],
        'line-opacity',
        factors[i] * line.opacity,
      );
    }
  }

  String _markerSignature(List<MapMarker> markers) => markers
      .map(
        (m) =>
            '${m.id}:${m.kind.index}:${m.position.lat.toStringAsFixed(5)}:${m.position.lng.toStringAsFixed(5)}',
      )
      .join('|');

  Future<void> _rebuildMarkers(
    mb.MapboxMap map,
    List<MapMarker> markers,
  ) async {
    await _removeLayer(map, _markerHalo);
    await _removeLayer(map, _markerCore);
    await _removeSource(map, _markerSource);

    final visible = markers
        .where((m) => m.kind != MarkerKind.runner)
        .toList(growable: false);
    if (visible.isEmpty) return;

    await map.style.addSource(
      mb.GeoJsonSource(
        id: _markerSource,
        data: jsonEncode(_markerCollection(visible)),
      ),
    );

    List<Object> colorMatch(double alpha) => <Object>[
      'match',
      <Object>['get', 'kind'],
      'start',
      _rgba(Spectrum.teal, alpha),
      'finish',
      _rgba(Spectrum.amber, alpha),
      _rgba(Spectrum.sky, alpha),
    ];

    await map.style.addLayer(
      mb.CircleLayer(
        id: _markerHalo,
        sourceId: _markerSource,
        slot: 'top',
        circleRadius: 17,
        circleBlur: 1.2,
        circleEmissiveStrength: 1.0,
        circleColorExpression: colorMatch(0.30),
      ),
    );
    await map.style.addLayer(
      mb.CircleLayer(
        id: _markerCore,
        sourceId: _markerSource,
        slot: 'top',
        circleRadius: 5.0,
        circleColor: 0xFF05070C,
        circleStrokeWidth: 2.6,
        circleEmissiveStrength: 1.0,
        circleStrokeColorExpression: colorMatch(1.0),
      ),
    );
  }

  List<Object> _rgba(Color color, double alpha) => <Object>[
    'rgba',
    (color.r * 255).round(),
    (color.g * 255).round(),
    (color.b * 255).round(),
    alpha,
  ];

  static Map<String, Object?> _markerCollection(List<MapMarker> markers) =>
      <String, Object?>{
        'type': 'FeatureCollection',
        'features': markers
            .map(
              (m) => <String, Object?>{
                'type': 'Feature',
                'properties': <String, Object?>{'kind': m.kind.name},
                'geometry': <String, Object?>{
                  'type': 'Point',
                  'coordinates': <double>[m.position.lng, m.position.lat],
                },
              },
            )
            .toList(growable: false),
      };

  Future<void> _rebuildHeatmap(mb.MapboxMap map, HeatmapData? data) async {
    await _removeLayer(map, _heatLayer);
    await _removeLayer(map, _traceLayer);
    await _removeSource(map, _heatSource);
    await _removeSource(map, _traceSource);
    if (data == null) return;

    await map.style.addSource(
      mb.GeoJsonSource(
        id: _traceSource,
        data: jsonEncode(_traceCollection(data.traces)),
      ),
    );
    await map.style.addLayer(
      mb.LineLayer(
        id: _traceLayer,
        sourceId: _traceSource,
        slot: 'middle',
        lineCap: mb.LineCap.ROUND,
        lineJoin: mb.LineJoin.ROUND,
        lineWidth: 1.4,
        lineBlur: 1.0,
        lineColor: Spectrum.sky.toARGB32(),
        lineOpacity: 0.26,
        lineEmissiveStrength: 1.0,
      ),
    );

    await map.style.addSource(
      mb.GeoJsonSource(
        id: _heatSource,
        data: jsonEncode(_heatCollection(data.points)),
      ),
    );
    await map.style.addLayer(
      mb.HeatmapLayer(
        id: _heatLayer,
        sourceId: _heatSource,
        slot: 'top',
        heatmapWeightExpression: <Object>[
          'interpolate',
          <Object>['linear'],
          <Object>['get', 'w'],
          0.0,
          0.0,
          1.0,
          0.22,
        ],
        heatmapIntensityExpression: <Object>[
          'interpolate',
          <Object>['linear'],
          <Object>['zoom'],
          10.0,
          0.18,
          13.0,
          0.42,
          16.0,
          0.9,
        ],
        heatmapRadiusExpression: <Object>[
          'interpolate',
          <Object>['linear'],
          <Object>['zoom'],
          10.0,
          3.0,
          13.0,
          7.0,
          16.0,
          16.0,
        ],
        heatmapOpacity: 0.85,
        heatmapColorExpression: <Object>[
          'interpolate',
          <Object>['linear'],
          <Object>['heatmap-density'],
          0.0,
          <Object>['rgba', 0, 0, 0, 0],
          0.10,
          <Object>['rgba', 14, 32, 86, 0.30],
          0.30,
          <Object>['rgba', 24, 78, 186, 0.58],
          0.52,
          <Object>['rgba', 47, 150, 255, 0.72],
          0.72,
          <Object>['rgba', 57, 226, 224, 0.82],
          0.90,
          <Object>['rgba', 255, 198, 90, 0.90],
          1.0,
          <Object>['rgba', 255, 122, 60, 0.95],
        ],
      ),
    );
  }

  Future<void> _moveCamera(mb.MapboxMap map, CameraRequest request) async {
    var options = request.camera == null
        ? null
        : mb.CameraOptions(
            center: _point(request.camera!.center),
            zoom: request.camera!.zoom,
            bearing: request.camera!.bearing,
            pitch: request.camera!.pitch,
            padding: mb.MbxEdgeInsets(
              top: request.padding.top,
              left: request.padding.left,
              bottom: request.padding.bottom,
              right: request.padding.right,
            ),
          );

    if (options == null && request.fit != null) {
      final bounds = request.fit!;
      options = await map.cameraForCoordinatesPadding(
        <mb.Point>[
          _point(LatLng(bounds.south, bounds.west)),
          _point(LatLng(bounds.north, bounds.east)),
          _point(LatLng(bounds.south, bounds.east)),
          _point(LatLng(bounds.north, bounds.west)),
        ],
        mb.CameraOptions(bearing: request.bearing, pitch: request.pitch),
        mb.MbxEdgeInsets(
          top: request.padding.top,
          left: request.padding.left,
          bottom: request.padding.bottom,
          right: request.padding.right,
        ),
        16.4,
        null,
      );
      options.bearing = request.bearing;
      options.pitch = request.pitch;
    }
    if (options == null) return;

    if (request.instant) {
      await map.setCamera(options);
      return;
    }
    final animation = mb.MapAnimationOptions(
      duration: request.duration.inMilliseconds,
    );
    if (request.duration.inMilliseconds > 900) {
      await map.flyTo(options, animation);
    } else {
      await map.easeTo(options, animation);
    }
  }

  Future<void> _placeOrnaments(mb.MapboxMap map, double inset) async {
    try {
      await map.logo.updateSettings(
        mb.LogoSettings(marginLeft: 20, marginBottom: inset),
      );
      await map.attribution.updateSettings(
        mb.AttributionSettings(marginLeft: 116, marginBottom: inset + 4),
      );
    } catch (_) {}
  }

  Future<bool> _layerExists(mb.MapboxMap map, String id) async {
    try {
      return await map.style.styleLayerExists(id);
    } catch (_) {
      return false;
    }
  }

  Future<void> _removeLayer(mb.MapboxMap map, String id) async {
    try {
      if (await map.style.styleLayerExists(id)) {
        await map.style.removeStyleLayer(id);
      }
    } catch (_) {}
  }

  Future<void> _removeSource(mb.MapboxMap map, String id) async {
    try {
      if (await map.style.styleSourceExists(id)) {
        await map.style.removeStyleSource(id);
      }
    } catch (_) {}
  }

  static mb.Point _point(LatLng p) =>
      mb.Point(coordinates: mb.Position(p.lng, p.lat));

  static Map<String, Object?> _lineFeature(List<LatLng> path) =>
      <String, Object?>{
        'type': 'Feature',
        'properties': <String, Object?>{},
        'geometry': <String, Object?>{
          'type': 'LineString',
          'coordinates': path
              .map((p) => <double>[p.lng, p.lat])
              .toList(growable: false),
        },
      };

  static Map<String, Object?> _traceCollection(List<List<LatLng>> traces) =>
      <String, Object?>{
        'type': 'FeatureCollection',
        'features': traces.map(_lineFeature).toList(growable: false),
      };

  static Map<String, Object?> _heatCollection(List<HeatmapPoint> points) =>
      <String, Object?>{
        'type': 'FeatureCollection',
        'features': points
            .map(
              (p) => <String, Object?>{
                'type': 'Feature',
                'properties': <String, Object?>{'w': p.weight},
                'geometry': <String, Object?>{
                  'type': 'Point',
                  'coordinates': <double>[p.position.lng, p.position.lat],
                },
              },
            )
            .toList(growable: false),
      };
}
