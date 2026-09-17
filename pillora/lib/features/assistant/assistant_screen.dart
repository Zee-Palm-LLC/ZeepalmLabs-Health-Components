import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/icons/glyphs.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/aurora.dart';
import '../../core/widgets/common.dart';
import '../../data/assistant_brain.dart';
import 'chat_widgets.dart';
import 'orb.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

enum _Mood { idle, listening, thinking, speaking }

class _AssistantScreenState extends State<AssistantScreen> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _intro;
  late final AnimationController _chat;
  late final AnimationController _fly;
  late final AnimationController _poke;

  final ValueNotifier<double> _energy = ValueNotifier(0.1);
  final ValueNotifier<double> _pulse = ValueNotifier(0);
  final ValueNotifier<Offset> _tilt = ValueNotifier(Offset.zero);
  Offset _tiltTarget = Offset.zero;

  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _list = ScrollController();
  final List<ChatMessage> _messages = [];
  final Set<int> _streamed = {};

  _Mood _mood = _Mood.idle;
  int? _topic;
  Timer? _voiceTimer;
  Timer? _typeTimer;

  static const _introCard = 417.0;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
    _chat = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _poke = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _input.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
    startClock();
    clock.addListener(_breathe);
  }

  @override
  void dispose() {
    clock.removeListener(_breathe);
    _voiceTimer?.cancel();
    _typeTimer?.cancel();
    _intro.dispose();
    _chat.dispose();
    _fly.dispose();
    _poke.dispose();
    _energy.dispose();
    _pulse.dispose();
    _tilt.dispose();
    _input.dispose();
    _focus.dispose();
    _list.dispose();
    disposeClock();
    super.dispose();
  }

  void _breathe() {
    final s = clock.value;
    final arrival = window(_intro.value, 0.35, 0.8);
    final spike = math.sin(arrival * math.pi) * 0.9 + math.sin(_poke.value * math.pi) * 0.8;
    final target = switch (_mood) {
      _Mood.idle => 0.1 + 0.05 * wave(s, 4),
      _Mood.listening => 0.35 + 0.45 * (math.sin(s * 9.3) * math.sin(s * 3.7)).abs(),
      _Mood.thinking => 0.85,
      _Mood.speaking => 0.5 + 0.25 * math.sin(s * 11).abs(),
    };
    _energy.value += (math.max(target, spike) - _energy.value) * 0.09;
    _pulse.value += ((_mood == _Mood.listening ? 1.0 : 0.0) - _pulse.value) * 0.07;
    final next = Offset.lerp(_tilt.value, _tiltTarget, 0.1)!;
    if ((next - _tilt.value).distanceSquared > 0.00001) _tilt.value = next;
  }

  bool get _busy => _mood == _Mood.thinking || _mood == _Mood.speaking;

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _busy) return;
    HapticFeedback.lightImpact();
    _voiceTimer?.cancel();
    _typeTimer?.cancel();
    _fly.forward(from: 0);
    _input.clear();
    setState(() {
      _messages.add(ChatMessage(Speaker.user, text));
      _mood = _Mood.thinking;
    });
    if (_chat.value < 1) _chat.forward();
    _follow();
    Future.delayed(Duration(milliseconds: 900 + text.length * 8), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(Speaker.helper, AssistantBrain.reply(text)));
        _mood = _Mood.speaking;
      });
      _follow();
    });
  }

  void _follow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_list.hasClients) return;
      _list.animateTo(
        _list.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _toggleVoice() {
    HapticFeedback.selectionClick();
    if (_mood == _Mood.listening) {
      _voiceTimer?.cancel();
      setState(() => _mood = _Mood.idle);
      return;
    }
    if (_busy) return;
    _focus.unfocus();
    _input.clear();
    setState(() => _mood = _Mood.listening);
    _voiceTimer = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      setState(() => _mood = _Mood.idle);
      const prompt = AssistantBrain.voicePrompt;
      var typed = 0;
      _typeTimer = Timer.periodic(const Duration(milliseconds: 28), (timer) {
        typed++;
        _input.text = prompt.substring(0, typed);
        if (typed >= prompt.length) {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 380), () {
            if (mounted) _send();
          });
        }
      });
    });
  }

  void _pokeOrb() {
    HapticFeedback.mediumImpact();
    _poke.forward(from: 0);
    _toggleVoice();
  }

  void _pickTopic(int index) {
    setState(() => _topic = index);
    _send(AssistantBrain.topics[index].question);
  }

  void _reset() {
    _voiceTimer?.cancel();
    _typeTimer?.cancel();
    _chat.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _streamed.clear();
        _topic = null;
      });
    });
    setState(() => _mood = _Mood.idle);
  }

  Future<void> _openMenu() async {
    final choice = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: const Color(0x14000000),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, _) => _MoreMenu(animation: animation),
    );
    if (!mounted || choice == null) return;
    if (choice == 'new') _reset();
    if (choice == 'summary') _send('Generate summary');
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: Palette.canvas,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _chat,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -60 * Curves.easeInOutCubic.transform(_chat.value)),
                child: child,
              ),
              child: const AuroraHero(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: padding.top + 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(),
                _subtitle(),
                const SizedBox(height: 15),
                _topics(),
                const SizedBox(height: 32),
                Expanded(child: _cardArea(padding.bottom)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Entrance(
            animation: stage(_intro, 0, 0.35, curve: Curves.easeOutBack),
            offset: const Offset(-20, 0),
            scale: 0.5,
            child: CircleButton(glyph: Glyph.back, onTap: () => Navigator.of(context).maybePop()),
          ),
          Expanded(
            child: Entrance(
              animation: stage(_intro, 0.06, 0.4),
              offset: const Offset(0, -12),
              blur: 6,
              child: const Center(
                child: Text(
                  'AI helper',
                  style: TextStyle(
                    fontFamily: TextStyles.family,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Entrance(
            animation: stage(_intro, 0.08, 0.42, curve: Curves.easeOutBack),
            offset: const Offset(20, 0),
            scale: 0.5,
            child: CircleButton(glyph: Glyph.more, onTap: _openMenu),
          ),
        ],
      ),
    );
  }

  Widget _subtitle() {
    final style = TextStyles.headline.copyWith(color: Colors.white.withValues(alpha: 0.94), fontSize: 25.5);
    return AnimatedBuilder(
      animation: _chat,
      builder: (context, child) {
        final c = Curves.easeInOutCubic.transform(_chat.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            heightFactor: 1 - c,
            child: Opacity(opacity: (1 - c * 1.8).clamp(0.0, 1.0), child: child),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Entrance(
              animation: stage(_intro, 0.1, 0.45),
              offset: const Offset(0, 20),
              blur: 10,
              child: Text('Your smart assistant for', style: style),
            ),
            Entrance(
              animation: stage(_intro, 0.16, 0.5),
              offset: const Offset(0, 20),
              blur: 10,
              child: Text('medicine dose', style: style),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topics() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        clipBehavior: Clip.none,
        itemCount: AssistantBrain.topics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final topic = AssistantBrain.topics[i];
          final selected = _topic == i;
          return Entrance(
            animation: stage(_intro, 0.2 + i * 0.07, 0.6 + i * 0.07, curve: Curves.easeOutBack),
            offset: const Offset(60, 0),
            child: Pressable(
              onTap: () => _pickTopic(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.fromLTRB(14, 0, 18, 0),
                decoration: BoxDecoration(
                  color: selected ? Palette.deep : const Color(0xFFEDF0F1),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: selected
                      ? const [BoxShadow(color: Color(0x33154044), blurRadius: 16, offset: Offset(0, 6))]
                      : null,
                ),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      child: topic.emoji.isEmpty
                          ? const CapsuleArt(size: 20)
                          : Image.asset(topic.emoji, width: 21, height: 21),
                    ),
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyles.label.copyWith(
                        fontSize: 14,
                        color: selected ? Colors.white : const Color(0xFF2A2D2E),
                      ),
                      child: Text(topic.label),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cardArea(double safeBottom) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final full = constraints.maxHeight - 13 - math.max(safeBottom, 16);
        return AnimatedBuilder(
          animation: Listenable.merge([_chat, _intro]),
          builder: (context, _) {
            final c = Curves.easeInOutCubic.transform(_chat.value);
            final height = lerp(math.min(_introCard, full), full, c);
            final card = window(_intro.value, 0.22, 0.62, const Cubic(0.2, 0.9, 0.25, 1.05));
            final back = window(_intro.value, 0.32, 0.7, Curves.easeOutCubic);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: lerp(30, 0, back),
                  left: 24,
                  right: 24,
                  height: 60,
                  child: Opacity(
                    opacity: back,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFE6E7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 13 + (1 - card) * 90,
                  left: 16,
                  right: 16,
                  height: height,
                  child: Opacity(
                    opacity: card.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: lerp(0.92, 1, card),
                      alignment: Alignment.topCenter,
                      child: _card(height, c),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _card(double height, double c) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Color(0x0D0B2A2D), blurRadius: 30, offset: Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (c > 0) _conversation(c),
                _greeting(c),
                _orb(width, c),
                _chatHeader(c),
                Positioned(top: 16, right: 16, child: _micButton()),
                Positioned(left: 16, right: 16, bottom: 68, height: 52, child: _composer()),
                Positioned(left: 0, right: 0, bottom: 16, height: 38, child: _suggestions()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _orb(double width, double c) {
    const canvas = 230.0;
    final introCentre = Offset(width / 2, 105);
    const chatCentre = Offset(40, 38);
    final centre = Offset.lerp(introCentre, chatCentre, c)!;
    final scale = lerp(1, 44 / 118, c);
    final appear = window(_intro.value, 0.34, 0.9, Curves.elasticOut);
    return Positioned(
      left: centre.dx - canvas / 2,
      top: centre.dy - canvas / 2,
      width: canvas,
      height: canvas,
      child: Transform.scale(
        scale: scale * appear,
        child: GestureDetector(
          onTap: _pokeOrb,
          onPanUpdate: (d) {
            _tiltTarget = Offset(
              (_tiltTarget.dx + d.delta.dx / 60).clamp(-1.0, 1.0),
              (_tiltTarget.dy + d.delta.dy / 60).clamp(-1.0, 1.0),
            );
          },
          onPanEnd: (_) => _tiltTarget = Offset.zero,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (e) =>
                _tiltTarget = Offset((e.localPosition.dx / canvas - 0.5) * 2, (e.localPosition.dy / canvas - 0.5) * 2),
            onExit: (_) => _tiltTarget = Offset.zero,
            child: AnimatedBuilder(
              animation: _poke,
              builder: (context, child) {
                final t = _poke.value;
                final squish = math.sin(t * math.pi * 4) * (1 - t) * 0.08;
                return Transform.scale(scaleX: 1 + squish, scaleY: 1 - squish, child: child);
              },
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: OrbPainter(clock: clock, energy: _energy, pulse: _pulse, tilt: _tilt),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _greeting(double c) {
    const words = ['Hi!', "I’m", 'your', 'medication', 'helper', 'ready', 'to', 'keep', 'you', 'on', 'track.'];
    const bright = 6;
    return Positioned(
      top: 196 - 40 * c,
      left: 24,
      right: 24,
      child: IgnorePointer(
        child: Opacity(
          opacity: (1 - c * 2.2).clamp(0.0, 1.0),
          child: AnimatedBuilder(
            animation: _intro,
            builder: (context, _) {
              final spans = <InlineSpan>[];
              for (var i = 0; i < words.length; i++) {
                final start = 0.5 + i * 0.03;
                final show = window(_intro.value, start, start + 0.12, Curves.easeOut);
                final ink = i < bright ? window(_intro.value, start + 0.1, start + 0.3, Curves.easeInOut) : 0.0;
                final color = Color.lerp(Palette.inkFaint, Palette.ink, ink)!.withValues(alpha: show);
                spans.add(
                  TextSpan(
                    text: i == words.length - 1 ? words[i] : '${words[i]} ',
                    style: TextStyle(color: color),
                  ),
                );
              }
              return Text.rich(
                TextSpan(children: spans),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: TextStyles.family,
                  fontSize: 19.5,
                  height: 1.42,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _chatHeader(double c) {
    if (c <= 0) return const SizedBox.shrink();
    final label = switch (_mood) {
      _Mood.idle => 'Online',
      _Mood.listening => 'Listening…',
      _Mood.thinking => 'Thinking…',
      _Mood.speaking => 'Replying…',
    };
    return Positioned(
      left: 72,
      top: 18,
      child: Opacity(
        opacity: window(c, 0.5, 1),
        child: Transform.translate(
          offset: Offset(16 * (1 - c), 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pillora AI', style: TextStyles.title),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Color(0xFF3DBE8B), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(label, key: ValueKey(label), style: TextStyles.caption),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conversation(double c) {
    return Positioned(
      top: 72,
      left: 0,
      right: 0,
      bottom: 128,
      child: Opacity(
        opacity: window(c, 0.4, 1),
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00FFFFFF), Colors.white, Colors.white, Color(0x00FFFFFF)],
            stops: [0, 0.035, 0.96, 1],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: ListView.builder(
            controller: _list,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            itemCount: _messages.length + (_mood == _Mood.thinking ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= _messages.length) {
                return const Padding(padding: EdgeInsets.only(top: 12), child: ThinkingBubble());
              }
              final message = _messages[i];
              final Widget bubble;
              if (message.speaker == Speaker.user) {
                bubble = UserBubble(key: ValueKey(message.id), text: message.text);
              } else {
                final fresh = _streamed.add(message.id);
                bubble = HelperBubble(
                  key: ValueKey(message.id),
                  text: message.text,
                  animate: fresh,
                  onDone: () {
                    if (mounted && _mood == _Mood.speaking) setState(() => _mood = _Mood.idle);
                  },
                );
              }
              return Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                child: bubble,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _micButton() {
    final listening = _mood == _Mood.listening;
    return Entrance(
      animation: stage(_intro, 0.45, 0.8, curve: Curves.easeOutBack),
      offset: Offset.zero,
      scale: 0.3,
      child: Pressable(
        onTap: _toggleVoice,
        scale: 0.88,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulse, clock]),
          builder: (context, child) {
            final pulse = _pulse.value;
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (pulse > 0.02)
                  for (var k = 0; k < 2; k++)
                    Builder(
                      builder: (context) {
                        final phase = (clock.value * 0.9 + k * 0.5) % 1;
                        return Container(
                          width: 48 + phase * 26,
                          height: 48 + phase * 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Palette.deep.withValues(alpha: (1 - phase) * 0.35 * pulse),
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: listening ? Palette.deep : const Color(0xFFEEF2F4),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: listening
                        ? const GlyphIcon(Glyph.stop, key: ValueKey('stop'), size: 20, color: Colors.white)
                        : const GlyphIcon(
                            Glyph.mic,
                            key: ValueKey('mic'),
                            size: 21,
                            color: Color(0xFF4B5256),
                            stroke: 1.5,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _composer() {
    final listening = _mood == _Mood.listening;
    final hasText = _input.text.isNotEmpty;
    return Entrance(
      animation: stage(_intro, 0.58, 0.9, curve: Curves.easeOutCubic),
      offset: const Offset(0, 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: _focus.hasFocus ? const Color(0x33154044) : const Color(0x00154044)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const GlyphIcon(Glyph.link, size: 19, color: Color(0xFF6B7174), stroke: 1.5),
            const SizedBox(width: 10),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: _input,
                    focusNode: _focus,
                    enabled: !listening,
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                    cursorColor: Palette.deep,
                    cursorWidth: 1.6,
                    style: TextStyles.label.copyWith(fontSize: 13.5, fontWeight: FontWeight.w400),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  if (!hasText)
                    IgnorePointer(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
                            child: child,
                          ),
                        ),
                        child: listening
                            ? Row(
                                key: const ValueKey('listening'),
                                children: [
                                  Text(
                                    'Listening',
                                    style: TextStyles.caption.copyWith(color: Palette.deep, fontSize: 13.5),
                                  ),
                                  const SizedBox(width: 10),
                                  VoiceBars(clock: clock),
                                ],
                              )
                            : Text(
                                'Ask me anything',
                                key: const ValueKey('hint'),
                                style: TextStyles.caption.copyWith(color: const Color(0xFF9A9FA2), fontSize: 13.5),
                              ),
                      ),
                    ),
                ],
              ),
            ),
            Pressable(
              onTap: () => _send(),
              scale: 0.86,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF111313),
                  shape: BoxShape.circle,
                  boxShadow: hasText
                      ? const [BoxShadow(color: Color(0x40000000), blurRadius: 14, offset: Offset(0, 6))]
                      : null,
                ),
                child: ClipOval(
                  child: AnimatedBuilder(
                    animation: _fly,
                    builder: (context, child) {
                      final t = _fly.value;
                      final out = Curves.easeInCubic.transform(window(t, 0, 0.45));
                      final back = Curves.easeOutBack.transform(window(t, 0.45, 1));
                      final offset = t < 0.45 ? Offset(28 * out, -28 * out) : Offset(-28 * (1 - back), 28 * (1 - back));
                      return Transform.translate(offset: t == 0 ? Offset.zero : offset, child: child);
                    },
                    child: const Center(child: GlyphIcon(Glyph.send, size: 20, color: Colors.white, stroke: 1.5)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }

  Widget _suggestions() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: AssistantBrain.suggestions.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        return Entrance(
          animation: stage(_intro, 0.64 + i * 0.06, 0.95 + i * 0.02, curve: Curves.easeOutBack),
          offset: const Offset(40, 0),
          child: Pressable(
            onTap: () => _send(AssistantBrain.suggestions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFFF4F6F8), borderRadius: BorderRadius.circular(19)),
              child: Text(
                AssistantBrain.suggestions[i],
                style: TextStyles.label.copyWith(fontSize: 13.5, color: const Color(0xFF2B2E30)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 10 + 58;
    return Stack(
      children: [
        Positioned(
          top: top,
          right: 16,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final t = animation.status == AnimationStatus.reverse
                  ? Curves.easeInCubic.transform(animation.value)
                  : const ElasticOutCurve(0.85).transform(animation.value);
              return Opacity(
                opacity: animation.value.clamp(0.0, 1.0),
                child: Transform.scale(scale: lerp(0.4, 1, t), alignment: Alignment.topRight, child: child),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 210,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Palette.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 30, offset: Offset(0, 14))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _item(context, Glyph.sparkle, 'New chat', 'new'),
                    _item(context, Glyph.clock, 'Daily summary', 'summary'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _item(BuildContext context, Glyph glyph, String label, String value) {
    return Pressable(
      onTap: () => Navigator.of(context).pop(value),
      scale: 0.97,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(color: Palette.mist, shape: BoxShape.circle),
              child: Center(child: GlyphIcon(glyph, size: 16, color: Palette.deep, stroke: 1.6)),
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyles.label.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
