import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fills its parent with a cover-fit asset photo, decoded at display size, and
/// falls back to a neutral tile when the asset is missing.
class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key,
    required this.asset,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.circular = false,
  });

  final String asset;
  final BorderRadius borderRadius;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final image = LayoutBuilder(
      builder: (context, constraints) {
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        // Cover-fit may crop either axis, so decode against the longer side, with
        // headroom because the artboard scales up slightly on large phones.
        final cacheWidth = (constraints.biggest.longestSide * pixelRatio * 1.25).round();
        return Image.asset(
          asset,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _Placeholder(size: constraints.biggest),
        );
      },
    );

    return circular ? ClipOval(child: image) : ClipRRect(borderRadius: borderRadius, child: image);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.photoPlaceholder,
      child: Center(
        child: Icon(
          Icons.landscape_rounded,
          size: size.shortestSide * 0.4,
          color: AppColors.surface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
