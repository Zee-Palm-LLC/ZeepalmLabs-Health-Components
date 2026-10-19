
import 'dart:math' as math;

import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  static const ink = Color(0xFF101713);
  static const muted = Color(0xFF718078);
  static const green = Color(0xFF287B58);
  static const paleGreen = Color(0xFFE4F6EA);
  static const canvas = Color(0xFFF7FAF6);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entrance;
  late final AnimationController _ambient;

  bool _obscurePassword = true;
  bool _acceptedTerms = true;
  bool _isSubmitting = false;

  late final Animation<double> _headerAnimation;
  late final Animation<double> _formAnimation;
  late final Animation<double> _footerAnimation;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _headerAnimation = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );

    _formAnimation = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.20, 0.85, curve: Curves.easeOutCubic),
    );

    _footerAnimation = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
    );

    _entrance.forward();
    _ambient.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms to continue.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Connect your authentication service here.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Connect your authentication service to create an account.',
          ),
        ),
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ambient,
                builder: (context, child) {
                  final t = _ambient.value;

                  return Stack(
                    children: [
                      Positioned(
                        top: -100 + t * 15,
                        right: -90,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFB8EBD0)
                                    .withValues(alpha: 0.36),
                                const Color(0xFFB8EBD0)
                                    .withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 270,
                        left: -125 + t * 12,
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFD8EBDD)
                                    .withValues(alpha: 0.45),
                                const Color(0xFFD8EBDD)
                                    .withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(25, 12, 25, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 23),

                        _Entrance(
                          animation: _headerAnimation,
                          child: _buildHeader(),
                        ),

                        const SizedBox(height: 27),

                        _Entrance(
                          animation: _formAnimation,
                          child: _buildForm(),
                        ),

                        const SizedBox(height: 22),

                        _Entrance(
                          animation: _footerAnimation,
                          child: _buildFooter(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE7EEE7)),
            boxShadow: [
              BoxShadow(
                color: green.withValues(alpha: 0.07),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.spa_rounded,
            color: green,
            size: 24,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'wellnest',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: ink,
              ),
            ),
            Text(
              'YOUR HEALTH, IN HARMONY',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1.05,
                fontWeight: FontWeight.w700,
                color: muted,
              ),
            ),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _showMessage(
            'Connect your sign-in screen here.',
          ),
          style: TextButton.styleFrom(
            foregroundColor: green,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
          child: const Text(
            'Log in',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _ambient,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_ambient.value * math.pi) * 3,
                -math.sin(_ambient.value * math.pi) * 3,
              ),
              child: child,
            );
          },
          child: _buildHealthArtwork(),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F5EA),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFD5ECDD)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: green,
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                'YOUR NEXT CHAPTER STARTS HERE',
                style: TextStyle(
                  color: green,
                  fontSize: 9,
                  letterSpacing: 0.65,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        const Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 36,
              height: 1.08,
              letterSpacing: -1.8,
              fontWeight: FontWeight.w900,
              color: ink,
            ),
            children: [
              TextSpan(text: 'Feel better.\n'),
              TextSpan(
                text: 'Live ',
                style: TextStyle(color: ink),
              ),
              TextSpan(
                text: 'in balance.',
                style: TextStyle(
                  color: green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Create your personal health space and start '
          'understanding what your body needs.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthArtwork() {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 8,
            top: 20,
            child: Transform.rotate(
              angle: -7 * math.pi / 180,
              child: _artTile(
                color: const Color(0xFFE4F6EA),
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFF35996B),
                width: 96,
                height: 85,
              ),
            ),
          ),

          Positioned(
            left: 80,
            top: 2,
            child: Transform.rotate(
              angle: 4 * math.pi / 180,
              child: _artTile(
                color: const Color(0xFFF0EDFF),
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF8471D6),
                width: 89,
                height: 76,
              ),
            ),
          ),

          Positioned(
            left: 105,
            top: 31,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF91D9AD).withValues(alpha: 0.32),
                    const Color(0xFF91D9AD).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 119,
            top: 19,
            child: Container(
              width: 102,
              height: 102,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: green.withValues(alpha: 0.14),
                    blurRadius: 25,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE3F8EA),
                      Color(0xFFC0EBD0),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  size: 44,
                  color: green,
                ),
              ),
            ),
          ),

          Positioned(
            right: 2,
            top: 20,
            child: Transform.rotate(
              angle: 7 * math.pi / 180,
              child: _artTile(
                color: const Color(0xFFFFF1DD),
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFFD58C32),
                width: 83,
                height: 78,
              ),
            ),
          ),

          Positioned(
            right: 29,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE6EEE6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ink.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: green,
                    size: 15,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Your journey, your pace',
                    style: TextStyle(
                      color: ink,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _artTile({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ink.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 29,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Create account',
                style: TextStyle(
                  color: ink,
                  fontSize: 20,
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: muted,
              ),
              SizedBox(width: 5),
              Text(
                'Private by design',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _fieldLabel('YOUR NAME'),
          const SizedBox(height: 8),
          _inputField(
            controller: _nameController,
            hint: 'What should we call you?',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().length < 2) {
                return 'Please enter your name.';
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          _fieldLabel('EMAIL ADDRESS'),
          const SizedBox(height: 8),
          _inputField(
            controller: _emailController,
            hint: 'you@example.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (!RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(email)) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          _fieldLabel('PASSWORD'),
          const SizedBox(height: 8),
          _inputField(
            controller: _passwordController,
            hint: 'At least 8 characters',
            icon: Icons.key_rounded,
            obscureText: _obscurePassword,
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: muted,
                size: 19,
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Use at least 8 characters.';
              }
              return null;
            },
          ),

          const SizedBox(height: 13),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
                  activeColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(
                    color: Color(0xFFBDCDC1),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Wrap(
                  children: [
                    const Text(
                      'I agree to the ',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                    _termsLink('Terms of Service'),
                    const Text(
                      ' and ',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                    _termsLink('Privacy Policy'),
                    const Text(
                      '.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 57,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF39986A),
                    Color(0xFF287B58),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: green.withValues(alpha: 0.24),
                    blurRadius: 19,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _isSubmitting
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          key: ValueKey('label'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create my account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              const Expanded(
                child: Divider(color: Color(0xFFE2EAE2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(
                    color: muted.withValues(alpha: 0.9),
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: Color(0xFFE2EAE2)),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _socialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Google',
                  onTap: () => _showMessage(
                    'Connect Google Sign-In to continue.',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _socialButton(
                  icon: Icons.apple_rounded,
                  label: 'Apple',
                  onTap: () => _showMessage(
                    'Connect Apple Sign-In to continue.',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF53665B),
        fontSize: 10,
        letterSpacing: 1.05,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        color: ink,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFA1ADA4),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF769182),
          size: 19,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.88),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE4ECE4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE4ECE4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF63AC81),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFD87878),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFD87878),
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 10,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _termsLink(String text) {
    return GestureDetector(
      onTap: () => _showMessage(
        'Add your $text page here.',
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: green,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.underline,
          decorationColor: green,
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        minimumSize: const Size(0, 49),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        side: const BorderSide(color: Color(0xFFE3EBE3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 23),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: Color(0xFF7B9383),
              ),
              SizedBox(width: 6),
              Text(
                'Your health journey stays yours.',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          GestureDetector(
            onTap: () => _showMessage(
              'Connect your existing login screen here.',
            ),
            child: const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
                children: [
                  TextSpan(text: 'Already part of Wellnest? '),
                  TextSpan(
                    text: 'Log in',
                    style: TextStyle(
                      color: green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _Entrance({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;

        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 26 * (1 - t)),
            child: Transform.scale(
              alignment: Alignment.topCenter,
              scale: 0.97 + 0.03 * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}