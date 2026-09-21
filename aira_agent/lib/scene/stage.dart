import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/motion.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/conversation.dart';
import '../features/chat/chat_layout.dart';
import '../features/chat/chat_view.dart';
import '../features/home/home_view.dart';
import '../features/voice/voice_view.dart';
import 'atmosphere.dart';
import 'director.dart';
import 'frame.dart';
import 'orb.dart';

enum Scene { home, voice, chat }

class Flight {
  const Flight({this.source, this.sourceText, this.sourceStyle, this.sourceFill = Colors.transparent, this.message});

  final Rect? source;
  final String? sourceText;
  final TextStyle? sourceStyle;
  final Color sourceFill;
  final Message? message;
}

class Stage extends StatefulWidget {
  const Stage({super.key, this.intro = true});

  final bool intro;

  @override
  State<Stage> createState() => StageState();
}

class StageState extends State<Stage> with TickerProviderStateMixin {
  Scene _scene = Scene.home;
  Scene? _from;
  bool _intro = true;
  Flight? _flight;
  late final AnimationController _flow;
  late final Director director;
  final GlobalKey _stageKey = GlobalKey();

  Scene get scene => _scene;
  bool get settled => !_flow.isAnimating;

  @override
  void initState() {
    super.initState();
    _intro = widget.intro;
    _flow = AnimationController(vsync: this, value: widget.intro ? 0 : 1)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _from = null;
            _intro = false;
            _flight = null;
          });
          director.arrived(_scene);
        }
      });
    director = Director(this);
    if (widget.intro) {
      _flow.duration = const Duration(milliseconds: 1900);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _flow.forward();
      });
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    director.dispose();
    super.dispose();
  }

  Rect localRect(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final stage = _stageKey.currentContext!.findRenderObject() as RenderBox;
    final topLeft = stage.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }

  void go(Scene to, {Flight? flight}) {
    if (to == _scene || _flow.isAnimating) return;
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.lightImpact();
    final from = _scene;
    final ms = switch ((from, to)) {
      (Scene.home, Scene.voice) => 1050,
      (Scene.voice, Scene.chat) => 1150,
      (Scene.home, Scene.chat) => 1000,
      (Scene.voice, Scene.home) => 900,
      _ => 850,
    };
    director.leaving(from, to);
    setState(() {
      _from = from;
      _scene = to;
      _intro = false;
      _flight = flight;
    });
    _flow.duration = Duration(milliseconds: ms);
    _flow.forward(from: 0);
  }

  Atmosphere _atmosphereOf(Scene scene) {
    return switch (scene) {
      Scene.home => Atmosphere.home,
      Scene.voice => Atmosphere.voice,
      Scene.chat => Atmosphere.chat,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        key: _stageKey,
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _flow,
              builder: (context, _) {
                final t = Curves.easeInOutCubic.transform(_flow.value);
                final start = _intro ? Atmosphere.dawn : _atmosphereOf(_from ?? _scene);
                return CustomPaint(
                  painter: AtmospherePainter(Atmosphere.lerp(start, _atmosphereOf(_scene), _from == null && !_intro ? 1 : t)),
                );
              },
            ),
          ),
          const Grain(),
          if (_isVisible(Scene.home))
            HomeView(
              key: const ValueKey('home'),
              presence: _flow,
              arriving: _scene == Scene.home,
              intro: _intro,
              partner: _scene == Scene.home ? _from : _scene,
              stage: this,
            ),
          if (_isVisible(Scene.voice))
            VoiceView(
              key: const ValueKey('voice'),
              presence: _flow,
              arriving: _scene == Scene.voice,
              partner: _scene == Scene.voice ? _from : _scene,
              stage: this,
            ),
          if (_isVisible(Scene.chat))
            ChatView(
              key: const ValueKey('chat'),
              presence: _flow,
              arriving: _scene == Scene.chat,
              partner: _scene == Scene.chat ? _from : _scene,
              stage: this,
              flying: _flight?.message,
            ),
          _pill(),
          if (_from != null) _flights(),
        ],
      ),
    );
  }

  bool _isVisible(Scene s) => s == _scene || s == _from;

  Widget _pill() {
    final frame = Frame.of(context);
    return AnimatedBuilder(
      animation: _flow,
      builder: (context, child) {
        final chatOrVoice = {Scene.voice, Scene.chat};
        double shown;
        if (_from == null) {
          shown = chatOrVoice.contains(_scene) ? 1 : 0;
        } else if (chatOrVoice.contains(_scene) && chatOrVoice.contains(_from)) {
          shown = 1;
        } else if (chatOrVoice.contains(_scene)) {
          shown = span(_flow.value, 0.35, 0.85, Curves.easeOutCubic);
        } else {
          shown = 1 - span(_flow.value, 0.0, 0.4, Curves.easeInCubic);
        }
        if (shown <= 0) return const SizedBox.shrink();
        return Positioned(
          top: frame.pillTop - 14 * (1 - shown),
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: shown,
              child: Transform.scale(scale: lerp(0.9, 1, shown), child: child),
            ),
          ),
        );
      },
      child: ClosePill(onTap: () => go(Scene.home)),
    );
  }

  Widget _flights() {
    final frame = Frame.of(context);
    final from = _from!;
    final to = _scene;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _flow,
        builder: (context, _) {
          final t = _flow.value;
          final children = <Widget>[];
          final orb = _orbFlight(frame, from, to, t);
          if (orb != null) children.add(orb);
          final bubble = _bubbleFlight(frame, from, to, t);
          if (bubble != null) children.add(bubble);
          final mic = _micFlight(frame, from, to, t);
          if (mic != null) children.add(mic);
          return Stack(children: children);
        },
      ),
    );
  }

  ({Offset centre, double size, double fill, double glyph}) _micAt(Frame frame, Scene scene) {
    return switch (scene) {
      Scene.home => (centre: frame.homeMic, size: 48.0, fill: 1.0, glyph: 26.0),
      Scene.voice => (centre: frame.voiceMic, size: 72.0, fill: 1.0, glyph: 37.0),
      Scene.chat => (centre: frame.chatMic, size: 26.0, fill: 0.0, glyph: 26.0),
    };
  }

  Widget? _micFlight(Frame frame, Scene from, Scene to, double t) {
    final a = _micAt(frame, from);
    final b = _micAt(frame, to);
    final move = switch ((from, to)) {
      (Scene.home, Scene.voice) => span(t, 0.05, 0.75, Curves.easeInOutCubic),
      (Scene.voice, Scene.chat) => span(t, 0.1, 0.7, Curves.easeInOutCubic),
      _ => span(t, 0.0, 0.8, Curves.easeInOutCubic),
    };
    final arc = math.sin(math.pi * move) * (from == Scene.home && to == Scene.voice ? -60 : -24);
    final centre = lerpOffset(a.centre, b.centre, move) + Offset(0, arc);
    final size = lerp(a.size, b.size, Curves.easeOutBack.transform(move).clamp(0.0, 1.2));
    final fill = lerp(a.fill, b.fill, move);
    final glyph = lerp(a.glyph, b.glyph, move);
    return Positioned(
      left: centre.dx - size / 2,
      top: centre.dy - size / 2,
      child: MicDisc(size: size, fill: fill, glyphSize: glyph, glow: math.sin(math.pi * move) * 0.8),
    );
  }

  ({Offset centre, double size, double opacity}) _orbAt(Frame frame, Scene scene) {
    return switch (scene) {
      Scene.home => (centre: frame.homeMic, size: 26.0, opacity: 0.0),
      Scene.voice => (centre: frame.orbCentre, size: frame.orbSize, opacity: 1.0),
      Scene.chat => (centre: director.orbLanding(frame), size: 24.0, opacity: 1.0),
    };
  }

  Widget? _orbFlight(Frame frame, Scene from, Scene to, double t) {
    if (from != Scene.voice && to != Scene.voice) return null;
    final a = _orbAt(frame, from);
    final b = _orbAt(frame, to);
    final double move;
    if (from == Scene.home) {
      move = span(t, 0.12, 0.95, Curves.easeOutCubic);
    } else if (to == Scene.home) {
      move = span(t, 0.0, 0.75, Curves.easeInCubic);
    } else {
      move = span(t, 0.12, 0.88, Curves.easeInOutCubic);
    }
    final grow = from == Scene.home ? Curves.easeOutBack.transform(span(t, 0.12, 0.95)) : move;
    final size = math.max(0.0, lerp(a.size, b.size, grow));
    final bend = to == Scene.chat ? Offset(-math.sin(math.pi * move) * 40, 0) : Offset.zero;
    final centre = lerpOffset(a.centre, b.centre, move) + bend;
    final opacity = lerp(a.opacity, b.opacity, span(move, 0, 0.35)).clamp(0.0, 1.0);
    if (opacity <= 0 || size < 1) return null;
    return Positioned(
      left: centre.dx - size / 2,
      top: centre.dy - size / 2,
      child: Opacity(
        opacity: opacity,
        child: Orb(size: size, level: director.level, seed: 0.3),
      ),
    );
  }

  Widget? _bubbleFlight(Frame frame, Scene from, Scene to, double t) {
    final flight = _flight;
    if (to != Scene.chat || flight == null || flight.message == null) return null;
    final message = flight.message!;
    final target = director.bubbleLanding(frame, message);
    final source = flight.source ?? target;
    final move = span(t, 0.08, 0.82, Curves.easeInOutCubic);
    final rect = Rect.lerp(source, target, move)!;
    final lift = math.sin(math.pi * move) * -18;
    final fill = span(t, 0.12, 0.6, Curves.easeOut);
    final oldText = 1 - span(t, 0.05, 0.42, Curves.easeIn);
    final newText = span(t, 0.32, 0.78, Curves.easeOut);
    final radius = lerp(from == Scene.home && flight.sourceFill.a > 0 ? 18 : 30, 16, move);
    final sourceStyle = flight.sourceStyle;
    return Positioned.fromRect(
      rect: rect.shift(Offset(0, lift)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BubbleFill(radius: radius, fill: fill, base: flight.sourceFill),
            ),
          ),
          if (oldText > 0 && flight.sourceText != null && sourceStyle != null)
            Positioned.fill(
              child: Opacity(
                opacity: oldText,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: source.width,
                    height: source.height,
                    child: _SourceText(flight: flight, style: sourceStyle),
                  ),
                ),
              ),
            ),
          if (newText > 0)
            Positioned(
              left: ChatLayout.minePadX,
              top: ChatLayout.minePadY,
              child: Opacity(
                opacity: newText,
                child: Transform.translate(
                  offset: Offset(0, 6 * (1 - newText)),
                  child: SizedBox(
                    width: target.width - ChatLayout.minePadX * 2 + 1,
                    child: Text(message.text, style: mineStyle),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SourceText extends StatelessWidget {
  const _SourceText({required this.flight, required this.style});

  final Flight flight;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      flight.sourceText!,
      style: style,
      textAlign: flight.sourceFill.a > 0 ? TextAlign.left : TextAlign.center,
    );
  }
}

class _BubbleFill extends CustomPainter {
  const _BubbleFill({required this.radius, required this.fill, required this.base});

  final double radius;
  final double fill;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    if (base.a > 0 && fill < 1) {
      canvas.drawRRect(rrect, Paint()..color = base.withValues(alpha: base.a * (1 - fill)));
    }
    if (fill > 0) {
      paintMineBubble(canvas, rrect, fill);
    }
  }

  @override
  bool shouldRepaint(_BubbleFill oldDelegate) => true;
}

void paintMineBubble(Canvas canvas, RRect rrect, double opacity) {
  final rect = rrect.outerRect;
  canvas.drawRRect(
    rrect.shift(const Offset(0, 6)),
    Paint()
      ..color = Tone.flame.withValues(alpha: 0.28 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
  );
  canvas.drawRRect(
    rrect,
    Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomLeft,
        [
          const Color(0xFFEE7A1A).withValues(alpha: opacity),
          const Color(0xFFD9570A).withValues(alpha: opacity),
          const Color(0xFFB53A03).withValues(alpha: opacity),
        ],
        const [0.0, 0.55, 1.0],
      ),
  );
  canvas.save();
  canvas.clipRRect(rrect);
  canvas.drawCircle(
    rect.topLeft + Offset(rect.width * 0.28, rect.height * 0.12),
    rect.height * 1.1,
    Paint()
      ..shader = ui.Gradient.radial(
        rect.topLeft + Offset(rect.width * 0.28, rect.height * 0.12),
        rect.height * 1.1,
        [const Color(0x40FFB36B).withValues(alpha: 0.25 * opacity), const Color(0x00FFB36B)],
      ),
  );
  canvas.restore();
  canvas.drawRRect(
    rrect.deflate(0.4),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomLeft,
        [const Color(0x55FFC89A).withValues(alpha: 0.33 * opacity), const Color(0x00FFC89A)],
      ),
  );
}
