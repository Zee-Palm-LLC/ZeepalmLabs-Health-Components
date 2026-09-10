import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/breathing_aura.dart';

enum BreathPhase {
  inhale('Inhale', 4, 0.72, 1.0),
  hold('Hold', 7, 1.0, 1.0),
  exhale('Exhale', 8, 1.0, 0.72);

  const BreathPhase(this.label, this.seconds, this.fromScale, this.toScale);
  final String label;
  final int seconds;
  final double fromScale;
  final double toScale;

  BreathPhase get next => BreathPhase.values[(index + 1) % BreathPhase.values.length];
}

const _sessionDuration = Duration(minutes: 2);

class BreathingSessionScreen extends StatefulWidget {
  const BreathingSessionScreen({super.key});

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with TickerProviderStateMixin {
  static const _clockSeconds = 24.0;
  late final AnimationController _breath = AnimationController(vsync: this);

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  Timer? _ticker;
  BreathPhase _phase = BreathPhase.inhale;
  int _remainingInPhase = BreathPhase.inhale.seconds;
  int _elapsedSeconds = 48;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _startPhase(BreathPhase.inhale);
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _clock.dispose();
    _breath.dispose();
    super.dispose();
  }

  void _startPhase(BreathPhase phase, {bool announce = false}) {
    if (announce) {
      switch (phase) {
        case BreathPhase.inhale:
          HapticFeedback.mediumImpact();
        case BreathPhase.hold:
          HapticFeedback.selectionClick();
        case BreathPhase.exhale:
          HapticFeedback.lightImpact();
      }
    }
    _phase = phase;
    _remainingInPhase = phase.seconds;
    _breath
      ..duration = Duration(seconds: phase.seconds)
      ..value = 0
      ..forward();
  }

  void _onTick(Timer timer) {
    if (!_running) return;
    setState(() {
      _elapsedSeconds = math.min(_elapsedSeconds + 1, _sessionDuration.inSeconds);
      if (_remainingInPhase > 1) {
        _remainingInPhase--;
      } else {
        _startPhase(_phase.next, announce: true);
      }
    });
  }

  void _togglePlayback() {
    setState(() {
      _running = !_running;
      HapticFeedback.selectionClick();
      if (_running) {
        _breath.forward();
      } else {
        _breath.stop();
      }
    });
  }

  String _format(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _format(_elapsedSeconds);
    final total = _format(_sessionDuration.inSeconds);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const _SessionBar(),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppDecoration.pageGradient),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _BreathCircle(
                    running: _running,
                    breath: _breath,
                    clock: _clock,
                    clockSeconds: _clockSeconds,
                    phase: _phase,
                    secondsLeft: _remainingInPhase,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: Row(
                  children: [
                    const Expanded(
                      child: _SessionOption(
                        icon: LucideIcons.waves,
                        title: 'Sounds',
                        value: 'Ocean Waves',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    const Expanded(
                      child: _SessionOption(
                        icon: LucideIcons.mic,
                        title: 'Voice',
                        value: 'Gentle Guide',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: _SessionProgress(
                  value: _elapsedSeconds / _sessionDuration.inSeconds,
                  label: '$elapsed / $total',
                ),
              ),
              SizedBox(height: 26.h),
              _SessionControls(running: _running, onToggle: _togglePlayback),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionBar extends StatelessWidget implements PreferredSizeWidget {
  const _SessionBar();
  static const _height = 68.0;

  @override
  Size get preferredSize => Size.fromHeight(_height.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _height.h,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(LucideIcons.chevronLeft, size: 24.r),
        color: AppColors.textPrimary,
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Breathing Session', style: AppText.body(19, weight: FontWeight.w600)),
          SizedBox(height: 2.h),
          Text(
            'Calm Mind  •  2 min',
            style: AppText.body(12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _BreathCircle extends StatelessWidget {
  const _BreathCircle({
    required this.running,
    required this.breath,
    required this.clock,
    required this.clockSeconds,
    required this.phase,
    required this.secondsLeft,
  });

  final bool running;
  final AnimationController breath;
  final AnimationController clock;
  final double clockSeconds;
  final BreathPhase phase;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([breath, clock]),
      builder: (context, _) {
        final t = Curves.easeInOut.transform(breath.value);

        final expansion =
            (phase.fromScale + (phase.toScale - phase.fromScale) * t - 0.72) / 0.28;

        return AnimatedOpacity(
          opacity: running ? 1 : 0.55,
          duration: AppMotion.enter,
          curve: AppMotion.enterCurve,
          child: BreathingAura(
            diameter: 268.r,
            time: clock.value * clockSeconds,
            breath: expansion,
            progress: breath.value,
            particles: running,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    phase.label,
                    key: ValueKey(phase),
                    style: AppText.body(23.5, weight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${secondsLeft}s',
                  style: AppText.body(15, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SessionOption extends StatelessWidget {
  const _SessionOption({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: AppDecoration.card(radius: 16.r),
      child: Row(
        children: [
          Container(
            width: 30.r,
            height: 30.r,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blueWash),
            child: Icon(icon, size: 15.r, color: AppColors.blueDeep),
          ),
          SizedBox(width: 9.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppText.body(13.5, weight: FontWeight.w500)),
              SizedBox(height: 1.h),
              Text(value, style: AppText.body(11.5, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionProgress extends StatelessWidget {
  const _SessionProgress({required this.value, required this.label});
  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3.r),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 400),
            builder: (context, t, _) => LinearProgressIndicator(
              value: t,
              minHeight: 4.h,
              backgroundColor: AppColors.track,
              valueColor: const AlwaysStoppedAnimation(AppColors.blueDeep),
            ),
          ),
        ),
        SizedBox(height: 9.h),
        Text(label, style: AppText.body(13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _SessionControls extends StatelessWidget {
  const _SessionControls({required this.running, required this.onToggle});
  final bool running;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _CircleControl(icon: LucideIcons.volume2),
        SizedBox(width: 30.w),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 62.r,
            height: 62.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.35), width: 1.4.r),
              boxShadow: AppShadows.raised,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                running ? LucideIcons.pause : LucideIcons.play,
                key: ValueKey(running),
                size: 24.r,
                color: AppColors.blueDeep,
              ),
            ),
          ),
        ),
        SizedBox(width: 30.w),
        const _CircleControl(icon: LucideIcons.settings2),
      ],
    );
  }
}

class _CircleControl extends StatelessWidget {
  const _CircleControl({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Icon(icon, size: 18.r, color: AppColors.textSecondary),
    );
  }
}
