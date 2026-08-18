import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPrompt extends StatelessWidget {
  const SignupPrompt({
    super.key,
    this.prefix = "Don't have an account? ",
    this.action = 'Sign up',
    this.onSignUp,
  });

  final String prefix;
  final String action;
  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefix,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade500,
          ),
        ),
        GestureDetector(
          onTap: onSignUp,
          child: Text(
            action,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
