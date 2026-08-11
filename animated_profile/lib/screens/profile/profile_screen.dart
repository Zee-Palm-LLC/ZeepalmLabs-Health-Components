import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../theme/app_colors.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _idleController;

  late final Animation<double> _rippleAnimation;
  late final Animation<double> _cardAnimation;
  late final Animation<double> _avatarHideAnimation;
  late final Animation<double> _avatarPopAnimation;
  late final Animation<double> _idleScale;
  late final ProfileStagger _stagger;

  bool _isBooked = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _idleScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _rippleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );

    _cardAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.82, curve: Curves.easeOutCubic),
    );

    _avatarHideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeInCubic),
      ),
    );

    _avatarPopAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeInBack),
      ),
    );

    _stagger = ProfileStagger(
      header: _sectionAnimation(0.60, 0.85),
      bio: _sectionAnimation(0.65, 0.88),
      stats: _sectionAnimation(0.70, 0.91),
      details: _sectionAnimation(0.78, 0.96),
      actions: _sectionAnimation(0.84, 0.99),
    );
  }

  Animation<double> _sectionAnimation(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  void _revealProfile() {
    if (_controller.isAnimating) return;

    _idleController.stop();
    _controller.forward(from: 0);
  }

  void _toggleBook() {
    setState(() {
      _isBooked = !_isBooked;
    });
  }

  void _callDoctor() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling City Heart Institute...'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: ColoredBox(color: AppColors.background),
                      ),
                      _BackgroundDecoration(size: size),
                      _Ripple(animation: _rippleAnimation, size: size),
                      _buildProfileContent(),
                      _buildAvatar(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _idleController]),
      builder: (context, child) {
        final hide = _avatarHideAnimation.value;
        final pop = _avatarPopAnimation.value;

        return Opacity(
          opacity: 1 - hide,
          child: Transform.scale(
            scale: _idleScale.value * (1 - (0.55 * pop)),
            child: GestureDetector(
              onTap: _revealProfile,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ProfileAvatar(),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.finger_scan,
                        size: 15,
                        color: AppColors.secondaryText.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap to view profile',
                        style: TextStyle(
                          color: AppColors.secondaryText.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    final card = _cardAnimation.value;

    return Opacity(
      opacity: card,
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - card)),
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ProfileCard(
                  stagger: _stagger,
                  isBooked: _isBooked,
                  onBook: _toggleBook,
                  onCall: _callDoctor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.5,
        child: Stack(
          children: [
            Positioned(
              left: -size.width * 0.25,
              top: size.height * 0.08,
              child: Container(
                width: size.width * 0.55,
                height: size.width * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withValues(alpha: 0.16),
                ),
              ),
            ),
            Positioned(
              right: -size.width * 0.20,
              bottom: size.height * 0.08,
              child: Container(
                width: size.width * 0.45,
                height: size.width * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ripple extends StatelessWidget {
  const _Ripple({required this.animation, required this.size});

  final Animation<double> animation;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final maxRadius =
        math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2)) * 0.75;
    final radius = 45 + (maxRadius * animation.value);

    return IgnorePointer(
      child: Center(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primaryLight.withValues(alpha: 0.70),
                AppColors.primaryLight.withValues(alpha: 0.32),
                AppColors.primaryLight.withValues(alpha: 0.10),
                AppColors.background.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.45, 0.75, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
