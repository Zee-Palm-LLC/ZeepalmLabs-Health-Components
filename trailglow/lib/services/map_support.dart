import 'package:flutter/foundation.dart';

import '../app/config/app_config.dart';

class MapSupport {
  MapSupport._();

  static bool? _override;

  static final ValueNotifier<bool> mapboxFailed = ValueNotifier<bool>(false);

  static set override(bool? value) => _override = value;

  static bool get platformSupportsMapbox =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get usesMapbox =>
      _override ?? (platformSupportsMapbox && AppConfig.hasMapboxToken);

  static String get fallbackReason {
    if (!platformSupportsMapbox) {
      return 'The Mapbox SDK runs on iOS and Android. '
          'This preview uses the built-in vector renderer.';
    }
    if (!AppConfig.hasMapboxToken) {
      return 'No MAPBOX_ACCESS_TOKEN found. ${AppConfig.tokenHelp}';
    }
    return 'The Mapbox style could not be reached. Showing the offline map.';
  }
}
