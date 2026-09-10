import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

enum HeartRateStatus { normal, elevated }

@immutable
class HeartRateReading {
  const HeartRateReading({
    required this.bpm,
    required this.status,
    this.recentBpm = const [],
    this.ecgSamples = const [],
  });

  final int bpm;
  final HeartRateStatus status;

  /// Recent per-minute readings, oldest first. Drives the trend sparkline.
  final List<double> recentBpm;

  /// Raw waveform from the wearable's ECG sensor, if it has one.
  final List<double> ecgSamples;
}

@immutable
class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
}

@immutable
class EmergencyContact {
  const EmergencyContact({
    required this.name,
    this.photo,
    this.isConnected = false,
    this.notifiedAt,
  });

  final String name;
  final ImageProvider? photo;

  /// Whether this contact has linked the app and can receive live alerts.
  final bool isConnected;
  final DateTime? notifiedAt;
}

@immutable
class Responder {
  const Responder({
    required this.name,
    required this.certification,
    required this.unit,
    required this.role,
    this.photo,
  });

  final String name;
  final String certification;
  final String unit;
  final String role;
  final ImageProvider? photo;
}

enum DispatchStage { alertSent, enRoute, arrived }

@immutable
class Dispatch {
  const Dispatch({
    required this.responder,
    required this.stage,
    required this.eta,
    required this.distanceMeters,
    required this.route,
    required this.alertSentAt,
    this.waypoint,
    this.enRouteAt,
    this.arrivalAt,
  });

  final Responder responder;
  final DispatchStage stage;
  final Duration eta;
  final double distanceMeters;

  /// Remaining path, from the responder's vehicle to the patient. Must contain
  /// at least two points.
  final List<LatLng> route;
  final LatLng? waypoint;

  final DateTime alertSentAt;
  final DateTime? enRouteAt;

  /// Actual arrival once [stage] is [DispatchStage.arrived], otherwise the
  /// estimate.
  final DateTime? arrivalAt;

  LatLng get vehiclePosition => route.first;
  LatLng get destination => route.last;

  /// Used to project the dispatch forward as the responder travels, without
  /// the screens having to rebuild the whole object.
  Dispatch copyWith({
    DispatchStage? stage,
    Duration? eta,
    double? distanceMeters,
  }) {
    return Dispatch(
      responder: responder,
      stage: stage ?? this.stage,
      eta: eta ?? this.eta,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      route: route,
      waypoint: waypoint,
      alertSentAt: alertSentAt,
      enRouteAt: enRouteAt,
      arrivalAt: arrivalAt,
    );
  }
}
