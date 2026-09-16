import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/sfx.dart';
import '../../../core/design.dart';
import '../../../core/motion/entrance.dart';
import '../../../core/motion/idle.dart';
import '../../../core/motion/pressable.dart';
import '../../../core/palette.dart';
import '../../../core/type.dart';
import '../../../widgets/hud.dart';
import '../../../widgets/hud_kit.dart';
import '../../../widgets/painters/quest_icons.dart';

class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.kicker,
    required this.lineOne,
    required this.lineTwo,
    required this.subtitle,
    required this.children,
    this.tone = Quests.purple,
  });

  final String kicker;
  final String lineOne;
  final String lineTwo;
  final String subtitle;
  final Color tone;

  final List<Widget> children;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: Quests.page,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _Backdrop(),
          ShellGlow(tint: widget.tone),
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: _in,
              builder: (BuildContext context, Widget? _) {
                final t = _in.value;
                var beat = 0;
                double next() => D.outExpo.transform(
                  D.stagger(t, 0.18, beat++, 0.055, 0.34),
                );
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    D.pageGutter + 6,
                    18,
                    D.pageGutter + 6,
                    24 + pad.bottom,
                  ),
                  children: <Widget>[
                    Rise(
                      t: D.softPop.transform((t / 0.4).clamp(0.0, 1.0)),
                      distance: 0,
                      scaleFrom: 0.6,
                      child: Center(child: _Crest(tone: widget.tone)),
                    ),
                    const SizedBox(height: 18),
                    Rise(
                      t: D.outExpo.transform(((t - 0.08) / 0.4).clamp(0.0, 1.0)),
                      distance: 14,
                      child: Column(
                        children: <Widget>[
                          Text(
                            widget.kicker,
                            style: T.questKicker.copyWith(
                              color: Color.lerp(widget.tone, Ink2.bright, 0.3),
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SweepReveal(
                            t: ((t - 0.1) / 0.4).clamp(0.0, 1.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.lineOne,
                                style: T.levelUp.copyWith(fontSize: 26),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SweepReveal(
                            t: ((t - 0.16) / 0.4).clamp(0.0, 1.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: Spectrum.headline.createShader,
                                child: Text(
                                  widget.lineTwo,
                                  style: T.yourHealth,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: T.sub.copyWith(fontSize: 14.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    for (final child in widget.children)
                      Rise(t: next(), distance: 18, child: child),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Opacity(
            opacity: 0.55,
            child: Image.asset(
              'assets/hero/plate.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0x6605060C),
                  Color(0xE605060C),
                  Quests.page,
                ],
                stops: <double>[0, 0.38, 0.62],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Crest extends StatelessWidget {
  const _Crest({required this.tone});

  final Color tone;

  @override
  Widget build(BuildContext context) {
    return IdleBuilder(
      builder: (BuildContext context, double idle, Widget? _) {
        final pulse = 0.5 + 0.5 * math.sin(idle * 1.8);
        return SizedBox(
          width: 118,
          height: 118,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.rotate(
                angle: idle * 0.6,
                child: CustomPaint(
                  size: const Size.square(118),
                  painter: _OrbitPainter(tone: tone, pulse: pulse),
                ),
              ),
              HexAvatar(
                tone: tone,
                size: 76,
                image: 'assets/hero/face.png',
                glow: 0.45 + 0.35 * pulse,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.tone, required this.pulse});

  final Color tone;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(4);
    final dashes = 28;
    for (var i = 0; i < dashes; i++) {
      final a = i * 2 * math.pi / dashes;
      canvas.drawArc(
        rect,
        a,
        0.09,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = tone.withValues(alpha: i.isEven ? 0.55 : 0.18),
      );
    }
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 0.6,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: <Color>[tone.withValues(alpha: 0), Quests.blueBright],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..maskFilter = MaskFilter.blur(BlurStyle.solid, 2 + 3 * pulse),
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.tone != tone || old.pulse != pulse;
}

class HudTextField extends StatefulWidget {
  const HudTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.glyph,
    this.tone = Quests.purple,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.trailing,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final QuestGlyph glyph;
  final Color tone;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final Widget? trailing;
  final bool enabled;

  @override
  State<HudTextField> createState() => _HudTextFieldState();
}

class _HudTextFieldState extends State<HudTextField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (_focus.hasFocus) GameAudio.play(Sfx.tick);
    setState(() {});
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText;
    final focused = _focus.hasFocus;
    final accent = error != null ? Quests.rose : widget.tone;
    final iconColour = error != null
        ? Quests.rose
        : (focused ? Color.lerp(widget.tone, Ink2.bright, 0.25)! : Ink2.muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: T.cardLabel.copyWith(
            fontSize: 11,
            color: focused ? Color.lerp(accent, Ink2.bright, 0.4) : null,
          ),
        ),
        const SizedBox(height: 7),
        HudPanel(
          cut: 12,
          fill: const Color(0xE60B0E19),
          edge: error != null
              ? Quests.rose.withValues(alpha: 0.7)
              : (focused
                    ? widget.tone.withValues(alpha: 0.75)
                    : Quests.cardEdge),
          accent: accent,
          glow: focused ? 0.35 : (error != null ? 0.2 : 0),
          brackets: focused || error != null,
          bracketLength: 10,
          rail: focused,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            height: 54,
            child: Row(
              children: <Widget>[
                QuestIcon(
                  glyph: widget.glyph,
                  size: 18,
                  color: iconColour,
                  strokeWidth: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    obscureText: widget.obscure,
                    obscuringCharacter: '•',
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    autofillHints: widget.autofillHints,
                    autocorrect: false,
                    enableSuggestions: !widget.obscure,
                    onSubmitted: widget.onSubmitted,
                    onChanged: widget.onChanged,
                    style: T.questTitle.copyWith(fontSize: 15),
                    cursorColor: Color.lerp(widget.tone, Ink2.bright, 0.3),
                    cursorWidth: 2,
                    decoration: InputDecoration.collapsed(
                      hintText: widget.hint,
                      hintStyle: T.questBlurb.copyWith(
                        fontSize: 14.5,
                        color: Ink2.faint,
                      ),
                    ),
                  ),
                ),
                if (widget.trailing != null) ...<Widget>[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: error == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 7, left: 2),
                  child: Row(
                    children: <Widget>[
                      const QuestIcon(
                        glyph: QuestGlyph.lock,
                        size: 12,
                        color: Quests.rose,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          error,
                          style: T.questBlurb.copyWith(
                            color: Quests.rose,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class RevealToggle extends StatelessWidget {
  const RevealToggle({super.key, required this.hidden, required this.onTap});

  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: hidden ? 'Show password' : 'Hide password',
    child: Pressable(
      sound: Sfx.tick,
      haptic: false,
      pressedScale: 0.85,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: QuestIcon(
          glyph: hidden ? QuestGlyph.eye : QuestGlyph.eyeOff,
          size: 20,
          color: Ink2.muted,
          strokeWidth: 7,
        ),
      ),
    ),
  );
}

int passwordScore(String password) {
  if (password.isEmpty) return 0;
  if (password.length < 8) return 1;
  var score = 1;
  if (password.contains(RegExp('[a-z]')) &&
      password.contains(RegExp('[A-Z]'))) {
    score++;
  }
  if (password.contains(RegExp(r'\d'))) score++;
  if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
  return score;
}

class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.password});

  final String password;

  static const List<(String, Color)> _ranks = <(String, Color)>[
    ('', Quests.locked),
    ('WEAK', Quests.rose),
    ('DECENT', Quests.gold),
    ('STRONG', Quests.green),
    ('LEGENDARY', Quests.purpleBright),
  ];

  @override
  Widget build(BuildContext context) {
    final score = passwordScore(password);
    final (label, colour) = _ranks[score];
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: score / 4),
              duration: const Duration(milliseconds: 380),
              curve: D.emphasized,
              builder: (BuildContext context, double v, Widget? _) =>
                  SegmentedMeter(
                    value: v,
                    color: colour,
                    height: 7,
                    segments: 4,
                    gap: 4,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 84,
            child: Text(
              score == 0 ? 'STRENGTH' : label,
              textAlign: TextAlign.right,
              style: T.rewardLabel.copyWith(
                fontSize: 10.5,
                color: score == 0 ? Ink2.faint : colour,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HudCheckbox extends StatelessWidget {
  const HudCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.tone = Quests.green,
    this.error = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;
  final Color tone;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final edge = error ? Quests.rose : (value ? tone : Quests.locked);
    return Semantics(
      checked: value,
      child: Pressable(
        sound: null,
        haptic: false,
        pressedScale: 0.97,
        onTap: () {
          Haptics.buzz(Buzz.selection);
          GameAudio.play(value ? Sfx.toggleOff : Sfx.toggleOn);
          onChanged(!value);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: value ? 1 : 0),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                builder: (BuildContext context, double v, Widget? _) =>
                    HudPanel(
                      cut: 6,
                      fill: Color.lerp(
                        const Color(0xFF0B0E19),
                        tone.withValues(alpha: 0.22),
                        v,
                      )!,
                      edge: edge.withValues(alpha: 0.5 + 0.4 * v),
                      accent: edge,
                      glow: 0.3 * v,
                      brackets: false,
                      scanlines: false,
                      child: v <= 0.01
                          ? const SizedBox.expand()
                          : Center(
                              child: QuestIcon(
                                glyph: QuestGlyph.check,
                                size: 15,
                                color: Color.lerp(tone, Ink2.bright, 0.3)!,
                                progress: v,
                              ),
                            ),
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.lead,
    required this.action,
    required this.onTap,
    this.tone = Quests.blueBright,
    this.sound = Sfx.open,
  });

  final String lead;
  final String action;
  final VoidCallback onTap;
  final Color tone;
  final Sfx sound;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        if (lead.isNotEmpty)
          Text('$lead  ', style: T.questBlurb.copyWith(fontSize: 14)),
        Pressable(
          sound: sound,
          pressedScale: 0.92,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              action,
              style: T.navLabel.copyWith(fontSize: 13, color: tone),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthCta extends StatelessWidget {
  const AuthCta({
    super.key,
    required this.label,
    required this.busyLabel,
    required this.onTap,
    this.charge = 0,
    this.busy = false,
  });

  final String label;
  final String busyLabel;
  final VoidCallback onTap;
  final double charge;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return IdleBuilder(
      builder: (BuildContext context, double idle, Widget? _) => Pressable(
        sound: null,
        enabled: !busy,
        pressedScale: 0.965,
        onTap: onTap,
        child: BevelButton(
          height: D.ctaHeight,
          cut: 17,
          gradient: Spectrum.action,
          glowColor: Spectrum.violetDeep,
          lit: busy,
          idle: idle,
          charge: charge,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(busy ? busyLabel : label, style: T.button),
                  ),
                ),
                const SizedBox(width: 18),
                const QuestIcon(
                  glyph: QuestGlyph.chevron,
                  size: 18,
                  color: Ink2.bright,
                  strokeWidth: 9,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'OR CONTINUE WITH'});

  final String label;

  @override
  Widget build(BuildContext context) {
    Widget rule(bool leftOfLabel) => Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: leftOfLabel
                ? const <Color>[Color(0x00FFFFFF), Color(0x33FFFFFF)]
                : const <Color>[Color(0x33FFFFFF), Color(0x00FFFFFF)],
          ),
        ),
      ),
    );
    return Row(
      children: <Widget>[
        rule(true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: T.rewardLabel.copyWith(fontSize: 10.5)),
        ),
        rule(false),
      ],
    );
  }
}

enum SocialProvider { google, apple }

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.provider,
    required this.onTap,
    this.enabled = true,
  });

  final SocialProvider provider;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final google = provider == SocialProvider.google;
    return Pressable(
      sound: Sfx.confirm,
      enabled: enabled,
      pressedScale: 0.95,
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: HudPanel(
          cut: 13,
          fill: const Color(0xE60E1120),
          accent: google ? Quests.blue : Ink2.secondary,
          accentStrength: 0.6,
          bracketLength: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomPaint(
                size: const Size.square(20),
                painter: google ? const _GoogleMark() : const _AppleMark(),
              ),
              const SizedBox(width: 10),
              Text(
                google ? 'GOOGLE' : 'APPLE',
                style: T.navLabel.copyWith(fontSize: 12.5, color: Ink2.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends CustomPainter {
  const _GoogleMark();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final stroke = w * 0.2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: w / 2 - stroke / 2,
    );
    Paint arc(Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = c;
    double rad(double deg) => deg * math.pi / 180;
    canvas.drawArc(rect, rad(-45), rad(90), false, arc(const Color(0xFF4285F4)));
    canvas.drawArc(rect, rad(45), rad(90), false, arc(const Color(0xFF34A853)));
    canvas.drawArc(rect, rad(135), rad(60), false, arc(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, rad(195), rad(120), false, arc(const Color(0xFFEA4335)));
    canvas.drawRect(
      Rect.fromLTWH(w * 0.5, w * 0.5 - stroke / 2, w * 0.5 - stroke * 0.1, stroke),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_GoogleMark old) => false;
}

class _AppleMark extends CustomPainter {
  const _AppleMark();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    Path circle(double x, double y, double r) =>
        Path()..addOval(Rect.fromCircle(center: Offset(x * w, y * w), radius: r * w));
    var body = Path.combine(
      PathOperation.union,
      circle(0.36, 0.6, 0.28),
      circle(0.64, 0.6, 0.28),
    );
    body = Path.combine(PathOperation.union, body, circle(0.5, 0.74, 0.22));
    body = Path.combine(PathOperation.difference, body, circle(0.5, 0.3, 0.1));
    body = Path.combine(PathOperation.difference, body, circle(0.96, 0.52, 0.16));
    final paint = Paint()..color = Ink2.bright;
    canvas.drawPath(body, paint);
    canvas.save();
    canvas.translate(w * 0.58, w * 0.14);
    canvas.rotate(0.7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.14, height: w * 0.28),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AppleMark old) => false;
}

class Shake extends StatefulWidget {
  const Shake({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (BuildContext context, Widget? child) {
      final v = _c.value;
      final dx = math.sin(v * math.pi * 7) * 11 * (1 - v);
      return Transform.translate(offset: Offset(dx, 0), child: child);
    },
  );
}
