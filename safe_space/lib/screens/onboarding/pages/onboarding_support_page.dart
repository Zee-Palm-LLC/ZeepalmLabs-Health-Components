import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import '../widgets/floating_motion.dart';

/// Page 3 — stacked support cards. Animation: staggered slide + ambient glow.
class OnboardingSupportPage extends StatefulWidget {
  const OnboardingSupportPage({super.key, required this.visible});

  final bool visible;

  @override
  State<OnboardingSupportPage> createState() => _OnboardingSupportPageState();
}

class _OnboardingSupportPageState extends State<OnboardingSupportPage>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    if (widget.visible) _play();
  }

  @override
  void didUpdateWidget(covariant OnboardingSupportPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _play();
    } else if (!widget.visible && oldWidget.visible) {
      _entrance.reset();
      _ambient.stop();
    }
  }

  void _play() {
    _entrance.forward(from: 0);
    _ambient.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  Animation<double> _fade(double begin, double end) {
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slide(double begin, double end, Offset from) {
    return Tween<Offset>(begin: from, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _ambient,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_ambient.value);
            return Stack(
              children: [
                Positioned(
                  top: 40 + t * 12,
                  right: -30,
                  child: _AmbientBlob(
                    size: 140,
                    color: AppColors.lavender.withValues(alpha: 0.22),
                  ),
                ),
                Positioned(
                  top: 160 - t * 10,
                  left: -40,
                  child: _AmbientBlob(
                    size: 120,
                    color: AppColors.peach.withValues(alpha: 0.2),
                  ),
                ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              FadeTransition(
                opacity: _fade(0, 0.35),
                child: SlideTransition(
                  position: _slide(0, 0.4, const Offset(0, -0.08)),
                  child: const _AvatarCluster(),
                ),
              ),
              const SizedBox(height: 18),
              FadeTransition(
                opacity: _fade(0.08, 0.45),
                child: SlideTransition(
                  position: _slide(0.08, 0.5, const Offset(-0.16, 0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.peach.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'Feel supported',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: const Color(0xFFB07A8C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You never have\nto carry it alone',
                        style: GoogleFonts.libreBaskerville(
                          fontSize: height < 700 ? 25 : 27,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.4,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _fade(0.18, 0.55),
                child: SlideTransition(
                  position: _slide(0.18, 0.6, const Offset(0, 0.08)),
                  child: Text(
                    'Prompts, reflections, and a calm community help you feel held — on your own timeline.',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      height: 1.5,
                      color: AppColors.body,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _fade(0.28, 0.68),
                      child: SlideTransition(
                        position: _slide(0.28, 0.72, const Offset(0.22, 0)),
                        child: FloatingMotion(
                          amplitude: 3.5,
                          duration: const Duration(milliseconds: 3200),
                          child: const _SupportCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Guided reflections',
                            subtitle: 'Short prompts when words are hard',
                            background: AppColors.cardLavender,
                            alignEnd: false,
                            iconColor: Color(0xFF7B6FA8),
                            badge: 'New',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _fade(0.4, 0.8),
                      child: SlideTransition(
                        position: _slide(0.4, 0.84, const Offset(-0.22, 0)),
                        child: FloatingMotion(
                          amplitude: 4.5,
                          delay: const Duration(milliseconds: 160),
                          duration: const Duration(milliseconds: 3600),
                          child: const _SupportCard(
                            icon: Icons.nights_stay_rounded,
                            title: 'Night check-ins',
                            subtitle: 'Unwind without pressure to perform',
                            background: AppColors.cardCream,
                            alignEnd: true,
                            iconColor: Color(0xFFC4A574),
                            badge: 'Evening',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _fade(0.52, 0.95),
                      child: SlideTransition(
                        position: _slide(0.52, 0.98, const Offset(0.18, 0.06)),
                        child: FloatingMotion(
                          amplitude: 3.5,
                          delay: const Duration(milliseconds: 280),
                          duration: const Duration(milliseconds: 3000),
                          child: const _SupportCard(
                            icon: Icons.favorite_border_rounded,
                            title: 'Soft community',
                            subtitle: 'Share only what feels right',
                            background: AppColors.softLavender,
                            alignEnd: false,
                            iconColor: Color(0xFFB07A8C),
                            badge: 'Safe',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FadeTransition(
                opacity: _fade(0.65, 1),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4, top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: AppColors.muted.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Private by default. You choose what to share.',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmbientBlob extends StatelessWidget {
  const _AmbientBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _AvatarCluster extends StatelessWidget {
  const _AvatarCluster();

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFE8D4C4),
      Color(0xFFD4CEE9),
      Color(0xFFF0E0C8),
      Color(0xFFD8E4F0),
    ];
    const initials = ['A', 'M', 'S', 'J'];

    return SizedBox(
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < colors.length; i++)
            Positioned(
              left: i * 28.0,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i],
                  border: Border.all(color: AppColors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initials[i],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
          Positioned(
            left: colors.length * 28.0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.ink,
                border: Border.all(color: AppColors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '+12',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 8,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Here with you',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
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

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.alignEnd,
    required this.iconColor,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final bool alignEnd;
  final Color iconColor;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.94,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.2,
                        height: 1.35,
                        color: AppColors.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.muted.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
