import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';

class WorkoutVideoPlayer extends StatefulWidget {
  const WorkoutVideoPlayer({
    super.key,
    this.onBack,
    this.scrollCollapse = 0,
  });

  final VoidCallback? onBack;
  final double scrollCollapse;

  @override
  State<WorkoutVideoPlayer> createState() => _WorkoutVideoPlayerState();
}

class _WorkoutVideoPlayerState extends State<WorkoutVideoPlayer>
    with TickerProviderStateMixin {
  late final AnimationController _progress;
  late final AnimationController _pulse;
  late final AnimationController _press;
  bool _playing = false;
  bool _muted = false;

  static const _duration = Duration(minutes: 5, seconds: 40);

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _duration);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _progress.dispose();
    _pulse.dispose();
    _press.dispose();
    super.dispose();
  }

  void _togglePlay() {
    HapticFeedback.mediumImpact();
    setState(() => _playing = !_playing);
    if (_playing) {
      _progress.forward();
    } else {
      _progress.stop();
    }
  }

  String _fmt(double t) {
    final total = (_duration.inMilliseconds * t).round();
    final m = total ~/ 60000;
    final s = (total % 60000) ~/ 1000;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final collapse = widget.scrollCollapse.clamp(0.0, 1.0);
    final height = (300 + top * 0.2) * (1 - 0.12 * collapse);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(22 + 6 * (1 - collapse)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1581009146145-b5ef0754ff92?w=1100&q=80',
              fit: BoxFit.cover,
              alignment: Alignment(0, -0.15 - 0.1 * collapse),
              errorBuilder: (_, error, stackTrace) => Container(
                color: KinoraColors.card,
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.dumbbell,
                  size: 48,
                  color: KinoraColors.lime,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0, 0.28, 0.7, 1],
                ),
              ),
            ),
            // Lime edge accent when playing
            if (_playing)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: KinoraColors.lime.withValues(alpha: 0.28),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              top: top + 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _GlassIconButton(
                    icon: LucideIcons.chevron_left,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onBack?.call();
                    },
                  ),
                  const Spacer(),
                  _GlassIconButton(
                    icon: LucideIcons.ellipsis_vertical,
                    onTap: () => HapticFeedback.selectionClick(),
                  ),
                ],
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulse, _press]),
                builder: (context, child) {
                  final phase = _pulse.value * math.pi * 2;
                  final breath = MathMotion.breath(phase, lo: 0.96, hi: 1.05);
                  final press = MathMotion.smootherstep(_press.value);
                  final ring = 1.08 + 0.06 * math.sin(phase);
                  return Transform.scale(
                    scale: breath * (1 - 0.08 * press),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_playing)
                          Transform.scale(
                            scale: ring,
                            child: Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                            ),
                          ),
                        if (_playing)
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: KinoraColors.lime.withValues(
                                    alpha: 0.28 + 0.12 * math.sin(phase),
                                  ),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        child!,
                      ],
                    ),
                  );
                },
                child: GestureDetector(
                  onTapDown: (_) => _press.forward(),
                  onTapUp: (_) {
                    _press.reverse();
                    _togglePlay();
                  },
                  onTapCancel: () => _press.reverse(),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _playing
                          ? KinoraColors.lime.withValues(alpha: 0.92)
                          : Colors.black.withValues(alpha: 0.48),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: _playing ? 0.1 : 0.38,
                        ),
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Icon(
                      _playing ? LucideIcons.pause : LucideIcons.play,
                      size: 30,
                      color: _playing ? KinoraColors.ink : Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  final t = _progress.value;
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.8,
                          activeTrackColor: KinoraColors.lime,
                          inactiveTrackColor:
                              Colors.white.withValues(alpha: 0.2),
                          thumbColor: Colors.white,
                          overlayColor:
                              KinoraColors.lime.withValues(alpha: 0.2),
                          padding: EdgeInsets.zero,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7.5,
                            elevation: 3,
                          ),
                          trackShape: const RectangularSliderTrackShape(),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Slider(
                            value: t.clamp(0.0, 1.0),
                            onChanged: (v) {
                              _progress.value = v;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 2),
                        child: Row(
                          children: [
                            Text(
                              _fmt(t),
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '5:40',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(width: 14),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _muted = !_muted);
                              },
                              child: Icon(
                                _muted
                                    ? LucideIcons.volume_x
                                    : LucideIcons.volume_2,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(
                              LucideIcons.maximize,
                              size: 17,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatefulWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          final t = MathMotion.smootherstep(_press.value);
          return Transform.scale(scale: 1 - 0.1 * t, child: child);
        },
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.4),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Icon(widget.icon, size: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
