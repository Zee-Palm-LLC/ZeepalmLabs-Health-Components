import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Scale-on-press driven by a real spring, not a tween.
///
/// Pressing pulls the child down to [pressedScale] quickly; releasing lets a
/// spring carry it back with one small overshoot, so a fast tap still reads
/// as a physical push rather than a flicker. The spring is simulated on a
/// [Ticker], so a release mid-press continues from the current velocity.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.94,
    this.haptic = true,
    this.enabled = true,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final bool haptic;
  final bool enabled;
  final HitTestBehavior hitTestBehavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  SpringSimulation? _sim;
  Duration _simStart = Duration.zero;
  double _scale = 1;
  double _velocity = 0;
  bool _down = false;

  static const SpringDescription _pressSpring =
      SpringDescription(mass: 1, stiffness: 900, damping: 60);
  static const SpringDescription _releaseSpring =
      SpringDescription(mass: 1, stiffness: 320, damping: 16);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _animateTo(double target, SpringDescription spring) {
    _sim = SpringSimulation(spring, _scale, target, _velocity);
    _simStart = Duration.zero;
    if (!_ticker.isActive) _ticker.start();
  }

  void _tick(Duration elapsed) {
    final sim = _sim;
    if (sim == null) {
      _ticker.stop();
      return;
    }
    if (_simStart == Duration.zero) _simStart = elapsed;
    final t = (elapsed - _simStart).inMicroseconds / 1e6;
    setState(() {
      _scale = sim.x(t);
      _velocity = sim.dx(t);
    });
    if (sim.isDone(t)) {
      _scale = sim.x(t);
      _velocity = 0;
      _sim = null;
      _ticker.stop();
    }
  }

  void _pressDown() {
    if (!widget.enabled || _down) return;
    _down = true;
    _animateTo(widget.pressedScale, _pressSpring);
  }

  void _pressUp() {
    if (!_down) return;
    _down = false;
    _animateTo(1, _releaseSpring);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.hitTestBehavior,
      onTapDown: (_) => _pressDown(),
      onTapUp: (_) => _pressUp(),
      onTapCancel: _pressUp,
      onTap: widget.enabled
          ? () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap?.call();
            }
          : null,
      onLongPress: widget.onLongPress,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// A press that reports its state continuously, for hold-to-talk surfaces.
class HoldDetector extends StatelessWidget {
  const HoldDetector({
    super.key,
    required this.child,
    required this.onChanged,
    this.onTap,
  });

  final Widget child;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (PointerDownEvent _) => onChanged(true),
      onPointerUp: (PointerUpEvent _) => onChanged(false),
      onPointerCancel: (PointerCancelEvent _) => onChanged(false),
      child: GestureDetector(onTap: onTap, child: child),
    );
  }
}
