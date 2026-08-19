import 'package:doctolib_login/screens/login/components/fade_slide_in.dart';
import 'package:doctolib_login/screens/login/components/labeled_text_field.dart';
import 'package:doctolib_login/screens/login/components/login_button.dart';
import 'package:doctolib_login/screens/login/components/or_divider.dart';
import 'package:doctolib_login/screens/login/components/signup_prompt.dart';
import 'package:doctolib_login/screens/login/components/social_login_row.dart';
import 'package:doctolib_login/screens/signup/components/terms_row.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SignupFormCard extends StatelessWidget {
  const SignupFormCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.acceptedTerms,
    this.onTermsTap,
    this.onSignUp,
    this.onGoogle,
    this.onFacebook,
    this.onApple,
    this.onLogin,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool acceptedTerms;
  final VoidCallback? onTermsTap;
  final VoidCallback? onSignUp;
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;
  final VoidCallback? onApple;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: LabeledTextField(
              label: 'Full name',
              controller: nameController,
              keyboardType: TextInputType.name,
              hintText: 'John Doe',
              prefixIcon: Icon(Iconsax.user, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 130),
            child: LabeledTextField(
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'example@gmail.com',
              prefixIcon: Icon(Iconsax.sms, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 180),
            child: LabeledTextField(
              label: 'Password',
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              hintText: 'Enter your password',
              prefixIcon: Icon(Iconsax.lock, color: Colors.grey.shade600),
              suffixIcon: Icon(Iconsax.eye, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 230),
            child: LabeledTextField(
              label: 'Confirm password',
              controller: confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
              hintText: 'Re-enter your password',
              prefixIcon: Icon(Iconsax.lock, color: Colors.grey.shade600),
              suffixIcon: Icon(Iconsax.eye, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 280),
            child: TermsRow(accepted: acceptedTerms, onTap: onTermsTap),
          ),
          const SizedBox(height: 40),
          FadeSlideIn(
            delay: const Duration(milliseconds: 330),
            child: LoginButton(label: 'Sign up', onPressed: onSignUp),
          ),
          const SizedBox(height: 40),
          const FadeSlideIn(
            delay: Duration(milliseconds: 380),
            child: OrDivider(),
          ),
          const SizedBox(height: 40),
          FadeSlideIn(
            delay: const Duration(milliseconds: 430),
            child: SocialLoginRow(
              onGoogle: onGoogle,
              onFacebook: onFacebook,
              onApple: onApple,
            ),
          ),
          const SizedBox(height: 40),
          FadeSlideIn(
            delay: const Duration(milliseconds: 480),
            child: SignupPrompt(
              prefix: 'Already have an account? ',
              action: 'Log in',
              onSignUp: onLogin,
            ),
          ),
        ],
      ),
    );
  }
}
