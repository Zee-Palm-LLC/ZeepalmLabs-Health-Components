import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/aegis_theme.dart';
import '../theme/motion.dart';
import 'formatting.dart';
import 'models.dart';
import 'widgets/aegis_app_bar.dart';
import 'widgets/aegis_scaffold.dart';
import 'widgets/dispatch_progress.dart';
import 'widgets/panel.dart';
import 'widgets/person_avatar.dart';
import 'widgets/responder_map.dart';
import 'widgets/reveal.dart';

/// Live view of a responder on their way.
///
/// The screen runs the journey itself: the vehicle crosses the map, the road
/// behind it fills in, the ETA counts down and the stepper advances. When the
/// responder reaches the pin the stage flips to arrived, the screen holds on
/// that beat, and then [onArrived] fires so the caller can show the arrival
/// screen. Replace [journeyDuration] with a real dispatch feed by driving
/// [Dispatch] from the wire and passing `autoAdvance: false`.
class ResponderTrackingScreen extends StatefulWidget {
  const ResponderTrackingScreen({
    super.key,
    required this.dispatch,
    required this.onBack,
    this.onMore,
    this.onCallResponder,
    this.onArrived,
    this.autoAdvance = true,
    this.journeyDuration = AegisMotion.route,
  });

  final Dispatch dispatch;
  final VoidCallback onBack;
  final VoidCallback? onMore;
  final VoidCallback? onCallResponder;

  /// Called once the responder has arrived and the arrival beat has played.
  final VoidCallback? onArrived;

  /// Whether the screen simulates the journey. Off, it renders [dispatch] as
  /// given and never calls [onArrived].
  final bool autoAdvance;

  final Duration journeyDuration;

  @override
  State<ResponderTrackingScreen> createState() =>
      _ResponderTrackingScreenState();
}

