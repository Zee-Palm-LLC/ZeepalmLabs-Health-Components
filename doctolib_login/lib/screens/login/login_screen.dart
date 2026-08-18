import 'package:doctolib_login/screens/login/components/fade_page_route.dart';
import 'package:doctolib_login/screens/login/components/fade_slide_in.dart';
import 'package:doctolib_login/screens/login/components/login_app_bar.dart';
import 'package:doctolib_login/screens/login/components/login_form_card.dart';
import 'package:doctolib_login/screens/signup/signup_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const LoginAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FadeSlideIn(child: Image.asset('assets/logo.png', height: 120)),
              LoginFormCard(
                emailController: _emailController,
                passwordController: _passwordController,
                rememberMe: _rememberMe,
                onRememberTap: () {
                  setState(() => _rememberMe = !_rememberMe);
                },
                onSignUp: () {
                  Navigator.of(
                    context,
                  ).push(FadePageRoute(page: const SignupScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
