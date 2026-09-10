import 'package:flutter/material.dart';

/// Renders photography from either a bundled asset or a remote URL.
///
/// While a remote image is in flight — and permanently if it fails — the widget
/// paints the tonal gradient passed in [fallback], so every composition keeps
/// its intended colour weight instead of collapsing to a grey box.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String source;
  final List<Color> fallback;
  final BoxFit fit;
  final Alignment alignment;

  bool get _isRemote => source.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: fallback,
        ),
      ),
      child: const SizedBox.expand(),
    );

    if (!_isRemote) {
      return Image.asset(
        source,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, _, _) => placeholder,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        placeholder,
        Image.network(
          source,
          fit: fit,
          alignment: alignment,
          errorBuilder: (context, _, _) => const SizedBox.shrink(),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOut,
              child: child,
            );
          },
        ),
      ],
    );
  }
}
