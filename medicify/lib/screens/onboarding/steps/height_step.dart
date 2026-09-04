import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicify/components/metric_picker_chrome.dart';
import 'package:medicify/components/onboarding_scaffold.dart';
import 'package:medicify/components/unit_toggle.dart';
import 'package:medicify/screens/onboarding/onboarding_data.dart';
import 'package:medicify/screens/onboarding/onboarding_flow.dart';
import 'package:medicify/theme/app_colors.dart';

class HeightStep extends StatefulWidget {
  const HeightStep({
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
  State<HeightStep> createState() => _HeightStepState();
}

class _HeightStepState extends State<HeightStep> {
  late FixedExtentScrollController _cmCtrl;
  late FixedExtentScrollController _feetCtrl;
  late FixedExtentScrollController _inchCtrl;

  @override
  void initState() {
    super.initState();
    _cmCtrl = FixedExtentScrollController(
      initialItem: (widget.data.heightCm - 120).clamp(0, 120),
    );
    _feetCtrl = FixedExtentScrollController(
      initialItem: (widget.data.heightFeet - 4).clamp(0, 4),
    );
    _inchCtrl = FixedExtentScrollController(
      initialItem: widget.data.heightInches.clamp(0, 11),
    );
  }

  @override
  void dispose() {
    _cmCtrl.dispose();
    _feetCtrl.dispose();
    _inchCtrl.dispose();
    super.dispose();
  }

  String get _label {
    if (widget.data.heightImperial) {
      return "${widget.data.heightFeet}' ${widget.data.heightInches}\"";
    }
    return '${widget.data.heightCm}';
  }

  String get _unitChip => widget.data.heightImperial ? 'ft/in' : 'cm';

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: widget.step,
      totalSteps: OnboardingFlow.totalSteps,
      eyebrow: 'Body metrics',
      title: 'How tall are you?',
      subtitle: 'This helps us understand your starting point.',
      onBack: widget.onBack,
      onContinue: widget.onContinue,
      child: Column(
        children: [
          MetricValueCard(
            value: widget.data.heightImperial ? _label : '$_label cm',
            trailing: MetricChip(label: _unitChip),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: Stack(
                alignment: Alignment.center,
                children: [
                  widget.data.heightImperial
                      ? Row(
                          children: [
                            Expanded(
                              child: _HeightWheel(
                                controller: _feetCtrl,
                                itemCount: 5,
                                labelBuilder: (i) => "${i + 4}'",
                                selectedIndex:
                                    (widget.data.heightFeet - 4).clamp(0, 4),
                                onSelected: (i) {
                                  HapticFeedback.selectionClick();
                                  widget.data.heightFeet = i + 4;
                                  widget.onChanged();
                                },
                              ),
                            ),
                            Expanded(
                              child: _HeightWheel(
                                controller: _inchCtrl,
                                itemCount: 12,
                                labelBuilder: (i) => '$i"',
                                selectedIndex:
                                    widget.data.heightInches.clamp(0, 11),
                                onSelected: (i) {
                                  HapticFeedback.selectionClick();
                                  widget.data.heightInches = i;
                                  widget.onChanged();
                                },
                              ),
                            ),
                          ],
                        )
                      : _HeightWheel(
                          controller: _cmCtrl,
                          itemCount: 121,
                          labelBuilder: (i) => '${i + 120}',
                          selectedIndex:
                              (widget.data.heightCm - 120).clamp(0, 120),
                          onSelected: (i) {
                            HapticFeedback.selectionClick();
                            widget.data.heightCm = i + 120;
                            widget.onChanged();
                          },
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
          const SizedBox(height: 14),
          UnitToggle(
            left: 'ft/in',
            right: 'cm',
            leftSelected: widget.data.heightImperial,
            onChanged: (imperial) {
              widget.data.heightImperial = imperial;
              widget.onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _HeightWheel extends StatelessWidget {
  const _HeightWheel({
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
                fontSize: selected ? 32 : 20,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                height: 1,
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.38),
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
