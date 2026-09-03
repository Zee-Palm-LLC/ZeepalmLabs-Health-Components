import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:physio_motion/theme/app_colors.dart';

class QuickActionItem {
  const QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.tint,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color tint;
  final VoidCallback? onTap;
}

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    this.onEdit,
    this.actions = const [
      QuickActionItem(
        title: 'Pain',
        subtitle: 'Log',
        icon: Iconsax.flash_1,
        accent: AppColors.lime,
        tint: Color(0xFFF4FBE0),
      ),
      QuickActionItem(
        title: 'Posture',
        subtitle: 'Check',
        icon: Iconsax.people,
        accent: Color(0xFF5E5CE6),
        tint: Color(0xFFF0EFFF),
      ),
      QuickActionItem(
        title: 'Exercises',
        subtitle: 'Library',
        icon: Iconsax.play,
        accent: Color(0xFFB4E600),
        tint: Color(0xFFF4FBE0),
      ),
      QuickActionItem(
        title: 'Book',
        subtitle: 'Session',
        icon: Iconsax.calendar_1,
        accent: Color(0xFF5E5CE6),
        tint: Color(0xFFF0EFFF),
      ),
    ],
  });

  final VoidCallback? onEdit;
  final List<QuickActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quick Actions',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onEdit,
              child: Text(
                'Edit',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cobalt,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 54,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _ActionCard(item: actions[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({required this.item});

  final QuickActionItem item;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        item.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.tint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 17, color: item.accent),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
