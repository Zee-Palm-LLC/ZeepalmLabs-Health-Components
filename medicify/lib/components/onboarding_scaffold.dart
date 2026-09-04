import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:medicify/components/continue_button.dart';
import 'package:medicify/components/fade_slide_in.dart';
import 'package:medicify/components/onboarding_progress_bar.dart';
import 'package:medicify/theme/app_colors.dart';

class OnboardingScaffold extends StatefulWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onContinue,
    this.onBack,
    this.footer,
    this.canContinue = true,
    this.eyebrow,
    this.continueLabel = 'Continue',
    this.continueHint,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  final Widget? footer;
  final bool canContinue;
  final String? eyebrow;
  final String continueLabel;
  final String? continueHint;

  /// Shared entrance controller for staggered children.
  static Animation<double>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_OnboardingEnterScope>()
        ?.animation;
  }

  @override
  State<OnboardingScaffold> createState() => _OnboardingScaffoldState();
}

class _OnboardingEnterScope extends InheritedWidget {
  const _OnboardingEnterScope({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  @override
  bool updateShouldNotify(covariant _OnboardingEnterScope oldWidget) =>
      animation != oldWidget.animation;
}

class _OnboardingScaffoldState extends State<OnboardingScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.step + 1) / widget.totalSteps;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    const floatingBarHeight = 96.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const _AmbientBackground(),
          SafeArea(
            bottom: false,
            child: _OnboardingEnterScope(
              animation: _enter,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      floatingBarHeight + bottomPad + 12,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        FadeSlideIn(
                          animation: _enter,
                          begin: 0,
                          end: 0.28,
                          offset: const Offset(0, -8),
                          child: Row(
                            children: [
                              _BackButton(
                                onTap: widget.onBack ??
                                    () => Navigator.maybePop(context),
                              ),
                              const Spacer(),
                              _StepPill(
                                step: widget.step + 1,
                                total: widget.totalSteps,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeSlideIn(
                          animation: _enter,
                          begin: 0.04,
                          end: 0.35,
                          offset: const Offset(0, 8),
                          child: OnboardingProgressBar(
                            progress: progress,
                            step: widget.step,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (widget.eyebrow != null) ...[
                          FadeSlideIn(
                            animation: _enter,
                            begin: 0.1,
                            end: 0.4,
                            offset: const Offset(0, 8),
                            child: Text(
                              widget.eyebrow!.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AppColors.purple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        FadeSlideIn(
                          animation: _enter,
                          begin: 0.12,
                          end: 0.48,
                          offset: const Offset(0, 16),
                          child: Text(
                            widget.title,
                            style: GoogleFonts.inter(
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                              letterSpacing: -0.9,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeSlideIn(
                          animation: _enter,
                          begin: 0.2,
                          end: 0.52,
                          offset: const Offset(0, 12),
                          child: Text(
                            widget.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          animation: _enter,
                          begin: 0.22,
                          end: 0.72,
                          offset: const Offset(0, 18),
                          child: widget.child,
                        ),
                        if (widget.footer != null) ...[
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            animation: _enter,
                            begin: 0.5,
                            end: 0.9,
                            offset: const Offset(0, 14),
                            child: widget.footer!,
                          ),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating continue bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeSlideIn(
              animation: _enter,
              begin: 0.58,
              end: 1,
              offset: const Offset(0, 20),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.bg.withValues(alpha: 0),
                        AppColors.bg.withValues(alpha: 0.92),
                        AppColors.bg,
                      ],
                      stops: const [0, 0.35, 1],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 28, 20, 12 + bottomPad),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ContinueButton(
                          label: widget.continueLabel,
                          onPressed: widget.canContinue
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  widget.onContinue();
                                }
                              : null,
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          child: !widget.canContinue &&
                                  widget.continueHint != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    widget.continueHint!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatefulWidget {
  const _AmbientBackground();

  @override
  State<_AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<_AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ambient,
      builder: (context, _) {
        final t = _ambient.value;
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -90 + math.sin(t * math.pi) * 10,
                right: -70,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.purple.withValues(alpha: 0.11 + t * 0.05),
                        AppColors.purple.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                left: -90,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFB86C)
                            .withValues(alpha: 0.07 + (1 - t) * 0.04),
                        const Color(0xFFFFB86C).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle grain-like dots
              CustomPaint(
                size: Size.infinite,
                painter: _DotFieldPainter(progress: t),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DotFieldPainter extends CustomPainter {
  _DotFieldPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.035);
    final rnd = math.Random(7);
    for (var i = 0; i < 28; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = 1.0 + (i % 3) * 0.6 + progress * 0.3;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotFieldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.purple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'Step $step of $total',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.92 : 1,
        duration: const Duration(milliseconds: 110),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Iconsax.arrow_left_2,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
