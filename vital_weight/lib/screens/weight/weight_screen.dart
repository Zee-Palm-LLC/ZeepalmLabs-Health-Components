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
  double _weightKg = 60;
  WeightUnit _unit = WeightUnit.kg;

  static const double _minKg = 30;
  static const double _maxKg = 90;
  static const double _kgToLbs = 2.20462;

  double get _displayValue =>
      _unit == WeightUnit.kg ? _weightKg : _weightKg * _kgToLbs;

  double get _minDisplay => _unit == WeightUnit.kg ? _minKg : _minKg * _kgToLbs;
  double get _maxDisplay => _unit == WeightUnit.kg ? _maxKg : _maxKg * _kgToLbs;

  void _setFromDial(double displayValue) {
    setState(() {
      final clamped = displayValue.clamp(_minDisplay, _maxDisplay);
      _weightKg = _unit == WeightUnit.kg ? clamped : clamped / _kgToLbs;
    });
  }

  void _switchUnit(WeightUnit unit) {
    if (unit == _unit) return;
    HapticFeedback.selectionClick();
    setState(() => _unit = unit);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialHeight = size.width * WeightDial.heightFactor + 14;
    final contentBottomInset = dialHeight - 36;

    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Column(
              children: [
                const TopNav(progress: 0.38),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      contentBottomInset,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _Entrance(
                          delay: Duration(milliseconds: 60),
                          child: _StepPill(),
                        ),
                        const SizedBox(height: 14),
                        const _Entrance(
                          delay: Duration(milliseconds: 120),
                          child: WeightBadge(),
                        ),
                        const SizedBox(height: 18),
                        const _Entrance(
                          delay: Duration(milliseconds: 180),
                          child: _Title(),
                        ),
                        const SizedBox(height: 20),
                        _Entrance(
                          delay: const Duration(milliseconds: 240),
                          child: _SelectionPanel(
                            unit: _unit,
                            value: _displayValue,
                            onUnitChanged: _switchUnit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: WeightDial(
                minValue: _minDisplay,
                maxValue: _maxDisplay,
                value: _displayValue,
                unitLabel: _unit == WeightUnit.kg ? 'kg' : 'lbs',
                onChanged: _setFromDial,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionPanel extends StatelessWidget {
  final WeightUnit unit;
  final double value;
  final ValueChanged<WeightUnit> onUnitChanged;

  const _SelectionPanel({
    required this.unit,
    required this.value,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          UnitToggle(unit: unit, onChanged: onUnitChanged),
          const SizedBox(height: 16),
          WeightBox(value: value, unit: unit),
          const SizedBox(height: 10),
          const CustomPaint(size: Size(16, 10), painter: TrianglePainter()),
        ],
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const _Entrance({required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    const offset = 0.16;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, v, childWidget) {
        final delayed =
            v * (1 - offset) + (delay.inMilliseconds / 600) * offset;
        final t = delayed.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

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
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
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
            style: AppType.body(
              size: 10.5,
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Your Current Weight',
          textAlign: TextAlign.center,
          style: AppType.display(size: 26),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Set your baseline so we can tailor goals and track your progress.',
            textAlign: TextAlign.center,
            style: AppType.body(size: 13),
          ),
        ),
      ],
    );
  }
}
