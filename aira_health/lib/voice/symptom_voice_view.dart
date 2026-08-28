import 'package:aira_health/onboarding/components/fade_reveal.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/voice/widgets/liquid_orb.dart';
import 'package:aira_health/voice/widgets/voice_chrome_button.dart';
import 'package:aira_health/voice/widgets/voice_detail_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SymptomVoiceView extends StatefulWidget {
  const SymptomVoiceView({super.key});

  @override
  State<SymptomVoiceView> createState() => _SymptomVoiceViewState();
}

class _SymptomVoiceViewState extends State<SymptomVoiceView> {
  bool _listening = false;

  void _toggleListening() {
    HapticFeedback.mediumImpact();
    setState(() => _listening = !_listening);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PrimaryBg(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                FadeReveal(
                  delay: Duration.zero,
                  duration: const Duration(milliseconds: 400),
                  child: _VoiceTopBar(
                    onBack: () => Get.back(),
                  ),
                ),
                SizedBox(height: 32.h),
                FadeReveal(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 520),
                  scaleBegin: 0.88,
                  child: LiquidOrb(
                    size: 200.w,
                    listening: _listening,
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: FadeReveal(
                    delay: const Duration(milliseconds: 160),
                    duration: const Duration(milliseconds: 480),
                    child: VoiceDetailFeed(listening: _listening),
                  ),
                ),
                FadeReveal(
                  delay: const Duration(milliseconds: 260),
                  offsetY: 14,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 28.h, top: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        VoiceChromeButton(
                          icon: Iconsax.message,
                          onTap: () {},
                        ),
                        LiquidOrb(
                          size: 58.w,
                          listening: _listening,
                          onTap: _toggleListening,
                        ),
                        VoiceChromeButton(
                          icon: Iconsax.close_circle,
                          onTap: () => Get.back(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceTopBar extends StatelessWidget {
  const _VoiceTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VoiceChromeButton(
          icon: Iconsax.arrow_left_2,
          onTap: onBack,
          size: 44.w,
        ),
        Expanded(
          child: Text(
            'Symptom Voice Assistant',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: PrimaryBgColors.title,
              letterSpacing: -0.2,
            ),
          ),
        ),
        VoiceChromeButton(
          icon: Iconsax.more,
          onTap: () {},
          size: 44.w,
        ),
      ],
    );
  }
}
