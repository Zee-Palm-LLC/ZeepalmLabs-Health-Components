import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../app/config/app_config.dart';
import '../app/theme/palette.dart';
import '../services/map_scene.dart';
import '../services/map_support.dart';
import '../services/mapbox_renderer.dart';
import '../services/painted_map/painted_map_view.dart';

class TrailglowMap extends StatefulWidget {
  const TrailglowMap({
    super.key,
    required this.scene,
    required this.initialCamera,
  });

  final MapScene scene;
  final MapCamera initialCamera;

  @override
  State<TrailglowMap> createState() => _TrailglowMapState();
}

class _TrailglowMapState extends State<TrailglowMap> {
  final MapboxSceneRenderer _renderer = MapboxSceneRenderer();
  Timer? _styleWatchdog;

  bool get _useMapbox =>
      MapSupport.usesMapbox && !MapSupport.mapboxFailed.value;

  @override
  void initState() {
    super.initState();
    if (_useMapbox) {
      _styleWatchdog = Timer(const Duration(seconds: 8), _giveUpOnMapbox);
    }
  }

  @override
  void didUpdateWidget(TrailglowMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_useMapbox && _renderer.ready) {
      _renderer.apply(widget.scene);
    }
  }

  @override
  void dispose() {
    _styleWatchdog?.cancel();
    _renderer.detach();
    super.dispose();
  }

  void _giveUpOnMapbox() {
    _styleWatchdog?.cancel();
    _styleWatchdog = null;
    if (_renderer.ready || !mounted) return;
    _renderer.detach();
    MapSupport.mapboxFailed.value = true;
    setState(() {});
  }

  void _onStyleLoaded() {
    _styleWatchdog?.cancel();
    _styleWatchdog = null;
    _renderer.onStyleLoaded(widget.scene);
  }

  @override
  Widget build(BuildContext context) {
    if (!_useMapbox) {
      return PaintedMapView(
        scene: widget.scene,
        initialCamera: widget.initialCamera,
      );
    }

    final camera = widget.initialCamera;
    return mb.MapWidget(
      key: const ValueKey<String>('trailglow_mapbox'),
      styleUri: AppConfig.nightStyleJson,
      textureView: false,
      // ignore: experimental_member_use
      androidHostingMode: mb.AndroidPlatformViewHostingMode.HC,
      viewport: mb.IdleViewportState(),
      onMapCreated: (map) {
        _renderer.attach(map);
        map.setCamera(
          mb.CameraOptions(
            center: mb.Point(
              coordinates: mb.Position(camera.center.lng, camera.center.lat),
            ),
            zoom: camera.zoom,
            bearing: camera.bearing,
            pitch: camera.pitch,
          ),
        );
        map.gestures.updateSettings(
          mb.GesturesSettings(
            rotateEnabled: true,
            pitchEnabled: true,
            scrollEnabled: true,
            pinchToZoomEnabled: true,
            doubleTapToZoomInEnabled: true,
            quickZoomEnabled: true,
          ),
        );
      },
      onStyleLoadedListener: (_) => _onStyleLoaded(),
      onMapLoadErrorListener: (_) => _giveUpOnMapbox(),
    );
  }
}

class MapFallbackBadge extends StatelessWidget {
  const MapFallbackBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MapSupport.mapboxFailed,
      builder: (context, failed, _) {
        if (MapSupport.usesMapbox && !failed) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Night.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Night.hairline),
          ),
          child: Text(
            failed ? 'OFFLINE MAP' : 'VECTOR PREVIEW',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 8.5,
              height: 1.0,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w600,
              color: Tone.faint,
            ),
          ),
        );
      },
    );
  }
}
