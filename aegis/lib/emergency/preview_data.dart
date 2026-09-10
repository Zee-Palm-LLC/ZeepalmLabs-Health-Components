import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import 'models.dart';

/// Fixture values matching the design reference. Stand-ins until the
/// wearable, location and dispatch sources exist; not real readings.
abstract final class PreviewData {
  static final _alertSentAt = DateTime(2026, 9, 10, 9, 41);

  /// Placeholder portraits, so the contact rows and the responder card show
  /// faces instead of initials during review.
  ///
  /// Swap [_portrait] for the real photo source — the widgets only need an
  /// [ImageProvider], so a bundled [AssetImage] or a signed URL drops straight
  /// in. Anything that fails to load falls back to the initials tile.
  static ImageProvider _portrait(int id) =>
      NetworkImage('https://i.pravatar.cc/240?img=$id');

  static const elevatedHeartRate = HeartRateReading(
    bpm: 118,
    status: HeartRateStatus.elevated,
    recentBpm: [
      96, 98, 97, 101, 99, 103, 101, 100, 104, 108, 106, 103,
      105, 112, 116, 110, 107, 109, 113, 118, 115, 117, 116, 118,
    ],
  );

  static final stableHeartRate = HeartRateReading(
    bpm: 76,
    status: HeartRateStatus.normal,
    ecgSamples: _ecgStrip(beats: 7),
  );

  static const location = LocationFix(
    latitude: 33.6844,
    longitude: 73.0479,
    accuracyMeters: 5,
  );

  static final contacts = [
    EmergencyContact(
      name: 'Sarah',
      photo: _portrait(47),
      isConnected: true,
    ),
    EmergencyContact(
      name: 'Ahmed',
      photo: _portrait(12),
      isConnected: true,
    ),
    EmergencyContact(
      name: 'Mom',
      photo: _portrait(32),
      isConnected: true,
    ),
    EmergencyContact(
      name: 'Raza',
      photo: _portrait(59),
      isConnected: true,
    ),
    EmergencyContact(name: 'Hina', photo: _portrait(26)),
  ];

  static final notifiedContacts = [
    EmergencyContact(
      name: 'Sarah Khan',
      photo: _portrait(47),
      isConnected: true,
      notifiedAt: DateTime(2026, 9, 10, 9, 46),
    ),
    EmergencyContact(
      name: 'Ahmed Raza',
      photo: _portrait(12),
      isConnected: true,
      notifiedAt: DateTime(2026, 9, 10, 9, 46),
    ),
  ];

  static final dispatch = Dispatch(
    responder: Responder(
      name: 'Jordan Diaz',
      certification: 'EMT',
      unit: 'Unit 7A-314',
      role: 'Paramedic',
      photo: _portrait(68),
    ),
    stage: DispatchStage.enRoute,
    eta: const Duration(minutes: 4),
    distanceMeters: 1800,
    route: const [
      LatLng(33.6745, 73.0360),
      LatLng(33.6760, 73.0386),
      LatLng(33.6771, 73.0405),
      LatLng(33.6778, 73.0421),
      LatLng(33.6791, 73.0431),
      LatLng(33.6811, 73.0441),
      LatLng(33.6828, 73.0459),
      LatLng(33.6844, 73.0479),
    ],
    waypoint: const LatLng(33.6778, 73.0421),
    alertSentAt: _alertSentAt,
    enRouteAt: DateTime(2026, 9, 10, 9, 42),
    arrivalAt: DateTime(2026, 9, 10, 9, 46),
  );

  static List<double> _ecgStrip({required int beats}) {
    const beat = <double>[
      0, 0, 0.02, 0.1, 0.16, 0.1, 0, 0, -0.08, 0.95, -0.42, 0,
      0.04, 0.12, 0.2, 0.18, 0.08, 0, 0, 0, 0.03, -0.02, 0.02, 0,
    ];
    return [for (var i = 0; i < beats; i++) ...beat];
  }
}
