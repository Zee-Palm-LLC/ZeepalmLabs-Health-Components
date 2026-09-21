import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/conversation.dart';
import '../../scene/frame.dart';
import '../../scene/orb.dart';
import '../../scene/stage.dart';
import 'chat_layout.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.presence,
    required this.arriving,
    required this.partner,
    required this.stage,
    this.flying,
  });

  final Animation<double> presence;
  final bool arriving;
  final Scene? partner;
  final StageState stage;
  final Message? flying;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final Set<int> _known = {};
  final _node = FocusNode();
  late final Message? _flying;
  late final Message? _landing;

  Conversation get _conversation => widget.stage.director.conversation;

  @override
  void initState() {
    super.initState();
    for (final message in _conversation.messages) {
      _known.add(message.id);
    }
    final fromVoice = widget.partner == Scene.voice;
    _flying = widget.flying;
    _landing = fromVoice ? _conversation.messages.where((m) => !m.mine).firstOrNull : null;
    _conversation.addListener(_changed);
    widget.stage.director.input.addListener(_typed);
  }

  @override
  void dispose() {
    _conversation.removeListener(_changed);
    widget.stage.director.input.removeListener(_typed);
    _node.dispose();
    super.dispose();
  }

  void _typed() => setState(() {});

  void _changed() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _follow());
  }

  void _follow() {
    final scroll = widget.stage.director.chatScroll;
    if (!scroll.hasClients) return;
    final max = scroll.position.maxScrollExtent;
    if (max - scroll.offset > 1) {
      scroll.animateTo(max, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final layout = ChatLayout(frame.width, _conversation.messages, working: _conversation.working);
    final director = widget.stage.director;
    final inputLift = inset > 0 ? inset + 10 - frame.inputBottom : 0.0;

    return AnimatedBuilder(
      animation: widget.presence,
      builder: (context, _) {
        final flow = widget.presence.value;
        final settled = widget.arriving && flow >= 1;
        final bar = widget.arriving ? span(flow, 0.35, 0.95, Curves.easeOutCubic) : 1 - span(flow, 0.0, 0.3, Curves.easeInCubic);
        final viewport = frame.inputTop - inputLift - 16;
        final contentHeight = frame.chatListTop + layout.contentBottom + 24;
        return Stack(
          children: [
            Positioned.fill(
              bottom: frame.height - viewport,
              child: _TopFade(
                enabled: contentHeight > viewport,
                start: frame.pillBottom,
                end: frame.chatListTop - 6,
                child: SingleChildScrollView(
                  controller: director.chatScroll,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: SizedBox(
                    height: math.max(contentHeight, viewport + 1),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (var i = 0; i < layout.slots.length; i++) ..._tiles(layout, i, frame, flow, settled),
                        if (_conversation.working)
                          AnimatedPositioned(
                            key: const ValueKey('working'),
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                            left: 59,
                            top: frame.chatListTop + layout.workingTop,
                            child: _Appear(
                              child: ShimmerText(
                                'Aira is working...',
                                style: inter(11.25, 450, color: const Color(0xFF6F6966), height: 14 / 11.25),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 17.5,
              right: 17.5,
              bottom: frame.inputBottom + inputLift - 40 * (1 - bar),
              height: frame.inputHeight,
              child: Opacity(
                opacity: bar.clamp(0.0, 1.0),
                child: _InputBar(
                  controller: director.input,
                  node: _node,
                  showMic: settled,
                  onSend: () => director.send(director.input.text),
                  onMic: () => widget.stage.go(Scene.voice),
                  onTyped: director.userTyped,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _tiles(ChatLayout layout, int index, Frame frame, double flow, bool settled) {
    final slot = layout.slots[index];
    final message = slot.message;
    final isNew = !_known.contains(message.id);
    if (isNew && settled) _known.add(message.id);
    final count = layout.slots.length;
    double reveal;
    Offset drift;
    if (widget.arriving) {
      if (widget.partner == null && flow < 1) {
        final begin = 0.15 + index * 0.08;
        reveal = span(flow, begin, math.min(begin + 0.45, 1), Curves.easeOutCubic);
        drift = Offset(0, 22 * (1 - reveal));
      } else {
        reveal = 1;
        drift = Offset.zero;
      }
    } else {
      final order = count - 1 - index;
      final leave = span(flow, order * 0.03, math.min(order * 0.03 + 0.3, 1), Curves.easeInCubic);
      reveal = 1 - leave;
      drift = Offset(0, 36 * leave);
    }
    final hideBubble = !settled && widget.arriving && message == _flying;
    final landing = message == _landing;
    final hideAvatar = !settled && widget.arriving && landing;
    final popIn = widget.arriving && widget.partner != null && !message.mine && message != _flying;
    final tiles = <Widget>[];
    final bubble = slot.bubble.shift(Offset(0, frame.chatListTop));

    Widget wrap(Widget child, {Alignment anchor = Alignment.center}) {
      Widget result = child;
      if (popIn && flow < 1) {
        final t = span(flow, 0.7, 1.0, Curves.easeOutBack);
        result = Opacity(
          opacity: span(flow, 0.7, 0.9).clamp(0.0, 1.0),
          child: Transform.scale(scale: lerp(0.4, 1, t), alignment: anchor, child: result),
        );
      }
      if (reveal < 1) {
        result = Opacity(
          opacity: reveal.clamp(0.0, 1.0),
          child: Transform.translate(offset: drift, child: result),
        );
      }
      return result;
    }

    if (slot.avatar != null) {
      final avatar = slot.avatar!.shift(Offset(0, frame.chatListTop));
      tiles.add(
        AnimatedPositioned.fromRect(
          key: ValueKey('avatar${message.id}'),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          rect: avatar,
          child: hideAvatar
              ? const SizedBox.shrink()
              : wrap(
                  _Enter(
                    fresh: isNew && settled,
                    anchor: Alignment.center,
                    child: ValueListenableBuilder<double>(
                      valueListenable: message.reveal,
                      builder: (context, value, _) {
                        final active = message.thinking || value < 1;
                        return Orb(size: 24, seed: 0.3 + message.id * 0.17, live: active);
                      },
                    ),
                  ),
                ),
        ),
      );
    }
    tiles.add(
      AnimatedPositioned.fromRect(
        key: ValueKey('bubble${message.id}'),
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeOutBack,
        rect: bubble,
        child: hideBubble
            ? const SizedBox.shrink()
            : wrap(
                _Enter(
                  fresh: isNew && settled,
                  anchor: message.mine ? Alignment.bottomRight : Alignment.topLeft,
                  rise: message.mine ? 26 : 0,
                  child: message.mine ? _MineBubble(message: message) : _AiraBubble(message: message, textWidth: slot.textWidth),
                ),
                anchor: message.mine ? Alignment.bottomRight : Alignment.topLeft,
              ),
      ),
    );
    return tiles;
  }
}

class _TopFade extends StatelessWidget {
  const _TopFade({required this.enabled, required this.start, required this.end, required this.child});

  final bool enabled;
  final double start;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x00000000), Color(0xFF000000), Color(0xFF000000)],
          stops: [start / bounds.height, end / bounds.height, 1],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class _Enter extends StatefulWidget {
  const _Enter({required this.fresh, required this.child, this.anchor = Alignment.center, this.rise = 0});

  final bool fresh;
  final Widget child;
  final Alignment anchor;
  final double rise;

  @override
  State<_Enter> createState() => _EnterState();
}

class _EnterState extends State<_Enter> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: widget.fresh ? 0 : 1);
    if (widget.fresh) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = _c.value;
        if (v >= 1) return child!;
        final pop = Curves.easeOutBack.transform(v);
        return Opacity(
          opacity: span(v, 0, 0.45).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, widget.rise * (1 - Curves.easeOutCubic.transform(v))),
            child: Transform.scale(scale: lerp(0.6, 1, pop), alignment: widget.anchor, child: child),
          ),
        );
      },
    );
  }
}

class _Appear extends StatelessWidget {
  const _Appear({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(-8 * (1 - t), 0), child: child),
      ),
    );
  }
}

class _MineBubble extends StatelessWidget {
  const _MineBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _MinePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(ChatLayout.minePadX, ChatLayout.minePadY, ChatLayout.minePadX - 1, 0),
        child: Text(message.text, style: mineStyle),
      ),
    );
  }
}

class _MinePainter extends CustomPainter {
  const _MinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    paintMineBubble(canvas, RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)), 1);
  }

  @override
  bool shouldRepaint(_MinePainter oldDelegate) => false;
}

