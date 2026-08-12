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

class _CurrentWeightScreenState extends State<CurrentWeightScreen> {
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
                        const _StepPill(),
                        const SizedBox(height: 20),
                        const WeightBadge(),
                        const SizedBox(height: 24),
                        const _Title(),
                        const SizedBox(height: 22),
                        UnitToggle(unit: _unit, onChanged: _switchUnit),
                        const SizedBox(height: 18),
                        WeightBox(value: _displayValue, unit: _unit),
                        const SizedBox(height: 8),
                        const CustomPaint(
                          size: Size(18, 12),
                          painter: TrianglePainter(),
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center,
            size: 13,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 6),
          Text(
            'STEP 2 OF 5',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.softGrey,
            ),
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
    return const Column(
      children: [
        Text(
          'Your Current Weight',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 44),
          child: Text(
            'Set your baseline so we can tailor goals and track your progress over time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.softGrey,
            ),
          ),
        ),
      ],
    );
  }
}
