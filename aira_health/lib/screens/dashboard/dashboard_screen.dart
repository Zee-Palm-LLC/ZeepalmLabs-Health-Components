import 'package:aira_health/screens/voice/voice_screen.dart';
import 'package:aira_health/theme/app_theme.dart';
import 'package:aira_health/widgets/chrome.dart';
import 'package:aira_health/widgets/fade_reveal.dart';
import 'package:aira_health/widgets/slide_to_start.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              FadeReveal(
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/avatar_1.png'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stay Healthy', style: AiraType.body(size: 12)),
                          Text('Jenny Wilson', style: AiraType.title(size: 15)),
                        ],
                      ),
                    ),
                    const CircleIconButton(
                      icon: Icons.notifications_none_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FadeReveal(
                delay: const Duration(milliseconds: 90),
                child: GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health Assistant Plan',
                              style: AiraType.title(size: 15),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Upgrade Health Plan',
                                style: AiraType.body(
                                  size: 11,
                                  color: AiraColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset('assets/robot.png', height: 88),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              FadeReveal(
                delay: const Duration(milliseconds: 140),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Quick Health Access', style: AiraType.title()),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _AccessTile(
                      delay: 180,
                      icon: Icons.favorite_border_rounded,
                      title: 'Symptoms',
                      subtitle: 'Tell Symptoms Voice',
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(SoftFadeRoute(page: const VoiceScreen()));
                      },
                    ),
                    const _AccessTile(
                      delay: 230,
                      icon: Icons.description_outlined,
                      title: 'Reports',
                      subtitle: 'Scan Medical Report',
                    ),
                    const _AccessTile(
                      delay: 280,
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Consult',
                      subtitle: 'Talk to a Doctor',
                    ),
                    const _AccessTile(
                      delay: 330,
                      icon: Icons.grid_view_rounded,
                      title: 'Tools',
                      subtitle: 'Health & Wellness',
                    ),
                  ],
                ),
              ),
              FadeReveal(
                delay: const Duration(milliseconds: 380),
                child: SlideToStart(
                  label: 'Start Health Check',
                  leading: Icons.arrow_forward_rounded,
                  onComplete: () {
                    Navigator.of(
                      context,
                    ).push(SoftFadeRoute(page: const VoiceScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessTile extends StatelessWidget {
  const _AccessTile({
    required this.delay,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final int delay;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FadeReveal(
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          radius: 26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AiraColors.ink, size: 22),
              const Spacer(),
              Text(title, style: AiraType.title(size: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: AiraType.body(size: 11)),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.north_east_rounded, size: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
