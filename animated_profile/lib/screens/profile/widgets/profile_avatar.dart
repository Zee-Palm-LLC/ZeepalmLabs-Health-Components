import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.avatarRingTop,
                  AppColors.avatarRingBottom,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 30,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.avatarBackgroundTop,
                            AppColors.avatarBackgroundBottom,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      child: Container(
                        width: 44,
                        height: 51,
                        decoration: BoxDecoration(
                          color: AppColors.avatarHead,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 17,
                      child: Container(
                        width: 49,
                        height: 33,
                        decoration: BoxDecoration(
                          color: AppColors.avatarHair,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 33,
                      child: Container(
                        width: 41,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.avatarFace,
                          borderRadius: BorderRadius.circular(21),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 27,
                      left: 29,
                      child: Container(
                        width: 18,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.avatarHair,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(13),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 47,
                      child: Row(
                        children: const [
                          _AvatarGlass(),
                          SizedBox(width: 4),
                          _AvatarGlass(),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 22,
                      child: Container(
                        width: 29,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.avatarBeard,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -17,
                      child: Container(
                        width: 78,
                        height: 49,
                        decoration: const BoxDecoration(
                          color: AppColors.avatarShirt,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(38),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 64,
                      child: Container(
                        width: 23,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.avatarStethoscope,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 68,
                      child: Container(
                        width: 5,
                        height: 13,
                        color: AppColors.avatarStethoscope,
                      ),
                    ),
                    Positioned(
                      top: 80,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.avatarStethoscope,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.onlineDot,
                  ),
                  child: SizedBox(width: 12, height: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarGlass extends StatelessWidget {
  const _AvatarGlass();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 11,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.avatarOutline,
          width: 1.4,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