class _ResponderTrackingScreenState extends State<ResponderTrackingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _journey = AnimationController(
    vsync: this,
    duration: widget.journeyDuration,
  )..addStatusListener(_handleJourneyStatus);

  /// Travel is eased and finishes before the controller does; the tail is the
  /// arrival beat, where the stepper and the pin get a moment on their own.
  late final Animation<double> _travel = CurvedAnimation(
    parent: _journey,
    curve: const Interval(0, AegisMotion.travelFraction, curve: Curves.easeInOutCubic),
  );

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AegisMotion.reveal,
  );

  bool _announcedArrival = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (reduceMotion(context)) {
      _reveal.value = 1;
    } else if (_reveal.status == AnimationStatus.dismissed) {
      _reveal.forward();
    }

    if (widget.autoAdvance && _journey.status == AnimationStatus.dismissed) {
      _journey.forward();
    }
  }

  @override
  void dispose() {
    _journey.dispose();
    _reveal.dispose();
    super.dispose();
  }

  void _handleJourneyStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _announcedArrival) return;
    _announcedArrival = true;
    HapticFeedback.mediumImpact();
    if (mounted) widget.onArrived?.call();
  }

  /// True once the vehicle has reached the pin, before the screen hands over.
  bool get _arrived =>
      widget.autoAdvance && _journey.value >= AegisMotion.travelFraction;

  /// [widget.dispatch] projected to where the responder is right now.
  Dispatch get _live {
    if (!widget.autoAdvance) return widget.dispatch;
    final remaining = 1 - _travel.value;
    return widget.dispatch.copyWith(
      stage: _arrived ? DispatchStage.arrived : DispatchStage.enRoute,
      eta: widget.dispatch.eta * remaining,
      distanceMeters: widget.dispatch.distanceMeters * remaining,
    );
  }

  @override
  Widget build(BuildContext context) {
    // A fixed 338 crowds a small phone once the responder card and stepper
    // are below it.
    final mapHeight = math.min(338.0, MediaQuery.sizeOf(context).height * 0.42);

    return AegisScaffold(
      glow: AegisColors.amber,
      topGap: 4,
      leading: HeaderButton(
        icon: CupertinoIcons.back,
        tooltip: 'Back',
        onPressed: widget.onBack,
      ),
      actions: [
        HeaderButton(
          icon: CupertinoIcons.ellipsis,
          tooltip: 'More',
          onPressed: widget.onMore,
        ),
      ],
      children: [
        Reveal(
          animation: _reveal,
          order: 0,
          child: AnimatedBuilder(
            animation: _journey,
            builder: (context, _) => _EtaHeadline(
              eta: _live.eta,
              arrived: _arrived,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Reveal(
          animation: _reveal,
          order: 1,
          child: AnimatedBuilder(
            animation: _journey,
            builder: (context, _) => _StatusLine(arrived: _arrived),
          ),
        ),
        const SizedBox(height: 20),
        Reveal(
          animation: _reveal,
          order: 2,
          lift: 28,
          child: SizedBox(
            height: mapHeight,
            child: ResponderMap(dispatch: widget.dispatch, travel: _travel),
          ),
        ),
        const SizedBox(height: 14),
        Reveal(
          animation: _reveal,
          order: 3,
          child: AnimatedBuilder(
            animation: _journey,
            builder: (context, _) => _ResponderCard(
              dispatch: _live,
              onCall: widget.onCallResponder,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Reveal(
          animation: _reveal,
          order: 4,
          child: AnimatedBuilder(
            animation: _journey,
            builder: (context, _) => DispatchProgress(
              dispatch: _live,
              enRouteProgress: _travel.value,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.arrived});

  final bool arrived;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AegisMotion.medium,
      child: Text(
        arrived
            ? 'Your responder is with you.'
            : 'Help is on the way. Stay calm.',
        key: ValueKey(arrived),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: arrived ? AegisColors.tealBright : AegisColors.textSecondary,
        ),
      ),
    );
  }
}

class _EtaHeadline extends StatelessWidget {
  const _EtaHeadline({required this.eta, required this.arrived});

  final Duration eta;
  final bool arrived;

  static const _wordStyle = TextStyle(
    fontFamily: AegisFonts.serif,
    fontSize: 40,
    height: 0.98,
    color: AegisColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final minutes = etaMinutes(eta);

    return Center(
      child: AnimatedSwitcher(
        duration: AegisMotion.medium,
        switchInCurve: AegisMotion.enter,
        child: arrived
            ? const _ArrivedHeadline(key: ValueKey('arrived'))
            : Semantics(
                key: const ValueKey('eta'),
                label: '$minutes ${minutes == 1 ? 'minute' : 'minutes'} out',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    _RollingMinutes(minutes: minutes),
                    const SizedBox(width: 14),
                    // Laid out bottom-up so the column's baseline is the last
                    // line, letting "out" share the numeral's baseline.
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      verticalDirection: VerticalDirection.up,
                      children: [
                        const Text('out', style: _wordStyle),
                        Text(
                          minutes == 1 ? 'minute' : 'minutes',
                          style: _wordStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// The countdown numeral, rolling up as each minute falls away.
class _RollingMinutes extends StatelessWidget {
  const _RollingMinutes({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AegisMotion.medium,
      switchInCurve: AegisMotion.enter,
      switchOutCurve: AegisMotion.exit,
      transitionBuilder: (child, animation) => ClipRect(
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.35),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.bottomCenter,
        children: [...previous, if (current != null) current],
      ),
      child: Text(
        '$minutes',
        key: ValueKey(minutes),
        style: const TextStyle(
          fontFamily: AegisFonts.serif,
          fontSize: 128,
          height: 1,
          fontWeight: FontWeight.w500,
          color: AegisColors.amber,
        ),
      ),
    );
  }
}

class _ArrivedHeadline extends StatelessWidget {
  const _ArrivedHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CupertinoIcons.checkmark_seal_fill,
          size: 64,
          color: AegisColors.tealBright,
        ),
        SizedBox(height: 12),
        Text(
          'Arrived',
          style: TextStyle(
            fontFamily: AegisFonts.serif,
            fontSize: 56,
            height: 1,
            fontWeight: FontWeight.w500,
            color: AegisColors.tealBright,
          ),
        ),
      ],
    );
  }
}

class _ResponderCard extends StatelessWidget {
  const _ResponderCard({required this.dispatch, this.onCall});

  final Dispatch dispatch;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final responder = dispatch.responder;

    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              PersonAvatar(
                name: responder.name,
                photo: responder.photo,
                size: 56,
                ring: AegisColors.amber.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      responder.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AegisColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${responder.certification} · ${responder.unit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AegisColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      responder.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AegisColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CallButton(name: responder.name, onPressed: onCall),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: CupertinoIcons.clock,
                    label: 'ETA',
                    value: Text(
                      formatEta(dispatch.eta),
                      style: AegisText.value,
                    ),
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _Stat(
                    icon: CupertinoIcons.placemark,
                    label: 'Distance',
                    value: Text(
                      formatDistance(dispatch.distanceMeters),
                      style: AegisText.value,
                    ),
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _Stat(
                    icon: Icons.airport_shuttle_outlined,
                    label: 'Vehicle',
                    value: _VehicleStatus(stage: dispatch.stage),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatefulWidget {
  const _CallButton({required this.name, this.onPressed});

  final String name;
  final VoidCallback? onPressed;

  @override
  State<_CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<_CallButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return Tooltip(
      message: 'Call ${widget.name}',
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: AegisMotion.fast,
          child: AnimatedContainer(
            duration: AegisMotion.fast,
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _down
                  ? AegisColors.amber.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: Border.all(
                color: AegisColors.amber.withValues(alpha: enabled ? 1 : 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              CupertinoIcons.phone_fill,
              size: 22,
              color: AegisColors.amber.withValues(alpha: enabled ? 1 : 0.4),
              semanticLabel: 'Call ${widget.name}',
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AegisColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AegisColors.textMuted,
                  ),
                ),
                const SizedBox(height: 5),
                value,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: VerticalDivider(width: 1, thickness: 1),
    );
  }
}

class _VehicleStatus extends StatelessWidget {
  const _VehicleStatus({required this.stage});

  final DispatchStage stage;

  @override
  Widget build(BuildContext context) {
    final label = switch (stage) {
      DispatchStage.alertSent => 'Dispatching',
      DispatchStage.enRoute => 'On route',
      DispatchStage.arrived => 'Arrived',
    };

    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AegisText.value,
          ),
        ),
        if (stage != DispatchStage.alertSent) ...[
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AegisColors.tealBright,
            ),
          ),
        ],
      ],
    );
  }
}
