import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
import 'widgets/sos_hold_button.dart';
import 'widgets/status_pill.dart';

class SosHomeScreen extends StatefulWidget {
  const SosHomeScreen({
    super.key,
    required this.heartRate,
    required this.location,
    required this.contacts,
    required this.onAlertActivated,
    this.onOpenSettings,
  });

  final HeartRateReading? heartRate;
  final LocationFix? location;
  final List<EmergencyContact> contacts;
  final VoidCallback onAlertActivated;
  final VoidCallback? onOpenSettings;

  @override
  State<SosHomeScreen> createState() => _SosHomeScreenState();
}

class _SosHomeScreenState extends State<SosHomeScreen>
    with SingleTickerProviderStateMixin {
  static const double _gutter = 14;

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AegisMotion.reveal,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _reveal.value = 1;
    } else if (_reveal.status == AnimationStatus.dismissed) {
      _reveal.forward();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AegisScaffold(
      glow: AegisColors.alert,
      actions: [
        HeaderButton(
          icon: CupertinoIcons.gear_alt,
          tooltip: 'Settings',
          onPressed: widget.onOpenSettings,
        ),
      ],
      children: [
        Reveal(
          animation: _reveal,
          order: 0,
          child: const Text(
            'Real help. When it matters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: AegisColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Reveal(
          animation: _reveal,
          order: 1,
          child: const Text(
            'Your health. Our priority.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AegisColors.textMuted),
          ),
        ),
        const SizedBox(height: 18),
        // The button is the one element allowed to drive the layout, so it
        // takes what the screen can spare rather than a fixed 284.
        Reveal(
          animation: _reveal,
          order: 2,
          lift: 30,
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: SosHoldButton(
                size: math.min(
                  SosHoldButton.defaultSize,
                  constraints.maxWidth * 0.86,
                ),
                onActivated: widget.onAlertActivated,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          animation: _reveal,
          order: 3,
          child: const Text(
            'Press and hold for 3 seconds\nto send an emergency alert.',
            textAlign: TextAlign.center,
            style: AegisText.caption,
          ),
        ),
        const SizedBox(height: 20),
        Reveal(
          animation: _reveal,
          order: 4,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _HeartRateCard(reading: widget.heartRate)),
                const SizedBox(width: _gutter),
                Expanded(child: _LocationCard(fix: widget.location)),
              ],
            ),
          ),
        ),
        const SizedBox(height: _gutter),
        Reveal(
          animation: _reveal,
          order: 5,
          child: _ContactsCard(contacts: widget.contacts),
        ),
      ],
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AegisText.cardTitle,
          ),
        ),
      ],
    );
  }
}

/// A heart that beats at the reading's own rate, so the card conveys the
/// number before it is read.
class _BeatingHeart extends StatefulWidget {
  const _BeatingHeart({required this.bpm, required this.color});

  final int bpm;
  final Color color;

  @override
  State<_BeatingHeart> createState() => _BeatingHeartState();
}

class _BeatingHeartState extends State<_BeatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _interval,
  );

  Duration get _interval =>
      Duration(milliseconds: (60000 / widget.bpm.clamp(30, 220)).round());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_BeatingHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) _controller.duration = _interval;
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
        // Sharp contraction, slow recovery — closer to a real beat than a
        // symmetrical pulse would be.
        final t = _controller.value;
        final beat = t < 0.18
            ? Curves.easeOut.transform(t / 0.18)
            : 1 - Curves.easeOutCubic.transform((t - 0.18) / 0.82);
        return Transform.scale(scale: 1 + 0.22 * beat, child: child);
      },
      child: Icon(CupertinoIcons.heart_fill, size: 19, color: widget.color),
    );
  }
}

class _HeartRateCard extends StatelessWidget {
  const _HeartRateCard({required this.reading});

  final HeartRateReading? reading;

