import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/conversation.dart';
import '../../scene/frame.dart';
import '../../scene/stage.dart';
import 'home_popovers.dart';

TextStyle get cardStyle => inter(13, 450, color: const Color(0xFFF3EBEA), height: 15.5 / 13);

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.presence,
    required this.arriving,
    required this.intro,
    required this.partner,
    required this.stage,
  });

  final Animation<double> presence;
  final bool arriving;
  final bool intro;
  final Scene? partner;
  final StageState stage;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _focus;
  final _field = TextEditingController();
  final _node = FocusNode();
  final _fieldKey = GlobalKey();
  final List<GlobalKey> _cardKeys = [for (final _ in Script.suggestions) GlobalKey()];
  Popover? _popover;
  String _model = 'Opus 4.8';

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _focus = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _node.addListener(() {
      if (_node.hasFocus) {
        _focus.animateTo(1, curve: Curves.easeOutCubic);
      } else {
        _focus.animateBack(0, curve: Curves.easeOutCubic);
      }
    });
    _field.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _idle.dispose();
    _focus.dispose();
    _field.dispose();
    _node.dispose();
    super.dispose();
  }

  void _toggle(Popover which) {
    setState(() => _popover = _popover == which ? null : which);
  }

  void _openCard(int index) {
    final (label, prompt) = Script.suggestions[index];
    final context = _cardKeys[index].currentContext;
    final rect = context == null ? null : widget.stage.localRect(context);
    widget.stage.director.sendFromHome(
      prompt,
      source: rect,
      label: label,
      style: cardStyle,
      fill: const Color(0x66000000),
    );
  }

  void _submit() {
    final text = _field.text.trim();
    if (text.isEmpty) {
      widget.stage.go(Scene.voice);
      return;
    }
    final context = _fieldKey.currentContext;
    final rect = context == null ? null : widget.stage.localRect(context);
    widget.stage.director.sendFromHome(
      text,
      source: rect,
      label: text,
      style: inter(16, 400, color: const Color(0xFFF1E9E6), height: 1.25),
    );
    _field.clear();
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedBuilder(
      animation: Listenable.merge([widget.presence, _focus]),
      builder: (context, _) {
        final raw = widget.presence.value;
        final settled = widget.arriving && raw >= 1;
        final flow = widget.arriving && !widget.intro ? span(raw, 0.22, 1) : raw;
        final focus = _focus.value;
        final lift = inset;
        final showMic = settled || (widget.arriving && widget.intro);
        return Stack(
          children: [
            _header(frame, flow),
            _headline(frame, flow, focus),
            _cards(frame, flow, focus),
            _panel(frame, flow, lift, focus, showMic),
            if (_popover != null && settled)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _popover = null),
                ),
              ),
            if (settled)
              PopoverLayer(
                which: _popover,
                frame: frame,
                model: _model,
                onModel: (model) => setState(() {
                  _model = model;
                  _popover = null;
                }),
                onHistory: () {
                  setState(() => _popover = null);
                  widget.stage.director.openHistory();
                },
                dockLift: lift,
              ),
          ],
        );
      },
    );
  }

  double _in(double flow, double begin, double end, [Curve curve = Curves.easeOutCubic]) {
    if (widget.arriving) {
      return span(flow, begin, end, curve);
    }
    return 1 - span(flow, begin * 0.5, math.min(end * 0.55, 1), Curves.easeInCubic);
  }

  Widget _header(Frame frame, double flow) {
    final logo = _in(flow, 0.02, 0.42, Curves.easeOutBack);
    final draw = widget.arriving ? span(flow, 0.05, 0.6, Curves.easeInOutCubic) : 1.0;
    final greet = _in(flow, 0.12, 0.5);
    final bell = _in(flow, 0.18, 0.55, Curves.easeOutBack);
    final menu = _in(flow, 0.24, 0.6, Curves.easeOutBack);
    return Positioned(
      left: 0,
      right: 0,
      top: frame.headerY - 20,
      height: 40,
      child: Stack(
        children: [
          Positioned(
            left: 25,
            top: 0.5,
            child: Reveal(
              t: logo.clamp(0.0, 1.0),
              scale: 0.6,
              offset: Offset.zero,
              child: Transform.rotate(
                angle: (1 - logo) * -0.6,
                child: AiraLogo(size: 39, draw: draw),
              ),
            ),
          ),
          Positioned(
            left: 75,
            top: 3,
            child: Reveal(
              t: greet,
              offset: const Offset(-12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Roobinium,', style: inter(13, 420, color: const Color(0x80FFFFFF), height: 16.5 / 13)),
                  Text('Welcome back', style: inter(13, 450, color: const Color(0xF2FFFFFF), height: 16.5 / 13)),
                ],
              ),
            ),
          ),
          Positioned(
            right: 63.5,
            top: 0,
            child: Reveal(
              t: bell.clamp(0.0, 1.0),
              scale: 0.5,
              offset: Offset.zero,
              child: GlassCircle(
                onTap: () => _toggle(Popover.alerts),
                child: _BellWithDot(idle: _idle, active: _popover == Popover.alerts),
              ),
            ),
          ),
          Positioned(
            right: 15.5,
            top: 0,
            child: Reveal(
              t: menu.clamp(0.0, 1.0),
              scale: 0.5,
              offset: Offset.zero,
              child: GlassCircle(
                onTap: () => _toggle(Popover.history),
                child: GlyphIcon(
                  _popover == Popover.history ? Glyph.close : Glyph.menu,
                  size: 16,
                  color: const Color(0xE6FFFFFF),
                  stroke: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headline(Frame frame, double flow, double focus) {
    const lines = [
      ['What', 'are', 'we'],
      ['building', 'today?'],
    ];
    final style = inter(43.5, 460, color: const Color(0xFFF6F3F2), height: 44.5 / 43.5, spacing: -0.1);
    var index = 0;
    final rows = <Widget>[];
    for (final line in lines) {
      final words = <Widget>[];
      for (var i = 0; i < line.length; i++) {
        final begin = 0.2 + index * 0.055;
        final double t;
        final double rise;
        if (widget.arriving) {
          t = span(flow, begin, begin + 0.42, Curves.easeOutCubic);
          rise = 26 * (1 - t);
        } else {
          final leave = span(flow, index * 0.035, index * 0.035 + 0.36, Curves.easeInCubic);
          t = 1 - leave;
          rise = -30 * leave;
        }
        final word = i == line.length - 1 ? line[i] : '${line[i]} ';
        words.add(
          Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, rise),
              child: Text(word, style: style),
            ),
          ),
        );
        index++;
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: words));
    }
    final hide = 1 - focus;
    return Positioned(
      left: 25,
      top: frame.cardsTop - 112.8 - 24 * focus,
      child: Opacity(
        opacity: hide.clamp(0.0, 1.0),
        child: IgnorePointer(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
        ),
      ),
    );
  }

  Widget _cards(Frame frame, double flow, double focus) {
    final count = Script.suggestions.length;
    return Positioned(
      left: 0,
      right: 0,
      top: frame.cardsTop - 20 * focus,
      height: 118,
      child: Opacity(
        opacity: (1 - focus).clamp(0.0, 1.0),
        child: IgnorePointer(
          ignoring: focus > 0.5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: count,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final double t;
              final Offset shift;
              if (widget.arriving) {
                final begin = 0.4 + index * 0.07;
                t = span(flow, begin, math.min(begin + 0.45, 1), Curves.easeOutCubic);
                shift = Offset(70 * (1 - t), 0);
              } else {
                final leave = span(flow, index * 0.04, index * 0.04 + 0.4, Curves.easeInCubic);
                t = 1 - leave;
                shift = Offset(0, 40 * leave);
              }
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: shift,
                  child: _SuggestionCard(
                    key: _cardKeys[index],
                    label: Script.suggestions[index].$1,
                    idle: _idle,
                    phase: index / count,
                    onTap: () => _openCard(index),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _panel(Frame frame, double flow, double lift, double focus, bool showMic) {
    final panel = _in(flow, 0.3, 0.85);
    final dock = _in(flow, 0.5, 0.95, Curves.easeOutBack);
    final mic = widget.arriving ? span(flow, 0.62, 1.0, Curves.elasticOut) : 1.0;
    final hasText = _field.text.trim().isNotEmpty;
    final panelTop = math.max(frame.panelTop - lift + (frame.panelHeight - 250) * focus, frame.headerY + 60);
    final dockY = frame.dockY - lift + (lift > 0 ? frame.safeBottom : 0);
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: panelTop + 60 * (1 - panel),
            bottom: 0,
            child: Opacity(
              opacity: panel.clamp(0.0, 1.0),
              child: CustomPaint(painter: _PanelPainter(focus)),
            ),
          ),
          Positioned(
            left: 29,
            right: 29,
            top: panelTop + 29 + 60 * (1 - panel),
            child: Opacity(
              opacity: panel.clamp(0.0, 1.0),
              child: SizedBox(
                key: _fieldKey,
                child: TextField(
                  controller: _field,
                  focusNode: _node,
                  minLines: 1,
                  maxLines: 4,
                  cursorWidth: 1.6,
                  cursorHeight: 18,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                  style: inter(16, 400, color: const Color(0xFFF1E9E6), height: 1.25),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Ask AI a question or describe your idea',
                    hintStyle: inter(16, 400, color: const Color(0x61FFFFFF), height: 1.25),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: dockY - 24,
            child: Reveal(
              t: dock.clamp(0.0, 1.0),
              scale: 0.6,
              offset: const Offset(0, 16),
              child: GlassCircle(
                size: 48,
                tint: 0.1,
                onTap: () {},
                child: const GlyphIcon(Glyph.clip, size: 19, color: Color(0xFFB9ADA9), stroke: 1.5),
              ),
            ),
          ),
          Positioned(
            left: 86,
            top: dockY - 24,
            child: Reveal(
              t: _in(flow, 0.55, 1.0, Curves.easeOutBack).clamp(0.0, 1.0),
              scale: 0.7,
              offset: const Offset(0, 16),
              child: _ModelPill(model: _model, open: _popover == Popover.model, onTap: () => _toggle(Popover.model)),
            ),
          ),
          if (showMic)
            Positioned(
              left: frame.width - 53 - 24,
              top: dockY - 24,
              child: Transform.scale(
                scale: mic.clamp(0.0, 1.3),
                child: Pressable(
                  onTap: _submit,
                  child: _BreathingMic(idle: _idle, send: hasText),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PanelPainter extends CustomPainter {
  const _PanelPainter(this.focus);

  final double focus;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndCorners(
      Offset.zero & Size(size.width, size.height + 40),
      topLeft: const Radius.circular(32),
      topRight: const Radius.circular(32),
    );
    canvas.drawRRect(rrect, Paint()..color = Color.lerp(const Color(0x30000000), const Color(0x59000000), focus)!);
    canvas.drawCircle(
      Offset(size.width, size.height),
      size.width * 0.5,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x2EFF7A1E), Color(0x00FF7A1E)],
        ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.5)),
    );
    canvas.drawRRect(
      rrect.deflate(0.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
          stops: [0, math.min(1, 90 / size.height)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_PanelPainter oldDelegate) => oldDelegate.focus != focus;
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({super.key, required this.label, required this.idle, required this.phase, required this.onTap});

  final String label;
  final Animation<double> idle;
  final double phase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.95,
      child: Container(
        width: 153,
        height: 118,
        decoration: BoxDecoration(
          color: const Color(0x66000000),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x0DFFFFFF), width: 0.8),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 11.4,
              top: 11.4,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: idle,
                  builder: (context, child) {
                    final local = (idle.value + phase) % 1.0;
                    final pulse = math.sin(math.pi * span(local, 0.0, 0.14));
                    return Transform.rotate(
                      angle: pulse * 0.5,
                      child: Transform.scale(scale: 1 + pulse * 0.22, child: child),
                    );
                  },
                  child: const GlyphIcon(Glyph.sparkle, size: 19, color: Tone.flame),
                ),
              ),
            ),
            Positioned(
              left: 13,
              right: 10,
              bottom: 8.5,
              child: Text(label, style: cardStyle, maxLines: 2, softWrap: false, overflow: TextOverflow.clip),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelPill extends StatelessWidget {
  const _ModelPill({required this.model, required this.open, required this.onTap});

  final String model;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 48,
        constraints: const BoxConstraints(minWidth: 118),
        padding: const EdgeInsets.only(left: 15.5, right: 14),
        decoration: BoxDecoration(
          color: const Color(0x17FFFFFF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(model, key: ValueKey(model), style: inter(14, 450, color: const Color(0xFFCFC5C2))),
            ),
            const SizedBox(width: 13),
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: const GlyphIcon(Glyph.chevron, size: 15, color: Color(0xFFBDB3AF), stroke: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathingMic extends StatelessWidget {
  const _BreathingMic({required this.idle, required this.send});

  final Animation<double> idle;
  final bool send;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: idle,
        builder: (context, _) {
          final breath = 0.5 + 0.5 * math.sin(idle.value * math.pi * 4);
          return SizedBox.square(
            dimension: 48,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                MicDisc(size: 48, glyph: send ? Glyph.arrowUp : Glyph.mic, glyphSize: send ? 22 : 26, glow: 0.25 + breath * 0.35),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BellWithDot extends StatelessWidget {
  const _BellWithDot({required this.idle, required this.active});

  final Animation<double> idle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: idle,
      builder: (context, child) {
        final local = idle.value;
        final swing = local < 0.12 ? math.sin(local / 0.12 * math.pi * 4) * (1 - local / 0.12) * 0.35 : 0.0;
        return Transform.rotate(angle: swing, alignment: const Alignment(0, -0.8), child: child);
      },
      child: GlyphIcon(Glyph.bell, size: 17, color: active ? Tone.snow : const Color(0xE6FFFFFF), stroke: 1.2),
    );
  }
}
