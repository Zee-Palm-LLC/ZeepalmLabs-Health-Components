import 'package:aira_health/theme/app_theme.dart';
import 'package:aira_health/widgets/chrome.dart';
import 'package:aira_health/widgets/fade_reveal.dart';
import 'package:aira_health/widgets/liquid_orb.dart';
import 'package:flutter/material.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Column(
            children: [
              FadeReveal(
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Symptom Voice Assistant',
                        textAlign: TextAlign.center,
                        style: AiraType.title(size: 15),
                      ),
                    ),
                    const CircleIconButton(icon: Icons.more_vert_rounded),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              const FadeReveal(
                delay: Duration(milliseconds: 80),
                child: LiquidOrb(size: 230),
              ),
              const SizedBox(height: 28),
              FadeReveal(
                delay: const Duration(milliseconds: 160),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Please describe your symptoms using your voice. Our health assistant will guide you based on the information you provide and help you understand possible next steps.',
                    textAlign: TextAlign.center,
                    style: AiraType.body(size: 13),
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FadeReveal(
                delay: const Duration(milliseconds: 240),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CircleIconButton(
                      icon: Icons.chat_bubble_outline_rounded,
                    ),
                    const LiquidOrb(size: 64),
                    CircleIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
