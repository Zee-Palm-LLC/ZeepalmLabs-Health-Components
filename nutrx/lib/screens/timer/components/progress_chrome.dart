import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../theme/nutrx_colors.dart';
import '../../../theme/nutrx_text.dart';
import 'math_motion.dart';

class ProgressHeader extends StatelessWidget implements PreferredSizeWidget {
  const ProgressHeader({super.key, this.onMore});

  final VoidCallback? onMore;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NutrxColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text('Progress', style: NutrxText.title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Material(
            color: NutrxColors.iconCircle,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onMore,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  LucideIcons.ellipsis,
                  size: 20,
                  color: NutrxColors.text,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ElasticSegmentTab extends StatefulWidget {
  const ElasticSegmentTab({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const labels = ['Daily', 'Calendar'];

  @override
  State<ElasticSegmentTab> createState() => _ElasticSegmentTabState();
}

class _ElasticSegmentTabState extends State<ElasticSegmentTab>
    with SingleTickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 0.8,
    stiffness: 180,
    damping: 11.5,
  );

  late final AnimationController _slide;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController.unbounded(vsync: this)
      ..value = widget.index.toDouble();
  }

  @override
  void didUpdateWidget(ElasticSegmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    _slide.animateWith(
      SpringSimulation(
        _spring,
        _slide.value,
        widget.index.toDouble(),
        _slide.velocity,
      ),
    );
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const labels = ElasticSegmentTab.labels;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: NutrxColors.card,
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedBuilder(
                animation: _slide,
                builder: (context, child) {
                  // Hyperbolic squash — stretch feels physical, never linear.
                  final squash =
                      MathMotion.tanh(_slide.velocity.abs() * 0.09);
                  return Positioned(
                    left: slot * _slide.value,
                    top: 0,
                    bottom: 0,
                    width: slot,
                    child: Transform.scale(
                      scaleX: 1 + squash * 0.22,
                      scaleY: 1 - squash * 0.12,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [NutrxColors.yellowSoft, NutrxColors.yellow],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: NutrxColors.yellow.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onChanged(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: NutrxText.tab.copyWith(
                              color: widget.index == i
                                  ? NutrxColors.onYellow
                                  : NutrxColors.textMuted,
                            ),
                            child: Text(labels[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
