import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../theme/aegis_theme.dart';
import '../../theme/motion.dart';
import '../formatting.dart';
import '../models.dart';
import '../route_path.dart';

const _arcgisApiKey = String.fromEnvironment('ARCGIS_API_KEY');
const _imageryUrl =
    'https://ibasemaps-api.arcgis.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}?token={token}';
const _imageryAttribution =
    'Esri, Vantor, Earthstar Geographics, GIS User Community';

// Pulls the imagery down to the reference's night-time tone without
// re-rendering each tile.
const _nightImagery = ColorFilter.matrix(<double>[
  0.40, 0.02, 0.02, 0, 0,
  0.02, 0.44, 0.02, 0, 2,
  0.02, 0.04, 0.52, 0, 6,
  0, 0, 0, 1, 0,
]);

/// The dispatch map.
///
/// [travel] drives how far along [Dispatch.route] the vehicle has come, from
/// zero at the responder's starting point to one at the patient. The road
/// behind it fills in solid as it goes while the road ahead stays dashed, so
/// the remaining distance is always the part still drawn as a plan.
class ResponderMap extends StatefulWidget {
  const ResponderMap({
    super.key,
    required this.dispatch,
    this.travel = const AlwaysStoppedAnimation(0),
  });

  final Dispatch dispatch;
  final Animation<double> travel;

  @override
  State<ResponderMap> createState() => _ResponderMapState();
}

class _ResponderMapState extends State<ResponderMap>
    with SingleTickerProviderStateMixin {
  static const _radius = BorderRadius.all(Radius.circular(18));
  static const _vehicleSize = 44.0;
  static const _vehicleMarkerWidth = _vehicleSize + 8 + _EtaChip.width;

  final _mapController = MapController();
  final _rotation = ValueNotifier<double>(0);

  /// Radar sweep on the destination pin. Decorative, so reduced motion parks
  /// it rather than looping.
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  late RoutePath _path = RoutePath(widget.dispatch.route);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _sweep.stop();
      _sweep.value = 0;
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void didUpdateWidget(ResponderMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.dispatch.route, widget.dispatch.route)) {
      _path = RoutePath(widget.dispatch.route);
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    _rotation.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dispatch = widget.dispatch;

    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: const BoxDecoration(
        borderRadius: _radius,
        border: Border.fromBorderSide(BorderSide(color: AegisColors.hairline)),
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                backgroundColor: AegisColors.mapBase,
                initialCameraFit: CameraFit.coordinates(
                  coordinates: dispatch.route,
                  padding: const EdgeInsets.fromLTRB(44, 60, 44, 52),
                ),
                onPositionChanged: (camera, _) =>
                    _rotation.value = camera.rotation,
              ),
              children: [
                if (_arcgisApiKey.isNotEmpty)
                  ColorFiltered(
                    colorFilter: _nightImagery,
                    child: TileLayer(
                      urlTemplate: _imageryUrl,
                      additionalOptions: const {'token': _arcgisApiKey},
                      userAgentPackageName: 'app.aegis',
                    ),
                  ),
                // Only the layers that move are rebuilt; the map itself is not.
                AnimatedBuilder(
                  animation: widget.travel,
                  builder: (context, _) => _RouteLayer(
                    path: _path,
                    travelled: widget.travel.value,
                  ),
                ),
                AnimatedBuilder(
                  animation: Listenable.merge([widget.travel, _sweep]),
                  builder: (context, _) => _MarkerLayer(
                    dispatch: dispatch,
                    path: _path,
                    travelled: widget.travel.value,
                    sweep: _sweep.value,
                  ),
                ),
              ],
            ),
            if (_arcgisApiKey.isNotEmpty)
              const Positioned(
                left: 12,
                top: 10,
                child: Text(
                  _imageryAttribution,
                  style: TextStyle(fontSize: 8.5, color: Color(0x8CFFFFFF)),
                ),
              ),
            Positioned(
              right: 12,
              bottom: 12,
              child: _CompassButton(
                rotation: _rotation,
                onPressed: () => _mapController.rotate(0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Road behind the vehicle solid, road ahead dashed.
class _RouteLayer extends StatelessWidget {
  const _RouteLayer({required this.path, required this.travelled});

  final RoutePath path;
  final double travelled;

  @override
  Widget build(BuildContext context) {
    final ahead = path.slice(travelled, 1);
    final behind = path.slice(0, travelled);

    return PolylineLayer(
      polylines: [
        Polyline(
          points: ahead,
          strokeWidth: 2.4,
          color: AegisColors.amber.withValues(alpha: 0.75),
          pattern: StrokePattern.dashed(segments: const [7, 6]),
        ),
        if (behind.length > 1) ...[
          // Glow first so the bright core sits on top of it.
          Polyline(
            points: behind,
            strokeWidth: 9,
            color: AegisColors.ember.withValues(alpha: 0.2),
          ),
          Polyline(
            points: behind,
            strokeWidth: 3.2,
            color: AegisColors.amberBright,
          ),
        ],
      ],
    );
  }
}

class _MarkerLayer extends StatelessWidget {
  const _MarkerLayer({
    required this.dispatch,
    required this.path,
    required this.travelled,
    required this.sweep,
  });

  final Dispatch dispatch;
  final RoutePath path;
  final double travelled;
  final double sweep;

  @override
  Widget build(BuildContext context) {
    final remaining = 1 - travelled;
    final arrived = travelled >= 0.999;
    final waypoint = dispatch.waypoint;
    final waypointAt = waypoint == null ? null : path.fractionOf(waypoint);

    return MarkerLayer(
      markers: [
        Marker(
          point: dispatch.destination,
          width: _DestinationMarker.size,
          height: _DestinationMarker.size,
          child: _DestinationMarker(sweep: sweep, closeness: travelled),
        ),
        if (waypoint != null)
          Marker(
            point: waypoint,
            width: 36,
            height: 36,
            // Fades once the vehicle is past it; it has served its purpose.
            child: _WaypointMarker(
              passed: waypointAt != null && travelled > waypointAt,
            ),
          ),
        if (!arrived)
          Marker(
            point: path.pointAt(travelled),
            width: _ResponderMapState._vehicleMarkerWidth,
            height: _EtaChip.height,
            // Anchors the vehicle, not the chip beside it, on the coordinate.
            alignment: const Alignment(
              1 -
                  _ResponderMapState._vehicleSize /
                      _ResponderMapState._vehicleMarkerWidth,
              0,
            ),
            child: Row(
              children: [
                _VehicleMarker(
                  size: _ResponderMapState._vehicleSize,
                  bearing: path.bearingAt(travelled),
                ),
                const SizedBox(width: 8),
                _EtaChip(eta: dispatch.eta * remaining),
              ],
            ),
          ),
      ],
    );
  }
}

class _VehicleMarker extends StatelessWidget {
  const _VehicleMarker({required this.size, required this.bearing});

  final double size;

  /// Compass degrees the vehicle is heading.
  final double bearing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0B0F12),
        border: Border.all(color: AegisColors.amber, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AegisColors.amber.withValues(alpha: 0.45),
            blurRadius: 18,
          ),
        ],
      ),
      // The glyph faces east, so zero degrees of bearing is a quarter turn.
      child: Transform.rotate(
        angle: (bearing - 90) * math.pi / 180,
        child: const Icon(
          Icons.airport_shuttle,
          size: 21,
          color: AegisColors.amber,
          semanticLabel: 'Ambulance',
        ),
      ),
    );
  }
}

