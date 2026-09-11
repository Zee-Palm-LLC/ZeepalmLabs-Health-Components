import 'package:video_player/video_player.dart';

import '../screens/onboarding/onboarding_data.dart';

/// Shared, app-level preload for onboarding MP4s.
/// Controllers stay warm so page changes don't wait on decode.
class OnboardingVideoCache {
  OnboardingVideoCache._();

  static final OnboardingVideoCache instance = OnboardingVideoCache._();

  final Map<String, VideoPlayerController> _controllers = {};
  Future<void>? _preload;

  bool get isReady =>
      kOnboardingVideoAssets.every(_controllers.containsKey) &&
      _controllers.values.every((c) => c.value.isInitialized);

  VideoPlayerController? controllerFor(String asset) => _controllers[asset];

  /// Initialize every unique onboarding video in parallel.
  Future<void> preload() => _preload ??= _loadAll();

  Future<void> _loadAll() async {
    await Future.wait(
      kOnboardingVideoAssets.map(_loadOne),
      eagerError: false,
    );
  }

  Future<void> _loadOne(String asset) async {
    if (_controllers[asset]?.value.isInitialized ?? false) return;

    final controller = VideoPlayerController.asset(
      asset,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      // Decode first frame so the first paint isn't blank.
      await controller.seekTo(Duration.zero);
      await controller.play();
      await Future<void>.delayed(const Duration(milliseconds: 48));
      await controller.pause();
      await controller.seekTo(Duration.zero);
      _controllers[asset] = controller;
    } catch (_) {
      await controller.dispose();
      rethrow;
    }
  }

  Future<void> disposeAll() async {
    final pending = _preload;
    _preload = null;
    await pending;
    final values = _controllers.values.toList(growable: false);
    _controllers.clear();
    for (final c in values) {
      await c.dispose();
    }
  }
}

/// Unique video paths used across onboarding pages.
final kOnboardingVideoAssets =
    kOnboardingPages.map((p) => p.video).toSet().toList(growable: false);
