import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../core/theme.dart';
import '../data/conversation.dart';
import '../features/chat/chat_layout.dart';
import 'frame.dart';
import 'stage.dart';

class Director {
  Director(this.stage) {
    _voiceTicker = stage.createTicker(_listen);
  }

  final StageState stage;
  final conversation = Conversation();
  final level = ValueNotifier<double>(0);
  final heard = ValueNotifier<double>(0);
  final confirmed = ValueNotifier<double>(0);
  final paused = ValueNotifier<bool>(false);
  final input = TextEditingController();
  final chatScroll = ScrollController();

  static final List<String> voiceLines = [
    'Deploy an autonomous',
    'AI agent to monitor liquidity',
    'pools. Make it a tactical',
    'trading bot.',
  ];
  static final List<String> voiceWords = [for (final line in voiceLines) ...line.split(' ')];

  late final Ticker _voiceTicker;
  final List<Timer> _timers = [];
  final List<AnimationController> _reveals = [];
  Duration _lastTick = Duration.zero;
  double _clock = 0;
  double _speech = 0;
  double _doneFor = 0;
  int _turn = 0;
  bool _autoplayed = false;
  bool _userTyped = false;

  void _confirm() {
    final total = voiceWords.length.toDouble();
    final h = heard.value;
    confirmed.value = h >= total ? math.min(total, _doneFor * 9 + total - 8) : math.max(0, h - 8);
  }

  void dispose() {
    _cancel();
    _voiceTicker.dispose();
    level.dispose();
    heard.dispose();
    confirmed.dispose();
    paused.dispose();
    input.dispose();
    chatScroll.dispose();
    conversation.dispose();
  }

