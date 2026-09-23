import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'services/map_support.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (MapSupport.platformSupportsMapbox && AppConfig.hasMapboxToken) {
    MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken.trim());
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF03050A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(const TrailglowApp());
}
