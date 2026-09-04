import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicify/components/metric_picker_chrome.dart';
import 'package:medicify/components/onboarding_scaffold.dart';
import 'package:medicify/screens/onboarding/onboarding_data.dart';
import 'package:medicify/screens/onboarding/onboarding_flow.dart';
import 'package:medicify/theme/app_colors.dart';

class BirthdayStep extends StatefulWidget {
  const BirthdayStep({
    super.key,
    required this.step,
    required this.data,
    required this.onChanged,
    required this.onContinue,
    required this.onBack,
  });

  final int step;
  final OnboardingData data;
  final VoidCallback onChanged;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  State<BirthdayStep> createState() => _BirthdayStepState();
}

class _BirthdayStepState extends State<BirthdayStep> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _minYear = 1920;
  late final int _maxYear = DateTime.now().year;

  late FixedExtentScrollController _dayCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _yearCtrl;

  int get _day => widget.data.birthday.day;
  int get _month => widget.data.birthday.month;
  int get _year => widget.data.birthday.year;

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;

  String get _label => '$_day ${_months[_month - 1]} $_year';

  int get _age {
    final now = DateTime.now();
    var age = now.year - _year;
    if (now.month < _month || (now.month == _month && now.day < _day)) {
      age--;
    }
    return age.clamp(0, 120);
  }

  @override
  void initState() {
    super.initState();
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _yearCtrl = FixedExtentScrollController(
      initialItem: (_year - _minYear).clamp(0, _maxYear - _minYear),
    );
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _commit({int? day, int? month, int? year}) {
    final m = month ?? _month;
    final y = year ?? _year;
    final maxDay = DateTime(y, m + 1, 0).day;
    final d = (day ?? _day).clamp(1, maxDay);

    if (d != _day && _dayCtrl.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dayCtrl.hasClients) {
          _dayCtrl.jumpToItem(d - 1);
        }
      });
    }

    final next = DateTime(y, m, d);
    if (next != widget.data.birthday) {
      HapticFeedback.selectionClick();
      widget.data.birthday = next;
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: widget.step,
      totalSteps: OnboardingFlow.totalSteps,
      eyebrow: 'About you',
      title: "When's your birthday?",
      subtitle: "We'll use this to personalize your experience.",
      onBack: widget.onBack,
      onContinue: widget.onContinue,
      child: Column(
        children: [
          MetricValueCard(
            value: _label,
            caption: '$_age years old',
            trailing: const MetricChip(label: 'DOB'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Row(
                      children: [
                        Expanded(child: _colLabel('Day')),
                        Expanded(flex: 2, child: _colLabel('Month')),
                        Expanded(flex: 2, child: _colLabel('Year')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _DateWheel(
                                key: ValueKey(
                                  'd-$_daysInMonth-$_month-$_year',
                                ),
                                controller: _dayCtrl,
                                itemCount: _daysInMonth,
                                labelBuilder: (i) => '${i + 1}',
                                selectedIndex:
                                    (_day - 1).clamp(0, _daysInMonth - 1),
                                onSelected: (i) => _commit(day: i + 1),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _DateWheel(
                                controller: _monthCtrl,
                                itemCount: 12,
                                labelBuilder: (i) => _months[i],
                                selectedIndex: _month - 1,
                                onSelected: (i) => _commit(month: i + 1),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _DateWheel(
                                controller: _yearCtrl,
                                itemCount: _maxYear - _minYear + 1,
                                labelBuilder: (i) => '${_minYear + i}',
                                selectedIndex: (_year - _minYear)
                                    .clamp(0, _maxYear - _minYear),
                                onSelected: (i) =>
                                    _commit(year: _minYear + i),
                              ),
                            ),
                          ],
                        ),
                        IgnorePointer(
                          child: Column(
                            children: [
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.bg.withValues(alpha: 0.95),
                                      AppColors.bg.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.bg.withValues(alpha: 0.95),
                                      AppColors.bg.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _colLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
    );
  }
}

class _DateWheel extends StatelessWidget {
  const _DateWheel({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.selectedIndex,
    required this.onSelected,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) labelBuilder;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 48,
      perspective: 0.003,
      diameterRatio: 1.45,
      physics: const FixedExtentScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      onSelectedItemChanged: onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final selected = index == selectedIndex;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: GoogleFonts.inter(
                fontSize: selected ? 26 : 18,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                height: 1,
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.4),
              ),
              child: Text(
                labelBuilder(index),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