class _EtaChip extends StatelessWidget {
  const _EtaChip({required this.eta});

  static const double width = 74;
  static const double height = 50;

  final Duration eta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xE6070D12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AegisColors.hairline),
      ),
      // The chip is a fixed-size map marker, so its text scales down rather
      // than overflowing when a large text scale or an unusual face is in use.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ETA',
              style: TextStyle(fontSize: 11, color: AegisColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              formatEta(eta),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AegisColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaypointMarker extends StatelessWidget {
  const _WaypointMarker({required this.passed});

  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: passed ? 0.3 : 1,
        duration: AegisMotion.medium,
        child: AnimatedContainer(
          duration: AegisMotion.medium,
          width: passed ? 12 : 18,
          height: passed ? 12 : 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AegisColors.amberBright,
            border: Border.all(color: AegisColors.ember, width: 3),
            boxShadow: [
              BoxShadow(
                color: AegisColors.amber.withValues(alpha: passed ? 0 : 0.7),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker({required this.sweep, required this.closeness});

  static const double size = 72;
  static const double _pinSize = 30;

  /// Phase of the radar ring, 0..1, looping.
  final double sweep;

  /// How far the responder has come. The sweep tightens and brightens as this
  /// approaches one, so the pin reads as being closed in on.
  final double closeness;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _RadarPainter(sweep: sweep, intensity: closeness),
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AegisColors.teal.withValues(alpha: 0.12),
            border: Border.all(color: AegisColors.teal.withValues(alpha: 0.45)),
          ),
        ),
        // Lifts the pin so its tip, not its centre, sits on the coordinate.
        const Positioned(
          top: size / 2 - _pinSize + 2,
          child: Icon(
            Icons.location_on,
            size: _pinSize,
            color: AegisColors.tealBright,
            semanticLabel: 'Your location',
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.sweep, required this.intensity});

  final double sweep;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final strength = 0.3 + 0.7 * intensity;

    canvas.drawCircle(
      center,
      maxRadius * 0.52,
      Paint()
        ..color = AegisColors.teal.withValues(alpha: 0.1 * strength)
        ..style = PaintingStyle.fill,
    );

    // Two rings, half a cycle apart, so there is always one in flight.
    for (final offset in const [0.0, 0.5]) {
      final t = (sweep + offset) % 1;
      final radius = maxRadius * (0.3 + 0.7 * t);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6 * (1 - t) + 0.4
          ..color = AegisColors.tealBright.withValues(
            alpha: 0.5 * (1 - t) * strength,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.sweep != sweep || oldDelegate.intensity != intensity;
}

class _CompassButton extends StatelessWidget {
  const _CompassButton({required this.rotation, required this.onPressed});

  final ValueListenable<double> rotation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Reset map to north',
      child: Material(
        color: const Color(0xE60B1116),
        shape: const CircleBorder(
          side: BorderSide(color: AegisColors.hairline),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 40,
            child: ValueListenableBuilder<double>(
              valueListenable: rotation,
              builder: (context, degrees, child) => Transform.rotate(
                angle: -degrees * math.pi / 180,
                child: child,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.location_north_fill,
                    size: 13,
                    color: AegisColors.textPrimary,
                  ),
                  Text(
                    'N',
                    style: TextStyle(
                      fontSize: 7,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      color: AegisColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
