import 'package:fit_profile/core/motion/app_motion.dart';
import 'package:flutter/material.dart';

/// One controller staggers children — efficient on low-end devices.
/// Supports [Expanded]/[Flexible] by animating only their inner child.
class StaggerColumn extends StatefulWidget {
  const StaggerColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  State<StaggerColumn> createState() => _StaggerColumnState();
}

class _StaggerColumnState extends State<StaggerColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _wrapChild(int index, int total, Widget child) {
    Widget animated(Widget content) => _StaggeredChild(
          index: index,
          total: total,
          progress: _controller.value,
          child: content,
        );

    if (child is Expanded) {
      return Expanded(
        flex: child.flex,
        child: animated(
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: child.child,
          ),
        ),
      );
    }
    if (child is Spacer) {
      return Expanded(
        flex: child.flex,
        child: animated(const SizedBox.shrink()),
      );
    }
    if (child is Flexible) {
      return Flexible(
        flex: child.flex,
        fit: child.fit,
        child: animated(
          child.fit == FlexFit.tight
              ? SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: child.child,
                )
              : Align(
                  alignment: Alignment.center,
                  child: child.child,
                ),
        ),
      );
    }

    return animated(child);
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotionOf(context)) {
      return Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        children: widget.children,
      );
    }

    final count = widget.children.length;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisSize: widget.mainAxisSize,
          children: [
            for (var i = 0; i < count; i++)
              _wrapChild(i, count, widget.children[i]),
          ],
        );
      },
    );
  }
}

class _StaggeredChild extends StatelessWidget {
  const _StaggeredChild({
    required this.index,
    required this.total,
    required this.progress,
    required this.child,
  });

  final int index;
  final int total;
  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final slot = 1 / (total + 1);
    final start = index * slot * 0.85;
    final end = (start + 0.55).clamp(0.0, 1.0);

    final t = Curves.easeOutCubic.transform(
      ((progress - start) / (end - start)).clamp(0.0, 1.0),
    );

    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 14),
        child: Transform.scale(
          scale: 0.98 + (t * 0.02),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
