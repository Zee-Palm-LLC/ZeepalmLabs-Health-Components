import 'dart:async';

import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceDetailFeed extends StatefulWidget {
  const VoiceDetailFeed({
    super.key,
    this.listening = false,
  });

  final bool listening;

  @override
  State<VoiceDetailFeed> createState() => _VoiceDetailFeedState();
}

class _VoiceDetailFeedState extends State<VoiceDetailFeed> {
  static const _script = [
    'Please describe your symptoms using your voice.',
    'Mention when they started and how strong they feel.',
    'Our assistant uses the information you share to guide next steps.',
    'Include details like fever, pain, cough, or fatigue if present.',
    'Speak naturally — you can pause and continue anytime.',
    'We will suggest safe care options after understanding your symptoms.',
  ];

  final ScrollController _scrollController = ScrollController();
  final List<String> _completedLines = [];

  Timer? _typeTimer;
  int _lineIndex = 0;
  int _charIndex = 0;
  String _activeLine = '';

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant VoiceDetailFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listening != widget.listening && widget.listening) {
      _restartFromBeginning();
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _restartFromBeginning() {
    _typeTimer?.cancel();
    setState(() {
      _completedLines.clear();
      _lineIndex = 0;
      _charIndex = 0;
      _activeLine = '';
    });
    _startTyping(fast: true);
  }

  void _startTyping({bool fast = false}) {
    final step = fast ? 18 : widget.listening ? 24 : 34;

    _typeTimer = Timer.periodic(Duration(milliseconds: step), (_) {
      if (!mounted) return;

      if (_lineIndex >= _script.length) {
        _typeTimer?.cancel();
        Future<void>.delayed(const Duration(milliseconds: 1800), () {
          if (!mounted) return;
          _restartFromBeginning();
        });
        return;
      }

      final line = _script[_lineIndex];
      if (_charIndex < line.length) {
        setState(() {
          _activeLine = line.substring(0, _charIndex + 1);
          _charIndex++;
        });
        return;
      }

      setState(() {
        _completedLines.add(line);
        _activeLine = '';
        _lineIndex++;
        _charIndex = 0;
      });
      _scrollToEnd();
    });
  }

  Future<void> _scrollToEnd() async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 420),
      curve: const Cubic(0.16, 1, 0.3, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.12, 0.82, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        children: [
          ..._completedLines.map(_buildLine),
          if (_activeLine.isNotEmpty) _buildLine(_activeLine, typing: true),
        ],
      ),
    );
  }

  Widget _buildLine(String text, {bool typing = false}) {
    final spans = _richSpans(text);

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: AnimatedSlide(
        offset: typing ? const Offset(0, 0.08) : Offset.zero,
        duration: const Duration(milliseconds: 320),
        curve: const Cubic(0.16, 1, 0.3, 1),
        child: AnimatedOpacity(
          opacity: typing ? 0.92 : 1,
          duration: const Duration(milliseconds: 240),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: PrimaryBgColors.subtitle,
                height: 1.55,
                letterSpacing: -0.1,
              ),
              children: [
                ...spans,
                if (typing)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _TypingCursor(listening: widget.listening),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _richSpans(String text) {
    const highlight = 'information';
    final index = text.indexOf(highlight);
    if (index == -1) {
      return [TextSpan(text: text)];
    }

    return [
      if (index > 0) TextSpan(text: text.substring(0, index)),
      TextSpan(
        text: highlight,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: PrimaryBgColors.title,
          height: 1.55,
        ),
      ),
      if (index + highlight.length < text.length)
        TextSpan(text: text.substring(index + highlight.length)),
    ];
  }
}

class _TypingCursor extends StatefulWidget {
  const _TypingCursor({required this.listening});

  final bool listening;

  @override
  State<_TypingCursor> createState() => _TypingCursorState();
}

class _TypingCursorState extends State<_TypingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2.w,
        height: 14.h,
        margin: EdgeInsets.only(left: 2.w),
        decoration: BoxDecoration(
          color: widget.listening
              ? const Color(0xFF7B5FD4)
              : PrimaryBgColors.title,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
