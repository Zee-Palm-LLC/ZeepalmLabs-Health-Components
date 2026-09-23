import 'dart:convert';

class AppConfig {
  AppConfig._();

  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );

  static const String mapboxStyleUri = String.fromEnvironment(
    'MAPBOX_STYLE_URI',
    defaultValue: 'mapbox://styles/mapbox/standard',
  );

  static String get nightStyleJson => jsonEncode(<String, Object?>{
    'version': 8,
    'imports': <Object>[
      <String, Object?>{
        'id': 'basemap',
        'url': mapboxStyleUri,
        'config': <String, Object?>{
          'lightPreset': 'night',
          'theme': 'default',
          'show3dObjects': true,
          'showPointOfInterestLabels': false,
          'showTransitLabels': false,
          'showRoadLabels': false,
          'showPlaceLabels': false,
          'showPedestrianRoads': true,
        },
      },
    ],
    'sources': <String, Object?>{},
    'layers': <Object>[],
  });

  static bool get hasMapboxToken =>
      mapboxAccessToken.trim().startsWith('pk.') &&
      mapboxAccessToken.trim().length > 40;

  static const String tokenHelp =
      'Pass a public Mapbox token at build time:\n'
      'flutter run --dart-define-from-file=mapbox.json';
}