  @override
  Widget build(BuildContext context) {
    final reading = this.reading;
    final elevated = reading?.status == HeartRateStatus.elevated;
    final accent = elevated ? AegisColors.alertText : AegisColors.teal;

    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: reading == null
                ? const Icon(
                    CupertinoIcons.heart,
                    size: 19,
                    color: AegisColors.alertText,
                  )
                : _BeatingHeart(
                    bpm: reading.bpm,
                    color: AegisColors.alertText,
                  ),
            label: 'Heart rate',
          ),
          const SizedBox(height: 8),
          if (reading == null)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Connect a wearable to see your heart rate.',
                style: AegisText.caption,
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${reading.bpm}',
                      style: TextStyle(
                        fontFamily: AegisFonts.serif,
                        fontSize: 46,
                        height: 1.05,
                        color: elevated
                            ? AegisColors.alertText
                            : AegisColors.warmWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'bpm',
                  style: TextStyle(fontSize: 16, color: AegisColors.textMuted),
                ),
              ],
            ),
            if (reading.recentBpm.length > 1) ...[
              const SizedBox(height: 4),
              SizedBox(
                height: 24,
                child: PulseLine(
                  samples: reading.recentBpm,
                  color: AegisColors.alert,
                  curved: true,
                  glow: true,
                ),
              ),
            ],
            const SizedBox(height: 12),
            StatusPill(
              icon: elevated
                  ? CupertinoIcons.alarm
                  : CupertinoIcons.checkmark_circle_fill,
              label: elevated ? 'Elevated' : 'Normal',
              color: accent,
              pulsing: elevated,
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.fix});

  final LocationFix? fix;

  @override
  Widget build(BuildContext context) {
    final fix = this.fix;

    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeading(
            icon: Icon(
              CupertinoIcons.placemark,
              size: 19,
              color: AegisColors.textPrimary,
            ),
            label: 'Location',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    fix == null ? 'Locating' : 'Live',
                    style: const TextStyle(
                      fontFamily: AegisFonts.serif,
                      fontSize: 38,
                      height: 1.05,
                      color: AegisColors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (fix != null) ...[
                const SizedBox(width: 10),
                const _LiveDot(),
              ],
            ],
          ),
          const SizedBox(height: 6),
          if (fix == null)
            const Text('Waiting for a GPS fix.', style: AegisText.caption)
          else ...[
            Text(
              '${formatLatitude(fix.latitude)}\n'
              '${formatLongitude(fix.longitude)}',
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AegisColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.signal_cellular_alt,
                  size: 15,
                  color: AegisColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Accuracy ${formatDistance(fix.accuracyMeters)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AegisColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Slow blink on the GPS indicator, the same idea as a recording light.
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  static const double size = 8;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.stop();
      _controller.value = 1;
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
        final t = 0.45 + 0.55 * _controller.value;
        return Container(
          width: _LiveDot.size,
          height: _LiveDot.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AegisColors.tealBright.withValues(alpha: t),
            boxShadow: [
              BoxShadow(
                color: AegisColors.teal.withValues(alpha: 0.6 * t),
                blurRadius: 4 + 5 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactsCard extends StatelessWidget {
  const _ContactsCard({required this.contacts});

  static const _visibleCount = 4;
  static const double _avatarSize = 52;

  final List<EmergencyContact> contacts;

  @override
  Widget build(BuildContext context) {
    final connected = contacts.where((c) => c.isConnected).length;
    final hidden = contacts.length - _visibleCount;

    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Emergency contacts', style: AegisText.cardTitle),
              ),
              Text(
                '$connected connected',
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
          const SizedBox(height: 14),
          if (contacts.isEmpty)
            const Text(
              'Add people to alert when you send an SOS.',
              style: AegisText.caption,
            )
          else
            // Even slots rather than fixed gaps, so the row holds together
            // from an SE up to a Max.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final contact in contacts.take(_visibleCount))
                  Expanded(
                    child: Column(
                      children: [
                        PersonAvatar(
                          name: contact.name,
                          photo: contact.photo,
                          size: _avatarSize,
                          connected: contact.isConnected,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contact.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AegisColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (hidden > 0)
                  Expanded(
                    child: SizedBox(
                      height: _avatarSize,
                      child: Center(
                        child: Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            '+$hidden',
                            semanticsLabel: '$hidden more contacts',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AegisColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
