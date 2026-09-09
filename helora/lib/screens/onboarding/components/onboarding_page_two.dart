import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helora/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

/// Onboarding page 2 — muted looping asset video + medical copy.
class OnboardingPageTwo extends StatefulWidget {
  const OnboardingPageTwo({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<OnboardingPageTwo> createState() => _OnboardingPageTwoState();
}

class _OnboardingPageTwoState extends State<OnboardingPageTwo> {
  late final VideoPlayerController _video;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.asset('assets/onboarding_page_two.webm')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _syncPlayback();
      });
  }

  @override
  void didUpdateWidget(covariant OnboardingPageTwo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncPlayback();
    }
  }

  void _syncPlayback() {
    if (!_ready) return;
    if (widget.isActive) {
      _video
        ..setVolume(0)
        ..play();
    } else {
      _video.pause();
    }
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _ready
              ? ClipRect(
                  child: Transform.translate(
                    // Kill VideoPlayer bottom hairline / edge seam.
                    offset: const Offset(0, 1),
                    child: Transform.scale(
                      scale: 1.03,
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: _video.value.size.width,
                          height: _video.value.size.height,
                          child: VideoPlayer(_video),
                        ),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.accent,
                    ),
                  ),
                ),
        ),

        SizedBox(height: 20),
        Text(
          'Find Verified\nSpecialists Nearby',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28,
            height: 1.18,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Browse licensed doctors and clinics —\nfilter by specialty, rating, and availability.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: AppColors.muted,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
