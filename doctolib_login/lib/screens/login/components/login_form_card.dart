import 'package:doctolib_login/screens/login/components/fade_slide_in.dart';
import 'package:doctolib_login/screens/login/components/labeled_text_field.dart';
import 'package:doctolib_login/screens/login/components/login_button.dart';
import 'package:doctolib_login/screens/login/components/or_divider.dart';
import 'package:doctolib_login/screens/login/components/remember_me_row.dart';
import 'package:doctolib_login/screens/login/components/signup_prompt.dart';
import 'package:doctolib_login/screens/login/components/social_login_row.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    this.onRememberTap,
    this.onForgotPassword,
    this.onLogin,
    this.onGoogle,
    this.onFacebook,
    this.onApple,
    this.onSignUp,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final VoidCallback? onRememberTap;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onLogin;
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;
  final VoidCallback? onApple;
  final VoidCallback? onSignUp;

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
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'example@gmail.com',
              prefixIcon: Icon(Iconsax.sms, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 140),
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
            delay: const Duration(milliseconds: 200),
            child: RememberMeRow(
              rememberMe: rememberMe,
              onRememberTap: onRememberTap,
              onForgotPassword: onForgotPassword,
            ),
          ),
          const SizedBox(height: 40),
          FadeSlideIn(
            delay: const Duration(milliseconds: 260),
            child: LoginButton(onPressed: onLogin),
          ),
          const SizedBox(height: 40),
          const FadeSlideIn(
            delay: Duration(milliseconds: 320),
            child: OrDivider(),
          ),
          const SizedBox(height: 40),
          FadeSlideIn(
            delay: const Duration(milliseconds: 380),
            child: SocialLoginRow(
              onGoogle: onGoogle,
              onFacebook: onFacebook,
              onApple: onApple,
            ),
          ),
          const SizedBox(height: 40),
          FadeSlideIn(
            delay: const Duration(milliseconds: 440),
            child: SignupPrompt(onSignUp: onSignUp),
          ),
        ],
      ),
    );
  }
}
