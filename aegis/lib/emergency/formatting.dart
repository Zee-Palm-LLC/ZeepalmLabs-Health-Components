import 'package:flutter/material.dart';

String formatLatitude(double value) =>
    '${value.abs().toStringAsFixed(4)}° ${value >= 0 ? 'N' : 'S'}';

String formatLongitude(double value) =>
    '${value.abs().toStringAsFixed(4)}° ${value >= 0 ? 'E' : 'W'}';

String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

/// Whole minutes, never below one so an imminent arrival doesn't read "0".
int etaMinutes(Duration eta) => eta.inSeconds <= 60 ? 1 : (eta.inSeconds / 60).round();

String formatEta(Duration eta) => '${etaMinutes(eta)} min';

String formatClockTime(BuildContext context, DateTime time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(time),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
