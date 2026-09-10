import 'package:flutter/cupertino.dart';

import '../../theme/aegis_theme.dart';
import '../../theme/motion.dart';
import '../formatting.dart';
import '../models.dart';

/// Alert sent, en route, arrived.
///
/// The connector between two steps fills rather than switching colour, so the
/// stepper reads as time passing. While the responder is still travelling the
/// last connector fills in step with [enRouteProgress].
class DispatchProgress extends StatelessWidget {
  const DispatchProgress({
    super.key,
    required this.dispatch,
    this.enRouteProgress = 0,
  });

  static const double _stepWidth = 64;
  static const double _nodeSize = 22;

  final Dispatch dispatch;

  /// How far along the journey the responder is, 0..1. Only consulted while
  /// the stage is [DispatchStage.enRoute].
  final double enRouteProgress;

  @override
  Widget build(BuildContext context) {
    final current = dispatch.stage.index;
    final isComplete = dispatch.stage == DispatchStage.arrived;
    final steps = [
      ('Alert sent', dispatch.alertSentAt),
      ('En route', dispatch.enRouteAt),
      ('Arrived', dispatch.arrivalAt),
    ];

    return Stack(
      children: [
        Positioned(
          left: _stepWidth / 2,
          right: _stepWidth / 2,
          top: _nodeSize / 2 - 1,
          child: Row(
            children: [
              for (var i = 1; i < steps.length; i++)
                Expanded(
                  child: _Connector(fill: _fillFor(i, current)),
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final (index, (label, time)) in steps.indexed)
              _Step(
                label: label,
                time: time,
                state: index < current || isComplete
                    ? _StepState.done
                    : index == current
                        ? _StepState.current
                        : _StepState.pending,
              ),
          ],
        ),
      ],
    );
  }

  /// Connector [i] joins step i-1 to step i.
  double _fillFor(int i, int current) {
    if (i <= current) return 1;
    if (i == current + 1) return enRouteProgress.clamp(0.0, 1.0);
    return 0;
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.fill});

  final double fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: AegisColors.inactive),
          ),
          // Animated so a stage change eases across rather than snapping, and
          // so a travel-driven fill stays smooth between frames.
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fill),
              duration: AegisMotion.medium,
              curve: AegisMotion.emphasized,
              builder: (context, value, child) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: child,
              ),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AegisColors.ember, AegisColors.amberBright],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState {
  done('completed'),
  current('in progress'),
  pending('upcoming');

  const _StepState(this.description);

  final String description;
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.time, required this.state});

  final String label;
  final DateTime? time;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final time = this.time;

    return Semantics(
      label: '$label, ${state.description}',
      excludeSemantics: true,
      child: SizedBox(
        width: DispatchProgress._stepWidth,
        child: Column(
          children: [
            SizedBox.square(
              dimension: DispatchProgress._nodeSize,
              child: Center(
                child: AnimatedSwitcher(
                  duration: AegisMotion.medium,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: AegisMotion.overshoot,
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(state),
                    child: _node(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedDefaultTextStyle(
              duration: AegisMotion.medium,
              style: TextStyle(
                fontFamily: AegisFonts.sans,
                fontSize: 13,
                color: switch (state) {
                  _StepState.current => AegisColors.amber,
                  _StepState.done => AegisColors.textSecondary,
                  _StepState.pending => AegisColors.textMuted,
                },
              ),
              child: Text(label, softWrap: false),
            ),
            const SizedBox(height: 2),
            Text(
              time == null ? '' : formatClockTime(context, time),
              softWrap: false,
              style: const TextStyle(
                fontSize: 11.5,
                color: AegisColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _node() {
    return switch (state) {
      _StepState.done => Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AegisColors.amber,
          ),
          child: const Icon(
            CupertinoIcons.checkmark,
            size: 11,
            color: AegisColors.background,
          ),
        ),
      _StepState.current => const _PulsingNode(),
      _StepState.pending => Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF101921),
            border: Border.all(color: AegisColors.inactive, width: 1.5),
          ),
        ),
    };
  }
}

/// The in-progress node, breathing so the eye lands on where things stand.
class _PulsingNode extends StatefulWidget {
  const _PulsingNode();

  @override
  State<_PulsingNode> createState() => _PulsingNodeState();
}

class _PulsingNodeState extends State<_PulsingNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
    value: 0.5,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          width: 20,
          height: 20,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AegisColors.background,
            border: Border.all(color: AegisColors.amber, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AegisColors.amber.withValues(alpha: 0.25 + 0.4 * t),
                blurRadius: 8 + 8 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: const DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AegisColors.amberBright,
        ),
      ),
    );
  }
}
