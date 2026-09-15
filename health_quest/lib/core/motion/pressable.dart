import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Scale-on-press driven by a real spring rather than a tween.
///
/// Pressing pulls the child down fast and stiff; releasing hands the current
/// velocity to a looser spring, so it comes back with one small overshoot.
/// A tween cannot do that: release halfway through a press and a tween
/// restarts from a standstill, which is exactly the moment a button stops
/// feeling physical.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.94,
    this.haptic = true,
    this.enabled = true,
    this.onPressedChanged,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;
  final bool enabled;

  /// Reports the raw down/up state, for surfaces that light up while held.
  final ValueChanged<bool>? onPressedChanged;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  /// Built in initState, not lazily.
  ///
  /// A `late final` initialiser here would defer createTicker to first use -
  /// and for a button nobody ever pressed, first use is `dispose`, where
  /// createTicker's lookup of the TickerMode ancestor is illegal. It throws
  /// in debug and does pointless work in release.
  late final Ticker _ticker;

  SpringSimulation? _sim;
  Duration _origin = Duration.zero;
  double _scale = 1;
  double _velocity = 0;
  bool _down = false;

  static const SpringDescription _push =
      SpringDescription(mass: 1, stiffness: 900, damping: 60);
  static const SpringDescription _release =
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

  void _springTo(double target, SpringDescription spring) {
    _sim = SpringSimulation(spring, _scale, target, _velocity);
    _origin = Duration.zero;
    if (!_ticker.isActive) _ticker.start();
  }

  void _tick(Duration elapsed) {
    final sim = _sim;
    if (sim == null) {
      _ticker.stop();
      return;
    }
    if (_origin == Duration.zero) _origin = elapsed;
    final t = (elapsed - _origin).inMicroseconds / 1e6;
    setState(() {
      _scale = sim.x(t);
      _velocity = sim.dx(t);
    });
    if (sim.isDone(t)) {
      _velocity = 0;
      _sim = null;
      _ticker.stop();
    }
  }

  void _setDown(bool down) {
    if (_down == down || !widget.enabled) return;
    _down = down;
    widget.onPressedChanged?.call(down);
    _springTo(down ? widget.pressedScale : 1, down ? _push : _release);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      onTap: widget.enabled
          ? () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap?.call();
            }
          : null,
      child: Transform.scale(scale: _scale, child: widget.child),
    );
  }
}
