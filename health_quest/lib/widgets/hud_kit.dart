import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/audio/sfx.dart';
import '../core/design.dart';
import '../core/motion/idle.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';
import 'hud.dart';
import 'painters/polygon.dart';
import 'painters/quest_icons.dart';

class ShellGlow extends StatelessWidget {
  const ShellGlow({super.key, this.tint = Quests.purple});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: IdleBuilder(
        builder: (BuildContext context, double s, Widget? _) => CustomPaint(
          painter: _GlowPainter(s, tint),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.seconds, this.tint);

  final double seconds;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    void blob(Offset c, double r, Color color, double alpha) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    blob(
      Offset(
        size.width * (0.22 + 0.05 * math.sin(seconds * 0.16)),
        size.height * 0.06,
      ),
      size.width * 0.8,
      tint,
      0.16,
    );
    blob(
      Offset(
        size.width * (0.86 + 0.04 * math.cos(seconds * 0.12)),
        size.height * 0.34,
      ),
      size.width * 0.6,
      Quests.blue,
      0.09,
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.seconds != seconds || old.tint != tint;
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.glyph,
    required this.onTap,
    this.sound = Sfx.tap,
    this.size = 46,
    this.semanticLabel,
  });

  final QuestGlyph glyph;
  final VoidCallback onTap;
  final Sfx? sound;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: Pressable(
      onTap: onTap,
      sound: sound,
      pressedScale: 0.88,
      child: SizedBox(
        width: size,
        height: size,
        child: HudPanel(
          cut: 12,
          fill: const Color(0x99111731),
          accent: Quests.purple,
          bracketLength: 9,
          child: Center(
            child: QuestIcon(glyph: glyph, size: 20, color: Ink2.primary),
          ),
        ),
      ),
    ),
  );
}

class HudPage extends StatelessWidget {
  const HudPage({
    super.key,
    required this.kicker,
    required this.title,
    required this.body,
    this.trailing,
    this.tint = Quests.purple,
  });

