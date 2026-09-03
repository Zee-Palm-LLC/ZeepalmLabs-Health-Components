import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:physio_motion/theme/app_colors.dart';

class HomeRecoveryCard extends StatefulWidget {
  const HomeRecoveryCard({
    super.key,
    this.score = 74,
    this.deltaPercent = 12,
    this.message = "Keep going! You're improving.",
  });

  final int score;
  final int deltaPercent;
  final String message;

  @override
  State<HomeRecoveryCard> createState() => _HomeRecoveryCardState();
}

class _HomeRecoveryCardState extends State<HomeRecoveryCard>
    with TickerProviderStateMixin {
  static const double _cardHeight = 198;
  static const double _imageOverflow = 24;

  late final AnimationController _enter;
  late final AnimationController _pulse;
  late final AnimationController _shimmer;
  late final Animation<double> _scoreAnim;
  late final Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnim = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
    );
    _ringAnim = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardHeight + _imageOverflow,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: _imageOverflow,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: AppColors.lime.withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -30,
                    bottom: -30,
                    width: 180,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.2, -0.1),
                            radius: 0.9,
                            colors: [
                              AppColors.lime.withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Soft diagonal shimmer wash
                  AnimatedBuilder(
                    animation: _shimmer,
                    builder: (context, _) {
                      final t = _shimmer.value;
                      return IgnorePointer(
                        child: Transform.translate(
                          offset: Offset(-80 + t * 280, 0),
                          child: Transform.rotate(
                            angle: -0.55,
                            child: Container(
                              width: 70,
                              height: 320,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.045),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 148, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S RECOVERY",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.15,
                            color: AppColors.lime,
                          ),
                        ),
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _scoreAnim,
                          builder: (context, _) {
                            final value =
                                (widget.score * _scoreAnim.value).round();
                            return Text(
                              '$value%',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                height: 0.95,
                                letterSpacing: -1.8,
                                color: AppColors.white,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        AnimatedBuilder(
                          animation: _ringAnim,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: SizedBox(
                                height: 3,
                                width: 118,
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.white.withValues(alpha: 0.12),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: (_ringAnim.value *
                                              (widget.score / 100))
                                          .clamp(0.0, 1.0),
                                      child: Container(color: AppColors.lime),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                            color: AppColors.white.withValues(alpha: 0.88),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lime.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.arrow_up_1,
                                size: 13,
                                color: AppColors.lime,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${widget.deltaPercent}% vs yesterday',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lime,
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
          ),
          Positioned(
            top: 0,
            right: 4,
            bottom: 6,
            width: 142,
            child: AnimatedBuilder(
              animation: _enter,
              builder: (context, child) {
                final t = Curves.easeOutCubic.transform(
                  ((_enter.value - 0.1) / 0.7).clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(18 * (1 - t), 10 * (1 - t)),
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * t,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/banner.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _HotspotPulsePainter(progress: _pulse.value),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotspotPulsePainter extends CustomPainter {
  const _HotspotPulsePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final spots = <(Offset, Color)>[
      (Offset(size.width * 0.52, size.height * 0.18), AppColors.lime),
      (Offset(size.width * 0.28, size.height * 0.32), AppColors.lime),
      (Offset(size.width * 0.70, size.height * 0.34), const Color(0xFFB24DFF)),
      (Offset(size.width * 0.50, size.height * 0.62), const Color(0xFFB24DFF)),
    ];

    for (var i = 0; i < spots.length; i++) {
      final (center, color) = spots[i];
      final phase = (progress + i * 0.18) % 1.0;
      final radius = 8 + phase * 22;
      final opacity = (1 - phase) * 0.45;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;

      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(
        center,
        radius * 0.55,
        Paint()
          ..color = color.withValues(alpha: opacity * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );

      canvas.drawCircle(
        center,
        3.5 + math.sin(phase * math.pi) * 1.5,
        Paint()..color = color.withValues(alpha: 0.35 + opacity * 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HotspotPulsePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
