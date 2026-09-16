import 'package:flutter/widgets.dart';

import '../../../../core/brand.dart';
import '../../../../core/painting/brand_mark_painter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// The wordmark with its palm perched on the shoulder of the first letter, as
/// in the design: the mark overlaps the "W" rather than sitting beside it.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  static const double _markSize = 22;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text.rich(
              TextSpan(
                text: AppBrand.name,
                style: AppTypography.brand,
                children: [TextSpan(text: '.', style: AppTypography.brand.copyWith(color: AppColors.orange))],
              ),
            ),
          ),
          const Positioned(
            left: -10,
            top: -11,
            width: _markSize,
            height: _markSize,
            child: CustomPaint(painter: BrandMarkPainter()),
          ),
        ],
      ),
    );
  }
}
