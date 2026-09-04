import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicify/screens/onboarding/onboarding_data.dart';
import 'package:medicify/screens/onboarding/steps/birthday_step.dart';
import 'package:medicify/screens/onboarding/steps/discovery_step.dart';
import 'package:medicify/screens/onboarding/steps/goal_step.dart';
import 'package:medicify/screens/onboarding/steps/height_step.dart';
import 'package:medicify/screens/onboarding/steps/language_step.dart';
import 'package:medicify/screens/onboarding/steps/weight_step.dart';
import 'package:medicify/theme/app_colors.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  static const totalSteps = 6;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _data = OnboardingData();
  int _step = 0;

  void _goTo(int index) {
    HapticFeedback.selectionClick();
    setState(() => _step = index);
  }

  void _next() {
    if (_step < OnboardingFlow.totalSteps - 1) {
      _goTo(_step + 1);
    } else {
      _showWelcome();
    }
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  void _showWelcome() {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Welcome',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, anim, secondary) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim, secondary, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(curved),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.28),
                        blurRadius: 48,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.purpleSoft,
                              AppColors.purpleSoft.withValues(alpha: 0),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset('assets/bear.png', height: 88),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You're all set!",
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome to Medicify — your personal health companion is ready.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [AppColors.purple, AppColors.purpleDeep],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purple.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Let's go",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stepFor(int index) {
    return switch (index) {
      0 => LanguageStep(
          key: const ValueKey('lang'),
          step: 0,
          data: _data,
          onChanged: () => setState(() {}),
          onContinue: _next,
          onBack: _back,
        ),
      1 => DiscoveryStep(
          key: const ValueKey('discovery'),
          step: 1,
          data: _data,
          onChanged: () => setState(() {}),
          onContinue: _next,
          onBack: _back,
        ),
      2 => GoalStep(
          key: const ValueKey('goal'),
          step: 2,
          data: _data,
          onChanged: () => setState(() {}),
          onContinue: _next,
          onBack: _back,
        ),
      3 => BirthdayStep(
          key: const ValueKey('bday'),
          step: 3,
          data: _data,
          onChanged: () => setState(() {}),
          onContinue: _next,
          onBack: _back,
        ),
      4 => HeightStep(
          key: const ValueKey('height'),
          step: 4,
          data: _data,
          onChanged: () => setState(() {}),
          onContinue: _next,
          onBack: _back,
        ),
      _ => WeightStep(
          key: const ValueKey('weight'),
          step: 5,
          data: _data,
          onChanged: () => setState(() {}),
          onContinue: _next,
          onBack: _back,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 640),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              ?currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          // Sequential: old fades out first half, new fades in second half.
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.42, 1.0, curve: Curves.easeOutCubic),
            reverseCurve: const Interval(0.0, 0.48, curve: Curves.easeInCubic),
          );
          return FadeTransition(
            opacity: fade,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_step),
          child: _stepFor(_step),
        ),
      ),
    );
  }
}
