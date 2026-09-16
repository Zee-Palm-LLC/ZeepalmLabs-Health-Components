import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/game_state.dart';
import '../../widgets/painters/quest_icons.dart';
import 'auth_flow.dart';
import 'login_screen.dart';
import 'main_quest_screen.dart';
import 'widgets/auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  late final AnimationController _charge = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  bool _hidden = true;
  bool _terms = false;
  bool _busy = false;
  int _shake = 0;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _termsError = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _charge.dispose();
    super.dispose();
  }

  void _submit() {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final nameError = validateHeroName(_name.text);
    final emailError = validateEmail(_email.text);
    final passwordError = validateNewPassword(_password.text);
    final termsError = !_terms;
    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        termsError) {
      GameAudio.play(Sfx.denied);
      Haptics.buzz(Buzz.heavy);
      setState(() {
        _nameError = nameError;
        _emailError = emailError;
        _passwordError = passwordError;
        _termsError = termsError;
        _shake++;
      });
      return;
    }
    unawaited(_launch(heroName: _name.text));
  }

  Future<void> _launch({String? heroName}) async {
    setState(() => _busy = true);
    GameAudio.play(Sfx.confirm);
    Haptics.buzz(Buzz.medium);
    await _charge.forward(from: 0);
    if (!mounted) return;
    GameState.instance.signIn(heroName: heroName);
    swapAuthPage(context, const MainQuestScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      kicker: 'NEW PLAYER  ·  STEP 1 OF 2',
      lineOne: 'CREATE YOUR',
      lineTwo: 'HERO',
      subtitle: 'Thirty seconds to set up. A lifetime of XP.',
      children: <Widget>[
        Shake(
          trigger: _shake,
          child: Column(
            children: <Widget>[
              HudTextField(
                controller: _name,
                label: 'HERO NAME',
                hint: 'What should we call you?',
                glyph: QuestGlyph.person,
                autofillHints: const <String>[AutofillHints.nickname],
                errorText: _nameError,
                enabled: !_busy,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 16),
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
                hint: 'At least 8 characters',
                glyph: QuestGlyph.lock,
                obscure: _hidden,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.newPassword],
                errorText: _passwordError,
                enabled: !_busy,
                onSubmitted: (_) => _submit(),
                onChanged: (_) => setState(() => _passwordError = null),
                trailing: RevealToggle(
                  hidden: _hidden,
                  onTap: () => setState(() => _hidden = !_hidden),
                ),
              ),
              PasswordStrength(password: _password.text),
            ],
          ),
        ),
        const SizedBox(height: 20),
        HudCheckbox(
          value: _terms,
          error: _termsError,
          onChanged: (bool v) => setState(() {
            _terms = v;
            _termsError = false;
          }),
          label: Text.rich(
            TextSpan(
              style: T.questBlurb.copyWith(
                fontSize: 13.5,
                height: 1.4,
                color: _termsError ? Quests.rose : Ink2.secondary,
              ),
              children: <InlineSpan>[
                const TextSpan(text: 'I accept the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: Quests.blueBright,
                    fontVariations: const <FontVariation>[
                      FontVariation('wght', 650),
                    ],
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Quests.blueBright,
                    fontVariations: const <FontVariation>[
                      FontVariation('wght', 650),
                    ],
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        AnimatedBuilder(
          animation: _charge,
          builder: (BuildContext context, Widget? _) => AuthCta(
            label: 'CREATE HERO',
            busyLabel: 'FORGING YOUR HERO',
            busy: _busy,
            charge: _charge.value,
            onTap: _submit,
          ),
        ),
        const SizedBox(height: 26),
        const OrDivider(label: 'OR SIGN UP WITH'),
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
          lead: 'Already a warrior?',
          action: 'LOG IN',
          onTap: () => swapAuthPage(context, const LoginScreen()),
        ),
      ],
    );
  }
}
