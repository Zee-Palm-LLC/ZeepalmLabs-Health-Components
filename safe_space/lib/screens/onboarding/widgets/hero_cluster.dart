import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'floating_motion.dart';
import 'floating_orb.dart';
import 'question_card.dart';

class HeroCluster extends StatelessWidget {
  const HeroCluster({
    super.key,
    required this.phoneOpacity,
    required this.phoneOffset,
    required this.primaryOpacity,
    required this.primaryOffset,
    required this.secondaryOpacity,
    required this.secondaryOffset,
    required this.orbsOpacity,
  });

  final Animation<double> phoneOpacity;
  final Animation<Offset> phoneOffset;
  final Animation<double> primaryOpacity;
  final Animation<Offset> primaryOffset;
  final Animation<double> secondaryOpacity;
  final Animation<Offset> secondaryOffset;
  final Animation<double> orbsOpacity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final scale = (h / 360).clamp(0.78, 1.08);

        return Center(
          child: SizedBox(
            height: h,
            width: double.infinity,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: SizedBox(
                width: 320,
                height: 340,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    FadeTransition(
                      opacity: phoneOpacity,
                      child: SlideTransition(
                        position: phoneOffset,
                        child: const _PhoneFrame(),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 108,
                      child: FadeTransition(
                        opacity: secondaryOpacity,
                        child: SlideTransition(
                          position: secondaryOffset,
                          child: FloatingMotion(
                            amplitude: 5,
                            duration: const Duration(milliseconds: 3200),
                            delay: const Duration(milliseconds: 200),
                            rotationAmplitude: 0.01,
                            child: Transform.rotate(
                              angle: 0.1,
                              child: const QuestionCard(
                                background: AppColors.cardCream,
                                width: 172,
                                question:
                                    'How do you start to lose passion for everything at once?',
                                meta: '1k answers  •  55k views',
                                leading: PhotoAvatar(size: 26),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 44,
                      child: FadeTransition(
                        opacity: primaryOpacity,
                        child: SlideTransition(
                          position: primaryOffset,
                          child: FloatingMotion(
                            amplitude: 7,
                            duration: const Duration(milliseconds: 2900),
                            delay: const Duration(milliseconds: 80),
                            rotationAmplitude: 0.014,
                            child: Transform.rotate(
                              angle: -0.07,
                              child: const QuestionCard(
                                background: AppColors.cardLavender,
                                width: 200,
                                question:
                                    'How do you stop overthinking small social interactions?',
                                meta: '16 answers  •  400 views',
                                leading: CharacterFace(size: 30),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 28,
                      child: FadeTransition(
                        opacity: orbsOpacity,
                        child: FloatingMotion(
                          amplitude: 8,
                          duration: const Duration(milliseconds: 2600),
                          delay: const Duration(milliseconds: 400),
                          rotationAmplitude: 0.02,
                          child: const FloatingActionOrb(
                            color: AppColors.heart,
                            icon: Icons.favorite_rounded,
                            size: 48,
                            iconSize: 22,
                            iconColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      bottom: 36,
                      child: FadeTransition(
                        opacity: orbsOpacity,
                        child: FloatingMotion(
                          amplitude: 6,
                          duration: const Duration(milliseconds: 3000),
                          delay: const Duration(milliseconds: 550),
                          rotationAmplitude: 0.018,
                          child: const FloatingActionOrb(
                            color: AppColors.plus,
                            icon: Icons.add_rounded,
                            size: 50,
                            iconSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 18),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Container(
            width: 72,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.dynamicIsland,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
