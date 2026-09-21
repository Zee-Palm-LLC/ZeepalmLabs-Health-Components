import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/store.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final _toggles = [true, true, false];

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = math.max(MediaQuery.viewPaddingOf(context).top, 20.0);
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 12.0);
    const settings = [
      (Glyph.bell, 'Care alerts', 'Missed doses and check-ins', Hue.coral),
      (Glyph.heart, 'Daily digest', 'A calm summary every evening', Hue.blush),
      (Glyph.moon, 'Quiet hours', '10 PM to 7 AM', Hue.iris),
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(18, top + 18, 18, bottom + 110),
      physics: const BouncingScrollPhysics(),
      children: [
        Staged(
          animation: _enter,
          begin: 0,
          end: 0.5,
          curve: Curves.easeOutBack,
          scale: 0.7,
          offset: Offset.zero,
          child: const Center(
            child: HaloAvatar(photo: 'assets/people/sara.webp', size: 104, halo: Hue.iris, glow: 1),
          ),
        ),
        const SizedBox(height: 14),
        Staged(
          animation: _enter,
          begin: 0.15,
          end: 0.55,
          child: Column(
            children: [
              Text('Sara Mitchell', style: jakarta(24, 800, spacing: -0.6)),
              const SizedBox(height: 4),
              const SoftChip(label: 'Circle admin', tone: Hue.iris, glyph: Glyph.sparkle, dense: true),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Staged(
          animation: _enter,
          begin: 0.25,
          end: 0.65,
          offset: const Offset(0, 20),
          child: Surface(
            radius: 24,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 40,
                  child: Stack(
                    children: [
                      for (final (i, member) in CareStore.members.indexed)
                        Positioned(
                          left: i * 17.0,
                          child: Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            padding: const EdgeInsets.all(2),
                            child: ClipOval(child: Portrait(member.photo, size: 36)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your circle', style: jakarta(15, 750)),
                      Text('5 members · 2 caregivers', style: jakarta(12.5, 550, color: Hue.inkSoft)),
                    ],
                  ),
                ),
                const GlyphIcon(Glyph.forward, size: 18, color: Hue.inkMute, stroke: 2),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Staged(
          animation: _enter,
          begin: 0.35,
          end: 0.75,
          offset: const Offset(0, 20),
          child: Surface(
            radius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (final (i, row) in settings.indexed) ...[
                  if (i > 0) const Divider(height: 1, color: Color(0xFFF3EEF6)),
                  SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        IconChip(glyph: row.$1, tone: row.$4, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row.$2, style: jakarta(14.5, 700)),
                              Text(row.$3, style: jakarta(12, 550, color: Hue.inkSoft)),
                            ],
                          ),
                        ),
                        _Toggle(on: _toggles[i], onChanged: (v) => setState(() => _toggles[i] = v)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Staged(
          animation: _enter,
          begin: 0.5,
          end: 0.9,
          curve: Curves.easeOutBack,
          offset: const Offset(0, 20),
          child: PrimaryButton(label: 'Invite to your circle', leading: Glyph.users, onTap: () {}),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: on ? Hue.irisGradient : null,
          color: on ? null : const Color(0xFFE6E0EC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
