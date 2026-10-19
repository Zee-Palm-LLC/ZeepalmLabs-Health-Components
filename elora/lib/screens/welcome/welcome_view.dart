import 'package:elora/screens/auth/sign_up_view.dart';
import 'package:elora/screens/welcome/components/health_preview_card.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _starScale;
  late final Animation<double> _starOpacity;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _headlineSlide;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonOpacity;
  late final Animation<Offset> _buttonSlide;

  final bool _showNextScreen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _starScale = Tween<double>(begin: 0.15, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack),
      ),
    );

    _starOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
      ),
    );

    _contentOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.52, 0.76, curve: Curves.easeOut),
    );

    _headlineSlide =
        Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.52, 0.78, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.62, 0.84, curve: Curves.easeOutCubic),
          ),
        );

    _buttonOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 0.94, curve: Curves.easeOut),
    );

    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.72, 0.98, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, secondaryAnimation) =>
            const SignupScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final horizontalPadding = width * 0.055;
          final starSize = width * 0.12;

          final centerX = (width - starSize) / 2;
          final centerY = height * 0.455;

          final topStarX = horizontalPadding + 1;
          final topStarY = height * 0.085;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = Curves.easeInOutCubic.transform(
                ((_controller.value - 0.18) / 0.42).clamp(0.0, 1.0),
              );

              final starX = _lerp(centerX, topStarX, progress);
              final starY = _lerp(centerY, topStarY, progress);

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const Positioned.fill(child: GradientBackground()),

                  // Subtle ambient background details.
                  Positioned(
                    top: height * 0.02,
                    right: -width * 0.2,
                    child: Container(
                      width: width * 0.55,
                      height: width * 0.55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.09),
                      ),
                    ),
                  ),

                  // Animated signature star.
                  Positioned(
                    left: starX,
                    top: starY,
                    width: starSize,
                    height: starSize,
                    child: Opacity(
                      opacity: _starOpacity.value,
                      child: Transform.scale(
                        scale: _starScale.value,
                        child: const Center(child: SparkleStar()),
                      ),
                    ),
                  ),

                  // Headline appears after the star starts moving.
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: height * 0.205,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: SlideTransition(
                        position: _headlineSlide,
                        child: const Text(
                          'YOUR HEALTH,\nIN BETTER\nBALANCE.',
                          style: TextStyle(
                            color: Color(0xFF101713),
                            fontSize: 31,
                            height: 1.04,
                            letterSpacing: -1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: height * 0.385,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: const Text(
                          'Understand your body. Build better habits. '
                          'Feel more like yourself.',
                          style: TextStyle(
                            color: Color(0xFF30443D),
                            fontSize: 14,
                            height: 1.55,
                            letterSpacing: 0.05,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Premium animated health preview
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: height * 0.44,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: const HealthPreviewCard(),
                      ),
                    ),
                  ),

                  // Bottom action area.
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: height * 0.045,
                    child: FadeTransition(
                      opacity: _buttonOpacity,
                      child: SlideTransition(
                        position: _buttonSlide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _continue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF050706),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    SizedBox(width: 9),
                                    Icon(Icons.arrow_forward_rounded, size: 17),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'By continuing, you agree to our Terms of '
                              'Service and Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF31443D),
                                fontSize: 10,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  double _lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GradientBackgroundPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class GradientBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF0F7DF),
          Color(0xFFD9F8E8),
          Color(0xFFA8EEE0),
          Color(0xFF7BD9DF),
        ],
        stops: [0.0, 0.34, 0.69, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);

    final shapePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final upperShape = Path()
      ..moveTo(size.width * 0.38, -size.height * 0.06)
      ..cubicTo(
        size.width * 0.27,
        size.height * 0.16,
        size.width * 0.23,
        size.height * 0.29,
        size.width * 0.0,
        size.height * 0.34,
      )
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(upperShape, shapePaint);

    final rightShape = Path()
      ..moveTo(size.width * 0.58, 0)
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.17,
        size.width * 0.71,
        size.height * 0.23,
        size.width,
        size.height * 0.27,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(rightShape, shapePaint);

    final lowerShape = Path()
      ..moveTo(0, size.height * 0.62)
      ..cubicTo(
        size.width * 0.21,
        size.height * 0.69,
        size.width * 0.31,
        size.height * 0.83,
        size.width * 0.39,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(lowerShape, shapePaint);

    final bottomShape = Path()
      ..moveTo(size.width * 0.59, size.height)
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.84,
        size.width * 0.81,
        size.height * 0.74,
        size.width,
        size.height * 0.69,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(bottomShape, shapePaint);

    final centralGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.48),
              radius: size.width * 0.75,
            ),
          );

    canvas.drawRect(rect, centralGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SparkleStar extends StatelessWidget {
  const SparkleStar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(48, 48), painter: SparkleStarPainter());
  }
}

class SparkleStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF050706)
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    path.moveTo(centerX, 0);
    path.cubicTo(
      centerX + size.width * 0.025,
      centerY - size.height * 0.12,
      centerX + size.width * 0.10,
      centerY - size.height * 0.025,
      size.width,
      centerY,
    );
    path.cubicTo(
      centerX + size.width * 0.10,
      centerY + size.height * 0.025,
      centerX + size.width * 0.025,
      centerY + size.height * 0.12,
      centerX,
      size.height,
    );
    path.cubicTo(
      centerX - size.width * 0.025,
      centerY + size.height * 0.12,
      centerX - size.width * 0.10,
      centerY + size.height * 0.025,
      0,
      centerY,
    );
    path.cubicTo(
      centerX - size.width * 0.10,
      centerY - size.height * 0.025,
      centerX - size.width * 0.025,
      centerY - size.height * 0.12,
      centerX,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

