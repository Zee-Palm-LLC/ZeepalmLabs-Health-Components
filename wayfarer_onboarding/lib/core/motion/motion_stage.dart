import 'package:flutter/widgets.dart';

typedef MotionStageBuilder = Widget Function(
  BuildContext context,
  Animation<double> intro,
  Animation<double> ambient,
);

/// Owns a one-shot intro timeline that starts when the stage becomes active and
/// a looping ambient timeline that only runs while it is active.
class MotionStage extends StatefulWidget {
  const MotionStage({
    super.key,
    required this.active,
    required this.introDuration,
    required this.builder,
    this.ambientPeriod = const Duration(seconds: 6),
  });

  final bool active;
  final Duration introDuration;
  final Duration ambientPeriod;
  final MotionStageBuilder builder;

  @override
  State<MotionStage> createState() => _MotionStageState();
}

class _MotionStageState extends State<MotionStage> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: widget.introDuration,
  );
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: widget.ambientPeriod,
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(covariant MotionStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  void _sync() {
    if (_reduceMotion) {
      _intro.value = 1;
      _ambient.stop();
      return;
    }
    if (!widget.active) {
      _ambient.stop();
      return;
    }
    if (_intro.isDismissed) _intro.forward();
    if (!_ambient.isAnimating) _ambient.repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _intro, _ambient);
}
