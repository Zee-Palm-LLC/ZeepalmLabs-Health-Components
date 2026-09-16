import 'package:flutter/material.dart';

import '../../../core/layout/artboard.dart';
import '../../../core/theme/app_colors.dart';
import '../data/onboarding_pages.dart';
import 'widgets/brand_header.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/page_indicator.dart';
import 'widgets/primary_pill_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageTransition = Duration(milliseconds: 560);

  final _controller = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == onboardingPages.length - 1;

  void _goTo(int index) {
    _controller.animateToPage(index, duration: _pageTransition, curve: Curves.easeOutCubic);
  }

  void _handlePrimaryAction() {
    if (_isLastPage) {
      widget.onCompleted?.call();
      return;
    }
    _goTo(_currentPage + 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Artboard(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: onboardingPages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => OnboardingPage(
                content: onboardingPages[index],
                index: index,
                controller: _controller,
                isActive: index == _currentPage,
              ),
            ),
            const Positioned(
              top: 64,
              left: 0,
              right: 0,
              child: IgnorePointer(child: BrandHeader()),
            ),
            Positioned(
              top: 653,
              left: 0,
              right: 0,
              child: Center(
                child: PageIndicator(
                  controller: _controller,
                  count: onboardingPages.length,
                  onSelected: _goTo,
                ),
              ),
            ),
            Positioned(
              top: 709,
              left: 97.5,
              width: 180,
              height: 50,
              child: PrimaryPillButton(label: 'Get Started', onPressed: _handlePrimaryAction),
            ),
          ],
        ),
      ),
    );
  }
}
