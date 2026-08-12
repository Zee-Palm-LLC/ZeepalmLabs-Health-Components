import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vital_weight/screens/weight/widgets/badge.dart';
import 'package:vital_weight/screens/weight/widgets/top_nav.dart';
import 'package:vital_weight/screens/weight/widgets/triangle_painter.dart';
import 'package:vital_weight/screens/weight/widgets/unit_toggle.dart';
import 'package:vital_weight/screens/weight/widgets/weight_box.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3D6EE),
              Color(0xFFCBE7EA),
              Color(0xFFF3F6F4),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.28, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const TopNav(progress: 0.38),
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const WeightBadge(),
                      const SizedBox(height: 18),
                      const Text(
                        'Your Current Weight',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1F1E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Enter your weight to set a baseline for personalized goals and progress tracking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      UnitToggle(unit: _unit, onChanged: _switchUnit),
                      const SizedBox(height: 22),
                      WeightBox(value: _displayValue, unit: _unit),
                      const SizedBox(height: 6),
                      const CustomPaint(
                        size: Size(18, 12),
                        painter: TrianglePainter(),
                      ),
                    ],
                  ),
                ),
              ),
              WeightDial(
                minValue: _minDisplay,
                maxValue: _maxDisplay,
                value: _displayValue,
                unitLabel: _unit == WeightUnit.kg ? 'kg' : 'lbs',
                onChanged: _setFromDial,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Weight saved: ${_displayValue.toStringAsFixed(1)} '
                            '${_unit == WeightUnit.kg ? "kg" : "lbs"}',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25B95C),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0xFF25B95C).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
