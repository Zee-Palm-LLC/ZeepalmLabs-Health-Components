import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicify/components/metric_picker_chrome.dart';
import 'package:medicify/components/onboarding_scaffold.dart';
import 'package:medicify/components/unit_toggle.dart';
import 'package:medicify/screens/onboarding/onboarding_data.dart';
import 'package:medicify/screens/onboarding/onboarding_flow.dart';
import 'package:medicify/theme/app_colors.dart';

class WeightStep extends StatefulWidget {
  const WeightStep({
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
  State<WeightStep> createState() => _WeightStepState();
}

class _WeightStepState extends State<WeightStep> {
  late final ScrollController _controller;
  static const _itemWidth = 88.0;
  static const _min = 30;
  static const _max = 200;
  bool _snapping = false;

  @override
  void initState() {
    super.initState();
    final index = (widget.data.weight - _min).clamp(0, _max - _min);
    _controller = ScrollController(
      initialScrollOffset: index * _itemWidth,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _index =>
      (_controller.hasClients
              ? (_controller.offset / _itemWidth).round()
              : widget.data.weight - _min)
          .clamp(0, _max - _min);

  void _applyIndex(int index) {
    final value = _min + index;
    if (value != widget.data.weight) {
      HapticFeedback.selectionClick();
      widget.data.weight = value;
      widget.onChanged();
    }
  }

  Future<void> _snap() async {
    if (!_controller.hasClients || _snapping) return;
    final index = _index;
    final target = index * _itemWidth;
    if ((_controller.offset - target).abs() < 0.5) {
      _applyIndex(index);
      return;
    }
    _snapping = true;
    await _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    _snapping = false;
    _applyIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final count = _max - _min + 1;
    final unit = widget.data.weightKg ? 'kg' : 'lbs';

    return OnboardingScaffold(
      step: widget.step,
      totalSteps: OnboardingFlow.totalSteps,
      eyebrow: 'Body metrics',
      title: "What's your current\nweight?",
      subtitle: 'This is simply your starting point.',
      continueLabel: 'Get started',
      onBack: widget.onBack,
      onContinue: widget.onContinue,
      child: Column(
        children: [
          MetricValueCard(
            value: '${widget.data.weight}',
            trailing: MetricChip(label: unit),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: LayoutBuilder(
                builder: (context, constraints) {
                  final sidePad =
                      ((constraints.maxWidth - _itemWidth) / 2).clamp(0.0, 9999.0);
                  return NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollUpdateNotification) {
                        _applyIndex(_index);
                      }
                      if (n is ScrollEndNotification) {
                        _snap();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: sidePad),
                      itemCount: count,
                      itemBuilder: (context, index) {
                        final value = _min + index;
                        final selected = value == widget.data.weight;
                        return SizedBox(
                          width: _itemWidth,
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 160),
                              style: GoogleFonts.inter(
                                fontSize: selected ? 48 : 26,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                height: 1,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary
                                        .withValues(alpha: 0.35),
                              ),
                              child: Text(
                                '$value',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ),
          const SizedBox(height: 14),
          UnitToggle(
            left: 'kg',
            right: 'lbs',
            leftSelected: widget.data.weightKg,
            onChanged: (kg) {
              widget.data.weightKg = kg;
              widget.onChanged();
            },
          ),
        ],
      ),
    );
  }
}
