import 'dart:ui' show DisplayFeatureType;

import 'package:flutter/widgets.dart';

/// Where the screen splits. On a book-style foldable the split is the real
/// hinge the OS reports; on a tablet or wide window it is a centred gutter.
class Fold {
  const Fold._(this.spanned, this.seam);

  /// Wide enough (or physically unfolded) to show Today and Trends side by side.
  final bool spanned;

  /// The dead zone between the panes, in logical pixels. Content keeps
  /// [Fold.clearance] away from it on both sides.
  final Rect seam;

  static const clearance = 24.0;
  static const virtualSeam = 40.0;
  static const minSpread = 720.0;

  static Fold of(BuildContext context, Size size) {
    final media = MediaQuery.of(context);
    for (final f in media.displayFeatures) {
      final vertical = f.bounds.height >= f.bounds.width;
      final splits = f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold;
      if (splits && vertical && f.bounds.left > 0 && f.bounds.right < size.width) {
        return Fold._(true, f.bounds);
      }
    }
    if (size.width >= minSpread) {
      final left = (size.width - virtualSeam) / 2;
      return Fold._(true, Rect.fromLTWH(left, 0, virtualSeam, size.height));
    }
    return Fold._(false, Rect.zero);
  }
}