  void _cancel() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    for (final c in _reveals) {
      c.dispose();
    }
    _reveals.clear();
  }

  void _after(int ms, VoidCallback run) {
    _timers.add(Timer(Duration(milliseconds: ms), run));
  }

  void leaving(Scene from, Scene to) {
    if (from == Scene.voice) {
      _voiceTicker.stop();
    }
    if (from == Scene.chat) {
      _cancel();
      conversation.setWorking(false);
    }
    if (to == Scene.voice) {
      heard.value = 0;
      confirmed.value = 0;
      paused.value = false;
      _speech = 0;
      _doneFor = 0;
      _clock = 0;
      level.value = 0.9;
      _lastTick = Duration.zero;
      if (!_voiceTicker.isActive) _voiceTicker.start();
    }
    if (to == Scene.home) {
      input.clear();
    }
  }

  void arrived(Scene scene) {
    if (scene == Scene.chat) {
      final pending = conversation.messages.where((m) => m.thinking).toList();
      for (final message in pending) {
        _reply(message, onDone: _afterReply);
      }
    }
  }

  void _listen(Duration elapsed) {
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;
    final arrivedAtVoice = stage.scene == Scene.voice && stage.settled;
    final speaking = arrivedAtVoice && !paused.value && heard.value < voiceWords.length;
    if (arrivedAtVoice && !paused.value) {
      _clock += dt;
      if (_clock > 0.45 && heard.value < voiceWords.length) {
        final index = heard.value.floor();
        final word = voiceWords[index.clamp(0, voiceWords.length - 1)];
        final pace = word.endsWith('.') ? 1.4 : 3.9 + (index % 3) * 0.6;
        heard.value = math.min(voiceWords.length.toDouble(), heard.value + dt * pace);
      }
      if (heard.value >= voiceWords.length) {
        _doneFor += dt;
        if (_doneFor > 2.1) {
          _voiceTicker.stop();
          sendVoice();
          return;
        }
      }
      _confirm();
    }
    _speech += dt;
    final wobble = 0.5 + 0.28 * math.sin(_speech * 11.3) + 0.22 * math.sin(_speech * 17.9 + 1.3);
    final target = speaking ? 0.38 + 0.5 * wobble : (paused.value ? 0.04 : 0.14);
    level.value += (target - level.value) * math.min(1, dt * 7);
  }

  Rect transcriptRect(Frame frame) {
    return Rect.fromLTWH(frame.midX - 150, frame.transcriptTop, 300, 29.0 * voiceLines.length);
  }

  void sendVoice() {
    if (stage.scene != Scene.voice) return;
    final frame = Frame.of(stage.context);
    _cancel();
    conversation.clear();
    final mine = Message(Author.me, Script.voiceBubble);
    conversation.add(mine);
    conversation.add(Message(Author.aira, Script.firstReply, reveal: 0, thinking: true));
    _autoplayed = false;
    _userTyped = false;
    _turn = 0;
    stage.go(
      Scene.chat,
      flight: Flight(
        source: transcriptRect(frame),
        sourceText: voiceLines.join('\n'),
        sourceStyle: transcriptStyle,
        message: mine,
      ),
    );
  }

  void sendFromHome(String prompt, {Rect? source, String? label, TextStyle? style, Color fill = const Color(0x00000000)}) {
    _cancel();
    conversation.clear();
    final mine = Message(Author.me, prompt);
    conversation.add(mine);
    conversation.add(Message(Author.aira, Script.replyFor(prompt, _turn), reveal: 0, thinking: true));
    _autoplayed = true;
    _turn = 1;
    stage.go(
      Scene.chat,
      flight: Flight(source: source, sourceText: label ?? prompt, sourceStyle: style, sourceFill: fill, message: mine),
    );
  }

  void openHistory() {
    _cancel();
    conversation.clear();
    conversation.add(Message(Author.me, Script.voiceBubble));
    conversation.add(Message(Author.aira, Script.firstReply));
    conversation.add(Message(Author.me, Script.followUp));
    conversation.add(Message(Author.aira, Script.followUpReply));
    conversation.working = true;
    _autoplayed = true;
    stage.go(Scene.chat);
  }

  void userTyped() {
    _userTyped = true;
  }

  void send(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;
    input.clear();
    conversation.setWorking(false);
    conversation.add(Message(Author.me, text));
    final reply = text == Script.followUp ? Script.followUpReply : Script.replyFor(text, _turn++);
    final thinking = Message(Author.aira, reply, reveal: 0, thinking: true);
    _after(380, () {
      conversation.add(thinking);
      _reply(thinking, onDone: _afterReply);
    });
  }

  void _reply(Message message, {VoidCallback? onDone}) {
    _after(1150, () {
      message.thinking = false;
      conversation.touch();
      final words = message.text.split(' ').length;
      final controller = AnimationController(
        vsync: stage,
        duration: Duration(milliseconds: 260 + words * 62),
      );
      _reveals.add(controller);
      controller.addListener(() => message.reveal.value = controller.value);
      _after(160, () {
        controller.forward().whenComplete(() {
          message.reveal.value = 1;
          onDone?.call();
        });
      });
    });
  }

  void _afterReply() {
    final last = conversation.messages.last;
    if (last.text == Script.followUpReply) {
      conversation.setWorking(true);
      return;
    }
    if (_autoplayed || _userTyped) return;
    _autoplayed = true;
    _after(1300, _typeFollowUp);
  }

  void _typeFollowUp() {
    if (_userTyped || input.text.isNotEmpty) return;
    const text = Script.followUp;
    for (var i = 1; i <= text.length; i++) {
      _after(i * 42, () {
        if (_userTyped) return;
        input.value = TextEditingValue(text: text.substring(0, i), selection: TextSelection.collapsed(offset: i));
      });
    }
    _after(text.length * 42 + 520, () {
      if (_userTyped) return;
      send(input.text);
    });
  }

  Offset orbLanding(Frame frame) {
    final layout = ChatLayout(frame.width, conversation.messages, working: false);
    for (final slot in layout.slots) {
      if (slot.avatar != null) {
        return slot.avatar!.center + Offset(0, frame.chatListTop);
      }
    }
    return Offset(ChatLayout.avatarLeft + 12, frame.chatListTop + 60);
  }

  Rect bubbleLanding(Frame frame, Message message) {
    final layout = ChatLayout(frame.width, conversation.messages, working: false);
    for (final slot in layout.slots) {
      if (slot.message == message) return slot.bubble.shift(Offset(0, frame.chatListTop));
    }
    return ChatLayout.predictMine(frame.width, message.text).shift(Offset(0, frame.chatListTop));
  }
}
