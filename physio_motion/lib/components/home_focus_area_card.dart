import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:physio_motion/theme/app_colors.dart';

class HomeFocusAreaCard extends StatefulWidget {
  const HomeFocusAreaCard({
    super.key,
    this.title = 'Lower Back',
    this.highlight = 'Recovery',
    this.status = 'Improving',
    this.onExplore,
  });

  final String title;
  final String highlight;
  final String status;
  final VoidCallback? onExplore;

  @override
  State<HomeFocusAreaCard> createState() => _HomeFocusAreaCardState();
}

class _HomeFocusAreaCardState extends State<HomeFocusAreaCard>
    with TickerProviderStateMixin {
  late final AnimationController _press;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.96,
      upperBound: 1,
      value: 1,
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _press.dispose();
    _glow.dispose();
    super.dispose();
  }

  Future<void> _handleExplore() async {
    await _press.reverse();
    await _press.forward();
    widget.onExplore?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final limeGlow = 0.06 + _glow.value * 0.08;
        return Container(
          height: 112,
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF141414),
                AppColors.dark,
                Color(0xFF0C0C0C),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.lime.withValues(alpha: limeGlow),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _glow,
            builder: (context, _) {
              return Container(
                width: 4,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(
                    alpha: 0.75 + _glow.value * 0.25,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lime.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Focus Area',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB24DFF).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.status,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD4B4FF),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.title} ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          letterSpacing: -0.5,
                          color: AppColors.white,
                        ),
                      ),
                      TextSpan(
                        text: widget.highlight,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          letterSpacing: -0.5,
                          color: AppColors.lime,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Targeted session ready',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ScaleTransition(
            scale: _press,
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: _handleExplore,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Iconsax.arrow_right_3,
                        size: 14,
                        color: AppColors.textPrimary,
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
