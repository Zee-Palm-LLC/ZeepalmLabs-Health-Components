import 'package:vital_heart/core/motion/app_motion.dart';
import 'package:flutter/material.dart';

class StaggerColumn extends StatefulWidget {
  const StaggerColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  State<StaggerColumn> createState() => _StaggerColumnState();
}

class _StaggerColumnState extends State<StaggerColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.slow);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotionOf(context)) {
      return Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _StaggeredChild(
                index: i,
                total: widget.children.length,
                progress: _controller.value,
                child: widget.children[i],
              ),
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
        offset: Offset(0, (1 - t) * 12),
        child: child,
      ),
    );
  }
}
