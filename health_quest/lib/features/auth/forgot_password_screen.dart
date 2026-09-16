import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/design.dart';
import '../../core/motion/idle.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/hud.dart';
import '../../widgets/hud_kit.dart';
import '../../widgets/painters/polygon.dart';
import '../../widgets/painters/quest_icons.dart';
import 'auth_flow.dart';
import 'widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  late final AnimationController _charge = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool _busy = false;
  bool _sent = false;
  int _shake = 0;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _charge.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final error = validateEmail(_email.text);
    if (error != null) {
      GameAudio.play(Sfx.denied);
      Haptics.buzz(Buzz.heavy);
      setState(() {
        _error = error;
        _shake++;
      });
      return;
    }
    setState(() => _busy = true);
    GameAudio.play(Sfx.open);
    await _charge.forward(from: 0);
    if (!mounted) return;
    GameAudio.play(Sfx.confirm);
    Haptics.buzz(Buzz.medium);
    setState(() {
      _busy = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return HudPage(
      kicker: 'ACCOUNT RECOVERY',
      title: 'RESET PASSWORD',
      tint: Quests.blue,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          D.pageGutter + 6,
          18,
          D.pageGutter + 6,
          24 + pad.bottom,
        ),
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: D.emphasized,
            transitionBuilder: (Widget child, Animation<double> a) =>
                FadeTransition(
                  opacity: a,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(a),
                    child: child,
                  ),
                ),
            child: _sent ? _sentView() : _form(),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Column(
      key: const ValueKey<String>('form'),
      children: <Widget>[
        const _MailCrest(tone: Quests.blue),
        const SizedBox(height: 18),
        Text(
          'Lost your key?',
          style: T.questHeadline.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter the email on your account and we'll send a link to set a new "
          'password. Your level and streak are safe.',
          textAlign: TextAlign.center,
          style: T.sub.copyWith(fontSize: 14.5, height: 1.4),
        ),
        const SizedBox(height: 26),
        Shake(
          trigger: _shake,
          child: HudTextField(
            controller: _email,
            label: 'EMAIL',
            hint: 'you@example.com',
            glyph: QuestGlyph.mail,
            tone: Quests.blue,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autofillHints: const <String>[AutofillHints.email],
            errorText: _error,
            enabled: !_busy,
            onSubmitted: (_) => unawaited(_send()),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ),
        const SizedBox(height: 22),
        AnimatedBuilder(
          animation: _charge,
          builder: (BuildContext context, Widget? _) => AuthCta(
            label: 'SEND RESET LINK',
            busyLabel: 'SENDING',
            busy: _busy,
            charge: _charge.value,
            onTap: () => unawaited(_send()),
          ),
        ),
        const SizedBox(height: 18),
        AuthLink(
          lead: 'Remembered it?',
          action: 'BACK TO LOG IN',
          sound: Sfx.back,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  Widget _sentView() {
    return Column(
      key: const ValueKey<String>('sent'),
      children: <Widget>[
        const _MailCrest(tone: Quests.green, sent: true),
        const SizedBox(height: 18),
        Text(
          'CHECK YOUR INBOX',
          style: T.questHeadline.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: T.sub.copyWith(fontSize: 14.5, height: 1.4),
            children: <InlineSpan>[
              const TextSpan(text: 'A reset link is on its way to\n'),
              TextSpan(
                text: _email.text.trim(),
                style: const TextStyle(color: Quests.greenBright),
              ),
              const TextSpan(
                text: '.\nIt expires in 30 minutes.',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 26),
        HudPanel(
          cut: 14,
          accent: Quests.gold,
          edge: Quests.gold.withValues(alpha: 0.25),
          rail: true,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              const QuestIcon(
                glyph: QuestGlyph.shield,
                size: 20,
                color: Quests.gold,
                highlight: Quests.goldBright,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Not there? Check spam, or make sure this is the email you '
                  'signed up with.',
                  style: T.questBlurb.copyWith(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        AuthCta(
          label: 'BACK TO LOG IN',
          busyLabel: '',
          onTap: () {
            GameAudio.play(Sfx.back);
            Navigator.of(context).maybePop();
          },
        ),
        const SizedBox(height: 14),
        AuthLink(
          lead: "Didn't get it?",
          action: 'RESEND',
          sound: Sfx.confirm,
          onTap: () => showHudToast(
            context,
            'Sent again to ${_email.text.trim()}.',
            tone: Quests.green,
            glyph: QuestGlyph.mail,
          ),
        ),
      ],
    );
  }
}

class _MailCrest extends StatelessWidget {
  const _MailCrest({required this.tone, this.sent = false});

  final Color tone;
  final bool sent;

  @override
  Widget build(BuildContext context) {
    return IdleBuilder(
      builder: (BuildContext context, double idle, Widget? _) {
        final pulse = 0.5 + 0.5 * math.sin(idle * 1.8);
        return SizedBox(
          width: 104,
          height: 112,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Transform.translate(
                offset: Offset(0, 3 * math.sin(idle * 1.4)),
                child: PolygonPane(
                  size: const Size(92, 104),
                  sides: 6,
                  cornerRadius: 10,
                  edgeWidth: 2,
                  edge: Color.lerp(tone, Ink2.bright, 0.2)!,
                  glow: tone.withValues(alpha: 0.8),
                  glowStrength: 0.45 + 0.35 * pulse,
                  fill: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color.lerp(tone, Colors.black, 0.55)!,
                      const Color(0xFF080B16),
                    ],
                  ),
                  child: QuestIcon(
                    glyph: QuestGlyph.mail,
                    size: 44,
                    color: Color.lerp(tone, Ink2.bright, 0.25)!,
                    strokeWidth: 6,
                  ),
                ),
              ),
              if (sent)
                Positioned(
                  right: 0,
                  bottom: 4,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: D.softPop,
                    builder: (BuildContext context, double v, Widget? _) =>
                        Transform.scale(
                          scale: v.clamp(0.0, 1.3),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0E1018),
                              border: Border.all(color: Quests.green),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Quests.green.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Center(
                              child: QuestIcon(
                                glyph: QuestGlyph.check,
                                size: 18,
                                color: Quests.greenBright,
                                progress: ((v - 0.3) / 0.7).clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