class _AiraBubble extends StatelessWidget {
  const _AiraBubble({required this.message, required this.textWidth});

  final Message message;
  final double textWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: message.thinking
              ? const Center(key: ValueKey('dots'), child: Dots())
              : Padding(
                  key: const ValueKey('text'),
                  padding: const EdgeInsets.fromLTRB(ChatLayout.airaPadX, ChatLayout.airaPadY, 0, 0),
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: textWidth + 1,
                    maxWidth: textWidth + 1,
                    maxHeight: double.infinity,
                    child: ValueListenableBuilder<double>(
                      valueListenable: message.reveal,
                      builder: (context, value, _) => _Streamed(text: message.text, progress: value),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Streamed extends StatelessWidget {
  const _Streamed({required this.text, required this.progress});

  final String text;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final style = bubbleStyle;
    if (progress >= 1) return Text(text, style: style);
    final words = text.split(' ');
    final head = progress * (words.length + 3);
    final spans = <TextSpan>[];
    for (var i = 0; i < words.length; i++) {
      final a = ((head - i) / 3).clamp(0.0, 1.0);
      final word = i == words.length - 1 ? words[i] : '${words[i]} ';
      spans.add(TextSpan(text: word, style: style.copyWith(color: style.color!.withValues(alpha: a))));
    }
    return Text.rich(TextSpan(children: spans));
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.node,
    required this.showMic,
    required this.onSend,
    required this.onMic,
    required this.onTyped,
  });

  final TextEditingController controller;
  final FocusNode node;
  final bool showMic;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final VoidCallback onTyped;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x8C000000),
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: const Color(0x12FFFFFF), width: 0.8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 17),
          Pressable(
            onTap: () {},
            child: const GlyphIcon(Glyph.clip, size: 19, color: Color(0xFF7F7774), stroke: 1.5),
          ),
          const SizedBox(width: 16.5),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: node,
              cursorWidth: 1.6,
              cursorHeight: 18,
              textInputAction: TextInputAction.send,
              onChanged: (_) => onTyped(),
              onSubmitted: (_) => onSend(),
              style: inter(16, 400, color: const Color(0xFFF1E9E6), height: 1.25),
              decoration: InputDecoration.collapsed(
                hintText: 'Ask AI a question',
                hintStyle: inter(16, 400, color: const Color(0xFF6F6966), height: 1.25),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: hasText
                    ? Pressable(
                        key: const ValueKey('send'),
                        onTap: onSend,
                        child: const MicDisc(size: 36, glyph: Glyph.arrowUp, glyphSize: 20),
                      )
                    : Opacity(
                        key: const ValueKey('mic'),
                        opacity: showMic ? 1 : 0,
                        child: Pressable(
                          onTap: onMic,
                          child: const GlyphIcon(Glyph.mic, size: 26, color: Color(0xFFF2F2F2), stroke: 1.8),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 5.5),
        ],
      ),
    );
  }
}
