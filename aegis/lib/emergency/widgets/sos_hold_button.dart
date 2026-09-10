import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/aegis_theme.dart';
import '../../theme/motion.dart';
import 'pulse_line.dart';

class SosHoldButton extends StatefulWidget {
  const SosHoldButton({
    super.key,
    required this.onActivated,
    this.holdDuration = const Duration(seconds: 3),
    this.size = defaultSize,
  });

  static const double defaultSize = 284;

  final VoidCallback onActivated;
  final Duration holdDuration;

  /// Outer diameter, including the rings. The face scales with it.
  final double size;

  @override
  State<SosHoldButton> createState() => _SosHoldButtonState();
}

class _SosHoldButtonState extends State<SosHoldButton>
    with TickerProviderStateMixin {
  /// Fill of the hold ring. Drives activation.
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
    reverseDuration: const Duration(milliseconds: 420),
  )
    ..addStatusListener(_handleHoldStatus)
    ..addListener(_handleHoldTick);

  /// Squeeze under the thumb. Separate from [_hold] so releasing after the
  /// alert has fired still springs back.
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 320),
  );

  /// Rings leaving the rim on each touch.
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  /// One-shot flare as the alert goes out.
  late final AnimationController _flare = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  /// Idle breath. Decorative, so reduced motion leaves it parked mid-swell.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: AegisMotion.breath,
    value: 0.5,
  );

  bool _activated = false;
  bool _holding = false;
  int _secondsLeft = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _breath.stop();
      _breath.value = 0.5;
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SosHoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hold.duration = widget.holdDuration;
  }

  @override
  void dispose() {
    _hold.dispose();
    _press.dispose();
    _ripple.dispose();
    _flare.dispose();
    _breath.dispose();
    super.dispose();
  }

  /// Counts the hold down on the face and ticks once per second under the
  /// thumb, so the user can feel how much longer to wait.
  void _handleHoldTick() {
    if (!_holding) return;
    final total = widget.holdDuration.inMilliseconds;
    final remaining = (total * (1 - _hold.value) / 1000).ceil();
    if (remaining == _secondsLeft) return;

    final counting = remaining < _secondsLeft;
    setState(() => _secondsLeft = remaining);
    if (counting && remaining > 0) HapticFeedback.selectionClick();
  }

  void _handleHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_activated) {
      _activated = true;
      _activate();
    } else if (status == AnimationStatus.dismissed) {
      _activated = false;
    }
  }

  void _activate() {
    HapticFeedback.heavyImpact();
    _flare.forward(from: 0);
    widget.onActivated();
  }

  void _startHold() {
    if (_activated) return;
    HapticFeedback.lightImpact();
    _press.forward();
    _ripple.forward(from: 0);
    _hold.forward();
    setState(() {
      _holding = true;
      _secondsLeft = widget.holdDuration.inSeconds;
    });
  }

  void _endHold() {
    _press.reverse();
    _hold.reverse();
    setState(() => _holding = false);
  }

  @override
  Widget build(BuildContext context) {
    final seconds = widget.holdDuration.inSeconds;

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SosRingPainter(
                  hold: _hold,
                  press: _press,
                  ripple: _ripple,
                  flare: _flare,
                  breath: _breath,
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'SOS',
            hint: 'Press and hold for $seconds seconds '
                'to send an emergency alert',
            onLongPress: _activate,
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _startHold(),
              onTapUp: (_) => _endHold(),
              onTapCancel: _endHold,
              child: AnimatedBuilder(
                animation: Listenable.merge([_press, _breath, _flare]),
                builder: (context, child) => Transform.scale(
                  scale: _faceScale,
                  child: child,
                ),
                child: _SosFace(
                  diameter: widget.size * 0.616,
                  holding: _holding,
                  secondsLeft: _secondsLeft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _faceScale {
    final squeeze = 1 - 0.055 * _press.value;
    final breath = 1 + 0.014 * (_breath.value - 0.5) * 2;
    // Quick swell then settle, rather than the flare's own flat decay.
    final flare = _flare.value;
    final pop = flare == 0 || flare == 1
        ? 1.0
        : 1 + 0.09 * math.sin(flare * math.pi) * (1 - flare * 0.4);
    return squeeze * breath * pop;
  }
}

class _SosFace extends StatelessWidget {
  const _SosFace({
    required this.diameter,
    required this.holding,
    required this.secondsLeft,
  });

  final double diameter;
  final bool holding;
  final int secondsLeft;

  static const _pulseGlyph = <double>[
    0, 0, 0, 0.18, 0, -0.12, 1, -0.75, 0.28, 0, 0, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final counting = holding && secondsLeft > 0;

    return AnimatedContainer(
      duration: AegisMotion.fast,
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF1C1110),
            Color(0xFF2E1512),
            Color(0xFF8E2619),
            Color(0xFFE0402A),
          ],
          stops: [0, 0.5, 0.86, 1],
        ),
        border: Border.all(
          color: holding ? const Color(0xFFFFB199) : const Color(0xFFFF8468),
          width: holding ? 2.2 : 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: AegisColors.alert.withValues(alpha: holding ? 0.85 : 0.6),
            blurRadius: holding ? 52 : 34,
            spreadRadius: holding ? 3 : 1,
          ),
          BoxShadow(
            color: AegisColors.alert.withValues(alpha: 0.25),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: diameter * 0.194,
            height: diameter * 0.103,
            child: const PulseLine(
              samples: _pulseGlyph,
              color: AegisColors.alertText,
            ),
          ),
          SizedBox(height: diameter * 0.034),
          Text(
            'SOS',
            style: TextStyle(
              fontSize: diameter * 0.229,
              height: 1.05,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AegisColors.textPrimary,
            ),
          ),
          SizedBox(height: diameter * 0.034),
          SizedBox(
            height: diameter * 0.1,
            child: AnimatedSwitcher(
              duration: AegisMotion.fast,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Text(
                counting ? '$secondsLeft' : 'HOLD',
                key: ValueKey(counting ? secondsLeft : -1),
                style: TextStyle(
                  fontSize: diameter * (counting ? 0.094 : 0.074),
                  height: 1.15,
                  fontWeight: counting ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: counting ? 0 : 1.1,
                  color: const Color(0xD1F4F6F7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SosRingPainter extends CustomPainter {
  _SosRingPainter({
    required this.hold,
    required this.press,
    required this.ripple,
    required this.flare,
    required this.breath,
  }) : super(
          repaint: Listenable.merge([hold, press, ripple, flare, breath]),
        );

  final Animation<double> hold;
  final Animation<double> press;
  final Animation<double> ripple;
  final Animation<double> flare;
  final Animation<double> breath;

  static const _startAngle = -math.pi / 2;
  static const _dashedSweep = math.pi * 1.5;
  static const _dashLength = 6.0;
  static const _dashGap = 5.0;

  Size? _cachedSize;
  Path? _cachedDashes;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final ring = Rect.fromCircle(center: center, radius: radius);
    final t = hold.value;
    final breathe = (breath.value - 0.5) * 2; // -1 .. 1

    _paintHalo(canvas, center, radius, breathe);
    _paintRipples(canvas, center, radius);
    _paintGuides(canvas, center, radius, breathe);
    canvas.drawPath(_dashes(size, ring), _dashPaint(ring));
    if (t > 0) _paintProgress(canvas, ring, t);
    _paintHead(canvas, center, radius, t);
    if (flare.value > 0) _paintFlare(canvas, center, radius);
  }

  /// The slow swell behind the face that keeps the idle screen alive.
  void _paintHalo(
    Canvas canvas,
    Offset center,
    double radius,
    double breathe,
  ) {
    final span = radius * 0.62 * (1 + 0.05 * breathe + 0.12 * press.value);
    canvas.drawCircle(
      center,
      span,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AegisColors.alert.withValues(alpha: 0.2 + 0.06 * breathe),
            AegisColors.alert.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: span)),
    );
  }

  /// Two rings per touch, the second trailing the first.
  void _paintRipples(Canvas canvas, Offset center, double radius) {
    if (ripple.value == 0 || ripple.value == 1) return;

    for (final delay in const [0.0, 0.22]) {
      final t = (ripple.value - delay) / (1 - delay);
      if (t <= 0 || t >= 1) continue;
      final eased = Curves.easeOutCubic.transform(t);
      canvas.drawCircle(
        center,
        radius * (0.62 + 0.42 * eased),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * (1 - eased) + 0.4
          ..color =
              AegisColors.amberBright.withValues(alpha: 0.45 * (1 - eased)),
      );
    }
  }

  void _paintGuides(
    Canvas canvas,
    Offset center,
    double radius,
    double breathe,
  ) {
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas
      ..drawCircle(
        center,
        radius * (0.86 + 0.01 * breathe),
        hairline..color = AegisColors.alert.withValues(alpha: 0.1),
      )
      ..drawCircle(
        center,
        radius * (0.77 + 0.015 * breathe),
        hairline..color = AegisColors.alert.withValues(alpha: 0.16),
      )
      ..drawCircle(
        center,
        radius,
        hairline
          ..color = AegisColors.amber
              .withValues(alpha: 0.14 + 0.16 * press.value),
      );
  }

  Paint _dashPaint(Rect ring) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round
    ..shader = const SweepGradient(
      colors: [
        AegisColors.amberBright,
        AegisColors.amber,
        AegisColors.ember,
        AegisColors.ember,
        AegisColors.amberBright,
      ],
      stops: [0, 0.3, 0.55, 0.75, 1],
      transform: GradientRotation(_startAngle),
    ).createShader(ring);

  void _paintProgress(Canvas canvas, Rect ring, double t) {
    final sweep = math.pi * 2 * t;
    canvas
      ..drawArc(
        ring,
        _startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 + 3 * t
          ..strokeCap = StrokeCap.round
          ..color = AegisColors.amber.withValues(alpha: 0.35 + 0.3 * t)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 6 * t),
      )
      ..drawArc(
        ring,
        _startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6 + 1.4 * t
          ..strokeCap = StrokeCap.round
          ..color = AegisColors.amberBright,
      );
  }

  void _paintHead(Canvas canvas, Offset center, double radius, double t) {
    final angle = _startAngle + math.pi * 2 * t;
    final head = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas
      ..drawCircle(
        head,
        6 + 4 * t,
        Paint()
          ..color = AegisColors.amberBright.withValues(alpha: 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + 3 * t),
      )
      ..drawCircle(
        head,
        3.2 + 1.2 * t,
        Paint()..color = AegisColors.amberBright,
      );
  }

  /// The alert leaving the device: a hot ring that expands past the button.
  void _paintFlare(Canvas canvas, Offset center, double radius) {
    final t = Curves.easeOutCubic.transform(flare.value);
    final fade = 1 - flare.value;
    final inner = radius * (0.55 + 0.35 * t);

    canvas
      ..drawCircle(
        center,
        radius * (0.6 + 0.9 * t),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10 * fade + 1
          ..color = AegisColors.warmWhite.withValues(alpha: 0.55 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      )
      ..drawCircle(
        center,
        inner,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AegisColors.warmWhite.withValues(alpha: 0.4 * fade),
              AegisColors.alert.withValues(alpha: 0.18 * fade),
              AegisColors.alert.withValues(alpha: 0),
            ],
            stops: const [0, 0.6, 1],
          ).createShader(Rect.fromCircle(center: center, radius: inner)),
      );
  }

  Path _dashes(Size size, Rect ring) {
    if (size == _cachedSize && _cachedDashes != null) return _cachedDashes!;

    final arc = Path()..addArc(ring, _startAngle, _dashedSweep);
    final dashes = Path();
    for (final metric in arc.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dashLength + _dashGap) {
        dashes.addPath(
          metric.extractPath(d, math.min(d + _dashLength, metric.length)),
          Offset.zero,
        );
      }
    }
    _cachedSize = size;
    return _cachedDashes = dashes;
  }

  @override
  bool shouldRepaint(_SosRingPainter oldDelegate) =>
      oldDelegate.hold != hold ||
      oldDelegate.press != press ||
      oldDelegate.ripple != ripple ||
      oldDelegate.flare != flare ||
      oldDelegate.breath != breath;
}
