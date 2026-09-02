import 'package:flutter/material.dart';
import 'package:healthscan_ai/core/motion/app_motion.dart';

class DashboardMotion extends InheritedWidget {
  const DashboardMotion({
    super.key,
    required this.intro,
    required super.child,
  });

  final Animation<double> intro;

  static DashboardMotion? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DashboardMotion>();
  }

  static Animation<double> introOf(BuildContext context) {
    return maybeOf(context)?.intro ?? const AlwaysStoppedAnimation(1);
  }

  /// Maps global [intro] into 0→1 between [start] and [end] (0–1 timeline).
  double interval(double start, double end) {
    final t = intro.value;
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }

  double curvedInterval(double start, double end) {
    return Curves.easeOutCubic.transform(interval(start, end));
  }

  @override
  bool updateShouldNotify(DashboardMotion oldWidget) =>
      oldWidget.intro != intro;
}

class DashboardMotionScope extends StatefulWidget {
  const DashboardMotionScope({super.key, required this.child});

  final Widget child;

  @override
  State<DashboardMotionScope> createState() => _DashboardMotionScopeState();
}

class _DashboardMotionScopeState extends State<DashboardMotionScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _intro;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _intro = CurvedAnimation(parent: _ctrl, curve: AppMotion.curve);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disable = AppMotion.reduceMotionOf(context);
    if (disable && _ctrl.value == 0) {
      _ctrl.value = 1;
    }

    return DashboardMotion(
      intro: _intro,
      child: widget.child,
    );
  }
}

/// Lightweight entrance — one listenable, transform only.
class MotionEntrance extends StatelessWidget {
  const MotionEntrance({
    super.key,
    required this.index,
    required this.child,
    this.slide = 14,
  });

  final int index;
  final Widget child;
  final double slide;

  @override
  Widget build(BuildContext context) {
    final motion = DashboardMotion.maybeOf(context);
    if (motion == null) return child;

    return AnimatedBuilder(
      animation: motion.intro,
      builder: (context, child) {
        final start = 0.04 + index * 0.07;
        final t = motion.curvedInterval(start, start + 0.24);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, slide * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Drives a numeric / progress animation from the shared intro timeline.
class MotionProgress extends StatelessWidget {
  const MotionProgress({
    super.key,
    required this.start,
    required this.end,
    required this.builder,
  });

  final double start;
  final double end;
  final Widget Function(BuildContext context, double progress) builder;

  @override
  Widget build(BuildContext context) {
    final motion = DashboardMotion.maybeOf(context);
    if (motion == null) return builder(context, 1);

    return AnimatedBuilder(
      animation: motion.intro,
      builder: (context, _) {
        return builder(context, motion.curvedInterval(start, end));
      },
    );
  }
}
