import 'package:flutter/material.dart';
import 'package:physio_motion/theme/app_colors.dart';

class WelcomeTopBar extends StatelessWidget {
  const WelcomeTopBar({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/logo.png', height: 35),
        const Spacer(),
        IconButton(
          onPressed: onMenuTap ?? () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const DotsGridIcon(),
        ),
      ],
    );
  }
}

class DotsGridIcon extends StatelessWidget {
  const DotsGridIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (_) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (_) {
              return Container(
                width: 3.5,
                height: 3.5,
                decoration: const BoxDecoration(
                  color: AppColors.softGray,
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
