import 'package:flutter/material.dart';

/// Warms the image cache for a set of sources the moment this subtree gets a
/// build context, so photography is already decoded by the time the user
/// reaches the screen that shows it.
class ImageWarmup extends StatefulWidget {
  const ImageWarmup({super.key, required this.sources, required this.child});

  final List<String> sources;
  final Widget child;

  @override
  State<ImageWarmup> createState() => _ImageWarmupState();
}

class _ImageWarmupState extends State<ImageWarmup> {
  bool _warmed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_warmed) return;
    _warmed = true;

    for (final source in widget.sources) {
      final provider = source.startsWith('http')
          ? NetworkImage(source) as ImageProvider
          : AssetImage(source);
      // A failed prefetch is not worth surfacing: AppImage still shows its
      // gradient and retries when the widget itself builds.
      precacheImage(provider, context, onError: (_, _) {});
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
