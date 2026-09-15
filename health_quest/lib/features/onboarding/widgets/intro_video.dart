import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import 'hero_stage.dart';

/// The supplied onboarding clip, played once behind the interface.
///
/// It is the real thing, not a frame sequence: the character drops out of the
/// sky, lands on the rock and stands up. The clip is trimmed to end just
/// before its own built-in stat labels appear, because those are drawn here
/// as live badges instead.
///
/// As it finishes, the frame is transformed toward the still composition's
/// registration (see [heroFrameRect]) while it cross-fades, so the character
/// does not change size under the dissolve.
///
/// Everything about it is optional. If the platform will not decode it - an
/// unsupported browser, a locked-down device - [onFailed] fires and the
/// screen falls back to the still composition with no visible difference
/// other than a missing intro.
class IntroVideo extends StatefulWidget {
  const IntroVideo({
    super.key,
    required this.onProgress,
    required this.onFailed,
    this.blend = 0,
    this.opacity = 1,
  });

  /// Normalised playback position, 0..1, every frame.
  final ValueChanged<double> onProgress;
  final VoidCallback onFailed;

  /// 0 covers the screen, 1 registers with the still composition.
  final double blend;
  final double opacity;

  @override
  State<IntroVideo> createState() => _IntroVideoState();
}

class _IntroVideoState extends State<IntroVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = VideoPlayerController.asset('assets/video/intro.mp4');
    try {
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      await c.setVolume(0);
      await c.setLooping(false);
      c.addListener(_onTick);
      await c.play();
      setState(() {
        _controller = c;
        _ready = true;
      });
    } catch (_) {
      await c.dispose();
      if (mounted) widget.onFailed();
    }
  }

  void _onTick() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.hasError) {
      widget.onFailed();
      return;
    }
    final total = c.value.duration.inMilliseconds;
    if (total <= 0) return;
    widget.onProgress(
      (c.value.position.inMilliseconds / total).clamp(0.0, 1.0),
    );
  }

  @override
  void dispose() {
    _controller
      ?..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (!_ready || c == null || widget.opacity <= 0) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final size = Size(box.maxWidth, box.maxHeight);
          final rect = heroFrameRect(size, widget.blend);
          return ClipRect(
            child: Opacity(
              opacity: widget.opacity.clamp(0.0, 1.0),
              child: Stack(
                children: <Widget>[
                  Positioned.fromRect(
                    rect: rect,
                    child: VideoPlayer(c),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
