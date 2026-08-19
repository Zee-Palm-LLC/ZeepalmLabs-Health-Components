import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RememberMeRow extends StatelessWidget {
  const RememberMeRow({
    super.key,
    required this.rememberMe,
    this.onRememberTap,
    this.onForgotPassword,
  });

  final bool rememberMe;
  final VoidCallback? onRememberTap;
  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onRememberTap,
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: rememberMe
                    ? const Icon(
                        Icons.done,
                        key: ValueKey('on'),
                        color: Colors.black,
                        size: 12,
                      )
                    : const SizedBox.shrink(key: ValueKey('off')),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Remember me',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onForgotPassword,
            child: Text(
              'Forgot password?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