  final String kicker;
  final String title;
  final Widget body;
  final Widget? trailing;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Quests.page,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ShellGlow(tint: tint),
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    D.pageGutter,
                    8,
                    D.pageGutter,
                    6,
                  ),
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      children: <Widget>[
                        GlassButton(
                          glyph: QuestGlyph.back,
                          sound: Sfx.back,
                          semanticLabel: 'Back',
                          onTap: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                kicker,
                                maxLines: 1,
                                style: T.questKicker.copyWith(
                                  fontSize: 10.5,
                                  color: tint,
                                ),
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  style: T.questHeadline.copyWith(fontSize: 24),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (trailing != null) ...<Widget>[
                          const SizedBox(width: 10),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HudSwitch extends StatelessWidget {
  const HudSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.tone = Quests.green,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: Pressable(
        sound: null,
        pressedScale: 0.92,
        onTap: () {
          GameAudio.play(value ? Sfx.toggleOff : Sfx.toggleOn);
          onChanged(!value);
        },
        child: SizedBox(
          width: 56,
          height: 30,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: value ? 1 : 0),
            duration: const Duration(milliseconds: 360),
            curve: D.softPop,
            builder: (BuildContext context, double v, Widget? _) {
              final lit = v.clamp(0.0, 1.0);
              final colour = Color.lerp(Quests.locked, tone, lit)!;
              return HudPanel(
                cut: 8,
                fill: Color.lerp(
                  const Color(0xFF10131F),
                  tone.withValues(alpha: 0.18),
                  lit,
                )!,
                edge: colour.withValues(alpha: 0.35 + 0.35 * lit),
                accent: colour,
                brackets: false,
                glow: 0.35 * lit,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Align(
                    alignment: Alignment(-1 + 2 * v, 0),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: HudPanel(
                        cut: 6,
                        fill: colour,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.white.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.15),
                          ],
                        ),
                        edge: Colors.white.withValues(alpha: 0.4),
                        brackets: false,
                        scanlines: false,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HudSegmented<V> extends StatelessWidget {
  const HudSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.tone = Quests.blue,
    this.height = 36,
  });

  final Map<V, String> options;
  final V value;
  final ValueChanged<V> onChanged;
  final Color tone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final keys = options.keys.toList();
    final index = keys.indexOf(value);
    return SizedBox(
      height: height,
      child: HudPanel(
        cut: 10,
        fill: const Color(0xFF0B0E19),
        brackets: false,
        padding: const EdgeInsets.all(3),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final slot = c.maxWidth / keys.length;
            return Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: D.emphasized,
                  left: slot * index,
                  top: 0,
                  bottom: 0,
                  width: slot,
                  child: HudPanel(
                    cut: 8,
                    fill: tone.withValues(alpha: 0.22),
                    edge: tone.withValues(alpha: 0.7),
                    accent: tone,
                    glow: 0.3,
                    brackets: false,
                    child: const SizedBox.expand(),
                  ),
                ),
                Row(
                  children: <Widget>[
                    for (final key in keys)
                      Expanded(
                        child: Pressable(
                          sound: key == value ? null : Sfx.nav,
                          pressedScale: 0.94,
                          onTap: () {
                            if (key != value) onChanged(key);
                          },
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 240),
                              style: T.navLabel.copyWith(
                                fontSize: 11.5,
                                color: key == value
                                    ? Color.lerp(tone, Ink2.bright, 0.55)
                                    : Ink2.muted,
                              ),
                              child: Text(options[key]!),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class HexAvatar extends StatelessWidget {
  const HexAvatar({
    super.key,
    required this.tone,
    this.size = 44,
    this.initials,
    this.image,
    this.glow = 0.35,
  });

  final Color tone;
  final double size;
  final String? initials;
  final String? image;
  final double glow;

  @override
  Widget build(BuildContext context) {
    final box = Size(size, size * 1.12);
    final img = image;
    return PolygonPane(
      size: box,
      sides: 6,
      cornerRadius: size * 0.12,
      edgeWidth: 1.8,
      edge: Color.lerp(tone, Ink2.bright, 0.2)!,
      glow: tone.withValues(alpha: 0.7),
      glowStrength: glow,
      fill: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color.lerp(tone, Colors.black, 0.45)!,
          const Color(0xFF090C18),
        ],
      ),
      child: img != null
          ? ClipPath(
              clipper: _HexClipper(size * 0.12),
              child: SizedBox(
                width: box.width - 4,
                height: box.height - 4,
                child: Image.asset(
                  img,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  initials ?? '',
                  style: T.disp(
                    size * 0.32,
                    weight: 900,
                    italic: false,
                    color: Color.lerp(tone, Ink2.bright, 0.6)!,
                  ),
                ),
              ),
            ),
    );
  }
}

class _HexClipper extends CustomClipper<Path> {
  const _HexClipper(this.radius);

  final double radius;

  @override
  Path getClip(Size size) => polygonPath(size, sides: 6, cornerRadius: radius);

  @override
  bool shouldReclip(_HexClipper old) => old.radius != radius;
}

class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.glyph,
    required this.tone,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.sound = Sfx.open,
  });

  final QuestGlyph glyph;
  final Color tone;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Sfx? sound;

  @override
  Widget build(BuildContext context) {
    final row = HudPanel(
      cut: 13,
      accent: tone,
      accentStrength: 0.6,
      edge: tone.withValues(alpha: 0.16),
      bracketLength: 10,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 62,
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tone.withValues(alpha: 0.14),
                border: Border.all(color: tone.withValues(alpha: 0.32)),
              ),
              child: Center(
                child: QuestIcon(
                  glyph: glyph,
                  size: 19,
                  color: tone,
                  highlight: Color.lerp(tone, Ink2.bright, 0.45),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.questTitle.copyWith(fontSize: 14.5),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: T.questBlurb.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                const QuestIcon(
                  glyph: QuestGlyph.chevron,
                  size: 16,
                  color: Ink2.muted,
                  strokeWidth: 8,
                ),
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return Pressable(
      onTap: onTap,
      sound: sound,
      pressedScale: 0.98,
      child: row,
    );
  }
}

class HudChip extends StatelessWidget {
  const HudChip({super.key, required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 24,
    child: HudPanel(
      cut: 7,
      fill: tone.withValues(alpha: 0.14),
      edge: tone.withValues(alpha: 0.45),
      accent: tone,
      brackets: false,
      scanlines: false,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          maxLines: 1,
          style: T.rewardLabel.copyWith(color: tone, letterSpacing: 1.0),
        ),
      ),
    ),
  );
}

void showHudToast(
  BuildContext context,
  String message, {
  Color tone = Quests.purple,
  QuestGlyph glyph = QuestGlyph.check,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext context) => _Toast(
      message: message,
      tone: tone,
      glyph: glyph,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.tone,
    required this.glyph,
    required this.onDone,
  });

  final String message;
  final Color tone;
  final QuestGlyph glyph;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 2400),
          )
          ..forward().whenCompleteOrCancel(() {
            if (mounted) widget.onDone();
          });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 10;
    return Positioned(
      left: D.pageGutter,
      right: D.pageGutter,
      top: top,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? child) {
            final v = _c.value;
            final inT = D.softPop.transform((v / 0.18).clamp(0.0, 1.0));
            final out = ((v - 0.82) / 0.18).clamp(0.0, 1.0);
            return Opacity(
              opacity: (inT.clamp(0.0, 1.0)) * (1 - out),
              child: Transform.translate(
                offset: Offset(0, -30 * (1 - inT) - 20 * out),
                child: child,
              ),
            );
          },
          child: Material(
            type: MaterialType.transparency,
            child: HudPanel(
              cut: 12,
              fill: const Color(0xF20E1120),
              accent: widget.tone,
              edge: widget.tone.withValues(alpha: 0.5),
              glow: 0.4,
              rail: true,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  QuestIcon(
                    glyph: widget.glyph,
                    size: 18,
                    color: widget.tone,
                    highlight: Color.lerp(widget.tone, Ink2.bright, 0.5),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: T.questTitle.copyWith(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<R?> showHudOverlay<R>(
  BuildContext context, {
  required WidgetBuilder builder,
  Alignment alignment = Alignment.center,
  bool dismissible = true,
}) {
  GameAudio.play(Sfx.open);
  return showGeneralDialog<R>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Dismiss',
    barrierColor: const Color(0xB3020309),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder:
        (BuildContext context, Animation<double> a1, Animation<double> a2) =>
            SafeArea(
              child: Align(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.all(D.pageGutter),
                  child: Material(
                    type: MaterialType.transparency,
                    child: builder(context),
                  ),
                ),
              ),
            ),
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondary,
          Widget child,
        ) {
          final a = CurvedAnimation(
            parent: animation,
            curve: D.softPop,
            reverseCurve: Curves.easeIn,
          );
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: AnimatedBuilder(
              animation: a,
              builder: (BuildContext context, Widget? child) =>
                  Transform.translate(
                    offset: Offset(
                      0,
                      (1 - a.value) * (alignment.y > 0 ? 60 : 24),
                    ),
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * a.value,
                      child: child,
                    ),
                  ),
              child: child,
            ),
          );
        },
  );
}

Future<bool> showHudConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  Color tone = Quests.rose,
}) async {
  final result = await showHudOverlay<bool>(
    context,
    builder: (BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: HudPanel(
        cut: 18,
        fill: const Color(0xFA0D1020),
        accent: tone,
        edge: tone.withValues(alpha: 0.45),
        glow: 0.4,
        rail: true,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: T.questHeadline.copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              message,
              style: T.questBlurb.copyWith(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: Pressable(
                    sound: Sfx.back,
                    onTap: () => Navigator.of(context).pop(false),
                    child: SizedBox(
                      height: 46,
                      child: HudPanel(
                        cut: 12,
                        fill: const Color(0xFF141726),
                        brackets: false,
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: T.navLabel.copyWith(
                              fontSize: 13,
                              color: Ink2.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Pressable(
                    sound: Sfx.confirm,
                    onTap: () => Navigator.of(context).pop(true),
                    child: BevelButton(
                      height: 46,
                      cut: 12,
                      gradient: LinearGradient(
                        colors: <Color>[
                          tone,
                          Color.lerp(tone, Colors.black, 0.25)!,
                        ],
                      ),
                      glowColor: tone,
                      child: Text(
                        confirmLabel,
                        style: T.button.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

class HudAction {
  const HudAction({
    required this.label,
    required this.glyph,
    required this.tone,
    required this.onSelected,
  });

  final String label;
  final QuestGlyph glyph;
  final Color tone;
  final VoidCallback onSelected;
}

Future<void> showHudActions(
  BuildContext context, {
  required String title,
  required List<HudAction> actions,
}) {
  return showHudOverlay<void>(
    context,
    alignment: Alignment.bottomCenter,
    builder: (BuildContext sheet) => HudPanel(
      cut: 18,
      fill: const Color(0xFA0D1020),
      accent: Quests.purple,
      edge: Quests.purple.withValues(alpha: 0.35),
      glow: 0.3,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HudHeading(title: title, accent: Quests.purple),
          const SizedBox(height: 12),
          for (final action in actions) ...<Widget>[
            MenuRow(
              glyph: action.glyph,
              tone: action.tone,
              title: action.label,
              sound: Sfx.confirm,
              onTap: () {
                Navigator.of(sheet).pop();
                action.onSelected();
              },
            ),
            const SizedBox(height: 8),
          ],
          Pressable(
            sound: Sfx.back,
            onTap: () => Navigator.of(sheet).pop(),
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  'CLOSE',
                  style: T.navLabel.copyWith(fontSize: 12.5),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
