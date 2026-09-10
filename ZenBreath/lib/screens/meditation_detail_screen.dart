import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_text.dart';
import '../widgets/app_image.dart';
import '../widgets/motion.dart';
import 'breathing_session_screen.dart';

String meditationHeroTag(Meditation item) => 'meditation-${item.title}';

/// Unclipped poster shared by the library card and this screen, so the Hero
/// flight carries identical content at both ends. Each side supplies its own
/// [ClipRRect]; the shuttle below interpolates between the two radii.
class MeditationPoster extends StatelessWidget {
  const MeditationPoster({super.key, required this.item});

  final Meditation item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppImage(source: item.image, fallback: item.fallback),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.0),
                Colors.black.withValues(alpha: 0.18),
                Colors.black.withValues(alpha: 0.66),
              ],
              stops: const [0.32, 0.58, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// Eases the poster's corners from the grid card's all-round radius to the
/// header's square top and rounded bottom while it flies.
Widget meditationHeroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final push = direction == HeroFlightDirection.push;
  final hero = (push ? toHeroContext : fromHeroContext).widget as Hero;
  final t = push ? animation : ReverseAnimation(animation);
  final card = AppRadii.card;
  final sheet = AppRadii.sheet;

  return AnimatedBuilder(
    animation: t,
    child: hero.child,
    builder: (context, child) => ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(lerpDouble(card, 0, t.value)!),
        bottom: Radius.circular(lerpDouble(card, sheet, t.value)!),
      ),
      child: child,
    ),
  );
}

class MeditationDetailScreen extends StatelessWidget {
  const MeditationDetailScreen({super.key, required this.item});

  final Meditation item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(LucideIcons.chevronLeft, size: 24.r),
          color: Colors.white,
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppDecoration.pageGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 372.h,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadii.sheet)),
                child: Hero(
                  tag: meditationHeroTag(item),
                  flightShuttleBuilder: meditationHeroShuttle,
                  child: MeditationPoster(item: item),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Entrance(child: Text(item.title, style: AppText.display(30))),
                    SizedBox(height: 6.h),
                    Entrance(
                      delay: const Duration(milliseconds: 70),
                      child: Text(
                        item.subtitle,
                        style: AppText.body(14, color: AppColors.textSecondary),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Entrance(
                      delay: const Duration(milliseconds: 140),
                      child: Row(
                        children: [
                          _MetaChip(icon: LucideIcons.clock, label: item.duration),
                          SizedBox(width: 8.w),
                          _MetaChip(icon: LucideIcons.sparkles, label: item.category),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Entrance(
                      delay: const Duration(milliseconds: 210),
                      child: const _BeginSessionButton(),
                    ),
                    SizedBox(height: MediaQuery.paddingOf(context).bottom + 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeginSessionButton extends StatelessWidget {
  const _BeginSessionButton();

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const BreathingSessionScreen())),
      child: Container(
        height: 54.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.aqua,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: [
            BoxShadow(
              color: AppColors.aquaDeep.withValues(alpha: 0.30),
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.play, size: 16.r, color: AppColors.textPrimary),
            SizedBox(width: 8.w),
            Text('Begin Session', style: AppText.body(17, weight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.r, color: AppColors.aquaDeep),
          SizedBox(width: 5.w),
          Text(label, style: AppText.body(12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
