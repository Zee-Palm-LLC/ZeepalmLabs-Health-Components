import 'package:flutter/widgets.dart';

import '../../../../core/motion/page_value.dart';
import '../../../../core/theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.controller,
    required this.count,
    required this.onSelected,
  });

  final PageController controller;
  final int count;
  final ValueChanged<int> onSelected;

  static const double _dotSize = 7;
  static const double _pitch = 16;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.pageValue;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < count; index++)
              Semantics(
                button: true,
                selected: page.round() == index,
                label: 'Page ${index + 1} of $count',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(index),
                  child: SizedBox(
                    width: _pitch,
                    height: 24,
                    child: Center(
                      child: Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            AppColors.indicatorIdle,
                            AppColors.violet,
                            (1 - (page - index).abs()).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
