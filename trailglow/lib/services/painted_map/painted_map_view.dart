import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/motion.dart';
import '../../utils/geo.dart';
import '../map_scene.dart';
import 'city_painter.dart';
import 'map_projection.dart';
import 'trail_painter.dart';

class PaintedMapView extends StatefulWidget {
  const PaintedMapView({
    super.key,
    required this.scene,
    required this.initialCamera,
    this.onCameraChanged,
  });

  final MapScene scene;
  final MapCamera initialCamera;
  final ValueChanged<MapCamera>? onCameraChanged;

  @override
  State<PaintedMapView> createState() => _PaintedMapViewState();
}

class _PaintedMapViewState extends State<PaintedMapView>
    with TickerProviderStateMixin {
  late MapCamera _camera = widget.initialCamera;
  late final AnimationController _flight = AnimationController(vsync: this);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  MapCamera? _from;
  MapCamera? _to;
  int _token = -1;
  Size _size = const Size(400, 800);

  late MapCamera _gestureStart = _camera;
  Offset _focalStart = Offset.zero;
  double _rotationStart = 0;

  @override
  void initState() {
    super.initState();
    _flight.addListener(_onFlight);
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumeRequest());
  }

  @override
  void didUpdateWidget(PaintedMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _consumeRequest();
  }

  @override
  void dispose() {
    _flight.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _consumeRequest() {
    final request = widget.scene.camera;
    if (request == null || request.token == _token) return;
    _token = request.token;
    final target = _resolve(request);
    if (target == null) return;
    if (request.instant || request.duration == Duration.zero) {
      _flight.stop();
      setState(() => _camera = target);
      widget.onCameraChanged?.call(target);
      return;
    }
    _from = _camera;
    _to = target;
    _flight
      ..stop()
      ..duration = request.duration
      ..value = 0
      ..forward();
  }

  MapCamera? _resolve(CameraRequest request) {
    if (request.camera != null) return request.camera;
    final fit = request.fit;
    if (fit == null) return null;
    return MapProjection.fit(
      fit,
      _size,
      request.padding,
      bearing: request.bearing,
    );
  }

  void _onFlight() {
    final from = _from;
    final to = _to;
    if (from == null || to == null) return;
    final t = Motion.glide.transform(_flight.value);
    setState(() => _camera = _lerpCamera(from, to, t));
    if (_flight.isCompleted) widget.onCameraChanged?.call(_camera);
  }

  static MapCamera _lerpCamera(MapCamera a, MapCamera b, double t) {
    final ax = Mercator.xOf(a.center.lng);
    final ay = Mercator.yOf(a.center.lat);
    final bx = Mercator.xOf(b.center.lng);
    final by = Mercator.yOf(b.center.lat);
    var dBearing = (b.bearing - a.bearing) % 360;
    if (dBearing > 180) dBearing -= 360;
    if (dBearing < -180) dBearing += 360;
    return MapCamera(
      center: LatLng(
        Mercator.latOf(ay + (by - ay) * t),
        Mercator.lngOf(ax + (bx - ax) * t),
      ),
      zoom: a.zoom + (b.zoom - a.zoom) * t,
      bearing: a.bearing + dBearing * t,
      pitch: a.pitch + (b.pitch - a.pitch) * t,
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _flight.stop();
    _gestureStart = _camera;
    _focalStart = details.localFocalPoint;
    _rotationStart = 0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final start = _gestureStart;
    final zoom =
        (start.zoom + math.log(math.max(0.05, details.scale)) / math.ln2).clamp(
          10.0,
          17.5,
        );
    var bearing = start.bearing;
    if (details.pointerCount > 1) {
      bearing =
          start.bearing - (details.rotation - _rotationStart) * 180 / math.pi;
    }

    final moved = details.localFocalPoint - _focalStart;
    final zoomed = MapCamera(
      center: start.center,
      zoom: zoom,
      bearing: bearing,
      pitch: start.pitch,
    );
    final projection = MapProjection(zoomed, _size);
    final centre = Offset(_size.width / 2, _size.height / 2);
    final anchor = projection.toLatLng(centre - moved);

    setState(() {
      _camera = zoomed.copyWith(center: anchor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size != _size && size.width > 0 && size.height > 0) {
          _size = size;
        }
        final interactive = widget.scene.interactive;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: interactive ? _onScaleStart : null,
          onScaleUpdate: interactive ? _onScaleUpdate : null,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              RepaintBoundary(
                child: CustomPaint(
                  painter: CityPainter(camera: _camera, dim: widget.scene.dim),
                  size: size,
                ),
              ),
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => CustomPaint(
                    painter: TrailPainter(
                      camera: _camera,
                      scene: widget.scene,
                      pulse: _pulse.value,
                    ),
                    size: size,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
