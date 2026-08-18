import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({
    super.key,
    this.onGoogle,
    this.onFacebook,
    this.onApple,
  });

  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;
  final VoidCallback? onApple;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onGoogle,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/google.svg'),
                const SizedBox(width: 10),
                Text('Google', style: GoogleFonts.poppins(color: Colors.black)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _CircleSocialButton(asset: 'assets/facebook.svg', onTap: onFacebook),
        const SizedBox(width: 10),
        _CircleSocialButton(asset: 'assets/apple.svg', onTap: onApple),
      ],
    );
  }
}

class _CircleSocialButton extends StatelessWidget {
  const _CircleSocialButton({required this.asset, this.onTap});

  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(asset),
      ),
    );
  }
}
