import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/motion/routes.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/game_state.dart';
import '../../widgets/painters/quest_icons.dart';
import 'auth_flow.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  late final AnimationController _charge = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  bool _hidden = true;
  bool _remember = true;
  bool _busy = false;
  int _shake = 0;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _charge.dispose();
    super.dispose();
  }

  void _submit() {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final emailError = validateEmail(_email.text);
    final passwordError = validatePassword(_password.text);
    if (emailError != null || passwordError != null) {
      GameAudio.play(Sfx.denied);
      Haptics.buzz(Buzz.heavy);
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
        _shake++;
      });
      return;
    }
    unawaited(_launch());
  }

  Future<void> _launch() async {
    setState(() => _busy = true);
    GameAudio.play(Sfx.charge);
    Haptics.buzz(Buzz.medium);
    await _charge.forward(from: 0);
    if (!mounted) return;
    GameAudio.play(Sfx.levelUp);
    Haptics.buzz(Buzz.heavy);
    GameState.instance.signIn();
    enterGame(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      kicker: 'RETURNING PLAYER',
      lineOne: 'WELCOME BACK,',
      lineTwo: 'WARRIOR',
      subtitle: 'Your streak is waiting. Log in to keep it alive.',
      children: <Widget>[
        Shake(
          trigger: _shake,
          child: Column(
            children: <Widget>[
              HudTextField(
                controller: _email,
                label: 'EMAIL',
                hint: 'you@example.com',
                glyph: QuestGlyph.mail,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                errorText: _emailError,
                enabled: !_busy,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: 16),
              HudTextField(
                controller: _password,
                label: 'PASSWORD',
                hint: 'Your password',
                glyph: QuestGlyph.lock,
                obscure: _hidden,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.password],
                errorText: _passwordError,
                enabled: !_busy,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
                trailing: RevealToggle(
                  hidden: _hidden,
                  onTap: () => setState(() => _hidden = !_hidden),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: HudCheckbox(
                value: _remember,
                onChanged: (bool v) => setState(() => _remember = v),
                label: Text(
                  'Remember me',
                  style: T.questBlurb.copyWith(
                    fontSize: 13.5,
                    color: Ink2.secondary,
                  ),
                ),
              ),
            ),
            AuthLink(
              lead: '',
              action: 'FORGOT PASSWORD?',
              tone: Quests.purpleBright,
              onTap: () => Navigator.of(context).push<void>(
                hudRoute(ForgotPasswordScreen(initialEmail: _email.text)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AnimatedBuilder(
          animation: _charge,
          builder: (BuildContext context, Widget? _) => AuthCta(
            label: 'LOG IN',
            busyLabel: 'ENTERING THE REALM',
            busy: _busy,
            charge: _charge.value,
            onTap: _submit,
          ),
        ),
        const SizedBox(height: 26),
        const OrDivider(),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: SocialButton(
                provider: SocialProvider.google,
                enabled: !_busy,
                onTap: () => unawaited(_launch()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SocialButton(
                provider: SocialProvider.apple,
                enabled: !_busy,
                onTap: () => unawaited(_launch()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AuthLink(
          lead: 'New to Health Quest?',
          action: 'CREATE ACCOUNT',
          onTap: () => swapAuthPage(context, const SignupScreen()),
        ),
      ],
    );
  }
}
