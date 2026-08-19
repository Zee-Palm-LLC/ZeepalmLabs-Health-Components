import 'package:doctolib_login/screens/login/components/fade_slide_in.dart';
import 'package:doctolib_login/screens/login/components/login_app_bar.dart';
import 'package:doctolib_login/screens/signup/components/signup_form_card.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _acceptedTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _openLogin() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: LoginAppBar(title: 'Sign up', onBack: _openLogin),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FadeSlideIn(child: Image.asset('assets/logo.png', height: 120)),
              SignupFormCard(
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                acceptedTerms: _acceptedTerms,
                onTermsTap: () {
                  setState(() => _acceptedTerms = !_acceptedTerms);
                },
                onLogin: _openLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
