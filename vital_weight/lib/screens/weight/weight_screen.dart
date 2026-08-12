import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vital_weight/screens/weight/widgets/badge.dart';
import 'package:vital_weight/screens/weight/widgets/top_nav.dart';
import 'package:vital_weight/screens/weight/widgets/triangle_painter.dart';
import 'package:vital_weight/screens/weight/widgets/unit_toggle.dart';
import 'package:vital_weight/screens/weight/widgets/weight_box.dart';
import 'package:vital_weight/theme/app_theme.dart';
import 'package:vital_weight/widgets/weight_dial.dart';

enum WeightUnit { kg, lbs }

class CurrentWeightScreen extends StatefulWidget {
  const CurrentWeightScreen({super.key});

  @override
  State<CurrentWeightScreen> createState() => _CurrentWeightScreenState();
}

class _CurrentWeightScreenState extends State<CurrentWeightScreen>
    with SingleTickerProviderStateMixin {
  // Weight is always stored internally in kg.
  double _weightKg = 60;
  WeightUnit _unit = WeightUnit.kg;

  static const double _minKg = 30;
  static const double _maxKg = 90;

  double get _displayValue =>
      _unit == WeightUnit.kg ? _weightKg : _weightKg * 2.20462;

  double get _minDisplay => _unit == WeightUnit.kg ? _minKg : _minKg * 2.20462;
  double get _maxDisplay => _unit == WeightUnit.kg ? _maxKg : _maxKg * 2.20462;

  void _setFromDial(double displayValue) {
    setState(() {
      final clamped = displayValue.clamp(_minDisplay, _maxDisplay);
      _weightKg = _unit == WeightUnit.kg ? clamped : clamped / 2.20462;
    });
  }

  void _switchUnit(WeightUnit unit) {
    if (unit == _unit) return;
    HapticFeedback.selectionClick();
    setState(() => _unit = unit);
  }

  @override
  Widget build(BuildContext context) {
    final dialHeight = MediaQuery.sizeOf(context).width * 0.70;
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Column(
              children: [
                const TopNav(progress: 0.38),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: dialHeight + 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const _Entrance(
                          delay: Duration(milliseconds: 80),
                          child: _StepPill(),
                        ),
                        const SizedBox(height: 20),
                        const _Entrance(
                          delay: Duration(milliseconds: 160),
                          child: WeightBadge(),
                        ),
                        const SizedBox(height: 24),
                        const _Entrance(
                          delay: Duration(milliseconds: 240),
                          child: _Title(),
                        ),
                        const SizedBox(height: 22),
                        _Entrance(
                          delay: const Duration(milliseconds: 320),
                          child: UnitToggle(
                            unit: _unit,
                            onChanged: _switchUnit,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _Entrance(
                          delay: const Duration(milliseconds: 400),
                          child: WeightBox(
                            value: _displayValue,
                            unit: _unit,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _Entrance(
                          delay: Duration(milliseconds: 460),
                          child: CustomPaint(
                            size: Size(18, 12),
                            painter: TrianglePainter(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Dial peeking from the bottom.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: WeightDial(
              minValue: _minDisplay,
              maxValue: _maxDisplay,
              value: _displayValue,
              unitLabel: _unit == WeightUnit.kg ? 'kg' : 'lbs',
              onChanged: _setFromDial,
            ),
          ),
        ],
      ),
    );
  }
}

/// Staggered fade + slide entrance for a polished onboarding feel.
class _Entrance extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const _Entrance({required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    final offset = 0.16;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, v, childWidget) {
        final delayed = v * (1 - offset) + (delay.inMilliseconds / 600) * offset;
        final t = (delayed).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - t)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

/// Full-screen decorative gradient with soft color blobs for depth.
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.backgroundGradient,
          stops: AppColors.backgroundStops,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -60,
            child: _Blob(
              size: 180,
              color: const Color(0xFF6FE3A3).withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            top: 90,
            left: -80,
            child: _Blob(
              size: 160,
              color: const Color(0xFFB79CE0).withValues(alpha: 0.22),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// Small pill showing the current onboarding step.
class _StepPill extends StatelessWidget {
  const _StepPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1F1E).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 13,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 6),
          Text(
            'STEP 2 OF 5',
            style: AppType.body(size: 10.5, weight: FontWeight.w700)
                .copyWith(letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}

/// Title block with a balanced heading + supporting copy.
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Your Current Weight',
          textAlign: TextAlign.center,
          style: AppType.display(size: 24),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Text(
            'Set your baseline so we can tailor goals and track your progress over time.',
            textAlign: TextAlign.center,
            style: AppType.body(),
          ),
        ),
      ],
    );
  }
}
