import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/aegis_theme.dart';
import '../theme/motion.dart';
import 'formatting.dart';
import 'models.dart';
import 'widgets/aegis_app_bar.dart';
import 'widgets/aegis_scaffold.dart';
import 'widgets/panel.dart';
import 'widgets/person_avatar.dart';
import 'widgets/pulse_line.dart';
import 'widgets/reveal.dart';
import 'widgets/status_pill.dart';

/// The all-clear.
///
/// Everything on the screen resolves rather than simply appearing: the badge
/// springs in and its check is drawn, the ECG is traced left to right, and the
/// heart rate settles from [previousBpm] down to where it is now.
class ArrivalScreen extends StatefulWidget {
  const ArrivalScreen({
    super.key,
    required this.heartRate,
    required this.notifiedContacts,
    required this.onClose,
    this.onOpenSupport,
    this.previousBpm,
  });

  final HeartRateReading? heartRate;
  final List<EmergencyContact> notifiedContacts;
  final VoidCallback onClose;
  final VoidCallback? onOpenSupport;

  /// Reading from before the responder arrived. When given, the number counts
  /// down from it, which is what "your pulse has settled" looks like.
  final int? previousBpm;

  @override
  State<ArrivalScreen> createState() => _ArrivalScreenState();
}

class _ArrivalScreenState extends State<ArrivalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _entrance.value = 1;
    } else if (_entrance.status == AnimationStatus.dismissed) {
      HapticFeedback.mediumImpact();
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heartRate = widget.heartRate;

    return AegisScaffold(
      glow: AegisColors.teal,
      topGap: 4,
      actions: [
        HeaderButton(
          icon: CupertinoIcons.xmark,
          tooltip: 'Close',
          onPressed: widget.onClose,
        ),
      ],
      children: [
        Center(child: _SuccessBadge(animation: _entrance)),
        const SizedBox(height: 20),
        Reveal(
          animation: _entrance,
          order: 4,
          child: const Text(
            'You’re safe',
            textAlign: TextAlign.center,
            style: AegisText.display,
          ),
        ),
        const SizedBox(height: 10),
        Reveal(
          animation: _entrance,
          order: 5,
          child: const Text(
            'Help has arrived. Your information\n'
            'has been shared with your contacts.',
            textAlign: TextAlign.center,
            style: AegisText.body,
          ),
        ),
        if (heartRate != null) ...[
          const SizedBox(height: 26),
          _HeartRateSummary(
            reading: heartRate,
            previousBpm: widget.previousBpm,
            animation: _entrance,
          ),
        ],
        const SizedBox(height: 20),
        Reveal(
          animation: _entrance,
          order: 9,
          child: _NotifiedContactsCard(
            contacts: widget.notifiedContacts,
            animation: _entrance,
          ),
        ),
        const SizedBox(height: 14),
        Reveal(
          animation: _entrance,
          order: 10,
          child: Panel(
            onTap: widget.onOpenSupport,
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: const Row(
              children: [
                _ShieldBadge(),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You’re in good hands',
                        style: TextStyle(
                          fontSize: 14.5,
                          color: AegisColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Aegis is always with you.',
                        style: AegisText.caption,
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: AegisColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge({required this.animation});

  static const double _size = 184;
  static const double _discSize = 122;

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final pop = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.42, curve: Curves.elasticOut),
    );
    final rings = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.1, 0.65, curve: AegisMotion.enter),
    );
    final check = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.28, 0.6, curve: AegisMotion.emphasized),
    );

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Halo and outline expand outwards from the disc, so the badge
            // reads as settling rather than fading up.
            Positioned.fill(
              child: FadeTransition(
                opacity: rings,
                child: ScaleTransition(
                  scale: Tween(begin: 0.7, end: 1.0).animate(rings),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AegisColors.teal.withValues(alpha: 0.14),
                          AegisColors.teal.withValues(alpha: 0),
                        ],
                      ),
                      border: Border.all(
                        color: AegisColors.teal.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: rings,
              child: ScaleTransition(
                scale: Tween(begin: 0.75, end: 1.0).animate(rings),
                child: Container(
                  width: 156,
                  height: 156,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AegisColors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
            ScaleTransition(
              scale: pop,
              child: Container(
                width: _discSize,
                height: _discSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.2, -0.35),
                    radius: 0.9,
                    colors: [
                      Color(0xFF32A284),
                      Color(0xFF166654),
                      Color(0xFF0E4A40),
                    ],
                    stops: [0, 0.6, 1],
                  ),
                  border: Border.all(
                    color: AegisColors.tealBright.withValues(alpha: 0.7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AegisColors.teal.withValues(alpha: 0.45),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: CustomPaint(painter: _CheckPainter(progress: check)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0) return;

    Offset at(double x, double y) => Offset(x * size.width, y * size.height);
    final full = Path()
      ..addPolygon([at(0.3, 0.52), at(0.44, 0.66), at(0.71, 0.37)], false);

    // Drawn on rather than revealed, so the stroke moves the way a hand would.
    final check = Path();
    for (final metric in full.computeMetrics()) {
      check.addPath(metric.extractPath(0, metric.length * t), Offset.zero);
    }

    canvas
      ..drawPath(
        check,
        _stroke(12)
          ..color = AegisColors.tealBright.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawPath(check, _stroke(7)..color = AegisColors.tealBright);
  }

  Paint _stroke(double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _HeartRateSummary extends StatelessWidget {
  const _HeartRateSummary({
    required this.reading,
    required this.animation,
    this.previousBpm,
  });

  final HeartRateReading reading;
  final Animation<double> animation;
  final int? previousBpm;

  @override
  Widget build(BuildContext context) {
    final normal = reading.status == HeartRateStatus.normal;
    final trace = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.4, 0.92, curve: Curves.easeInOut),
    );
    final settle = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.45, 1, curve: AegisMotion.emphasized),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reading.ecgSamples.length > 1) ...[
          SizedBox(
            height: 44,
            child: PulseLine(
              samples: reading.ecgSamples,
              color: AegisColors.teal,
              strokeWidth: 1.5,
              glow: true,
              fadeEdges: true,
              progress: trace,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _SettlingBpm(
              from: previousBpm ?? reading.bpm,
              to: reading.bpm,
              animation: settle,
            ),
            const SizedBox(width: 8),
            const Text(
              'bpm',
              style: TextStyle(fontSize: 20, color: AegisColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Reveal(
          animation: animation,
          order: 7,
          child: Text(
            normal ? 'Within normal range.' : 'Above normal range.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.5,
              color: AegisColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Reveal(
          animation: animation,
          order: 8,
          child: Center(
            child: normal
                ? const StatusPill(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'Heart rate stable',
                    color: AegisColors.teal,
                  )
                : const StatusPill(
                    icon: CupertinoIcons.alarm,
                    label: 'Elevated',
                    color: AegisColors.alertText,
                    pulsing: true,
                  ),
          ),
        ),
      ],
    );
  }
}

class _SettlingBpm extends StatelessWidget {
  const _SettlingBpm({
    required this.from,
    required this.to,
    required this.animation,
  });

  final int from;
  final int to;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$to beats per minute',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final bpm = (from + (to - from) * animation.value).round();
          return Text(
            '$bpm',
            style: const TextStyle(
              fontFamily: AegisFonts.serif,
              fontSize: 64,
              height: 1.05,
              fontWeight: FontWeight.w500,
              color: AegisColors.warmWhite,
            ),
          );
        },
      ),
    );
  }
}

class _NotifiedContactsCard extends StatelessWidget {
  const _NotifiedContactsCard({
    required this.contacts,
    required this.animation,
  });

  final List<EmergencyContact> contacts;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final notified = contacts.where((c) => c.notifiedAt != null).toList();

    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Emergency contacts', style: AegisText.cardTitle),
              ),
              Text(
                '${notified.length} notified',
                style: const TextStyle(
                  fontSize: 12,
                  color: AegisColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.person_2,
                size: 17,
                color: AegisColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (notified.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No contacts have been notified yet.',
                style: AegisText.caption,
              ),
            ),
          for (final (index, contact) in notified.indexed) ...[
            if (index > 0) const Divider(height: 1, thickness: 1),
            Reveal(
              animation: animation,
              order: 10 + index,
              lift: 12,
              child: _NotifiedContactRow(
                contact: contact,
                animation: animation,
                order: 10 + index,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotifiedContactRow extends StatelessWidget {
  const _NotifiedContactRow({
    required this.contact,
    required this.animation,
    required this.order,
  });

  final EmergencyContact contact;
  final Animation<double> animation;
  final int order;

  @override
  Widget build(BuildContext context) {
    final time = formatClockTime(context, contact.notifiedAt!);
    // The tick lands just after its row has settled.
    final start = (0.06 * order + 0.12).clamp(0.0, 0.8);
    final tick = CurvedAnimation(
      parent: animation,
      curve: Interval(start, (start + 0.2).clamp(0.0, 1.0),
          curve: AegisMotion.overshoot),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          PersonAvatar(
            name: contact.name,
            photo: contact.photo,
            size: 46,
            connected: contact.isConnected,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AegisColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text('Notified · $time', style: AegisText.caption),
              ],
            ),
          ),
          ScaleTransition(
            scale: tick,
            child: const Icon(
              CupertinoIcons.checkmark_alt,
              size: 22,
              color: AegisColors.teal,
              semanticLabel: 'Notified',
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldBadge extends StatelessWidget {
  const _ShieldBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: AegisColors.hairline)),
      ),
      child: const Icon(
        CupertinoIcons.shield,
        size: 20,
        color: AegisColors.amber,
      ),
    );
  }
}
