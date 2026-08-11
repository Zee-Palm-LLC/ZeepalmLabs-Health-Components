import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ChatLauncher extends StatefulWidget {
  const ChatLauncher({super.key});

  @override
  State<ChatLauncher> createState() => _ChatLauncherState();
}

class _ChatLauncherState extends State<ChatLauncher>
    with SingleTickerProviderStateMixin {
  static const Color blue = Color(0xFF2563EB);
  static const Color lightBlue = Color(0xFF60A5FA);
  static const Color red = Color(0xFFFF5A63);
  static const Color muted = Color(0xFF64748B);
  static const Color panelBg = Color(0xFFF5F8FF);

  late final AnimationController _controller;
  late final Animation<double> _t;

  bool _active = false;
  final _messages = <_ChatMessage>[
    _ChatMessage(
      "Hello Dr. Smith! I'm your health assistant. How can I help today?",
      isUser: false,
    ),
    _ChatMessage(
      "Can you summarize patient Jackson Wang's vitals?",
      isUser: true,
    ),
    _ChatMessage(
      'His resting heart rate is 78 bpm and vitals look within normal range.',
      isUser: false,
    ),
  ];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _active = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _active = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggle() =>
      _controller.value == 1 ? _controller.reverse() : _controller.forward();

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, isUser: true));
      _messages.add(
        _ChatMessage(
          "Thanks for your message! I'll get back to you shortly.",
          isUser: false,
        ),
      );
      _inputController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetW = (constraints.maxWidth * 0.86).clamp(280.0, 420.0);
        final targetH = constraints.maxHeight * 0.72;
        const minW = 52.0;
        const minH = 52.0;
        final pad = 12.r;

        return Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final a = _t.value;
                return Positioned.fill(
                  child: IgnorePointer(
                    ignoring: a == 0,
                    child: GestureDetector(
                      onTap: _active ? _toggle : null,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5 * a),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: pad,
              bottom: pad,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final a = _t.value;
                  final w = ui.lerpDouble(minW, targetW, a);
                  final h = ui.lerpDouble(minH, targetH, a);
                  final radius = ui.lerpDouble(26, 20, a) ?? 0;
                  final bg = Color.lerp(blue, panelBg, a);

                  return SizedBox(
                    width: w,
                    height: h,
                    child: Material(
                      elevation: 16,
                      shadowColor: Colors.black.withValues(alpha: 0.5),
                      color: bg,
                      borderRadius: BorderRadius.circular(radius),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: _active,
                              child: GestureDetector(
                                onTap: _toggle,
                                behavior: HitTestBehavior.opaque,
                                child: Opacity(
                                  opacity: 1 - a,
                                  child: Center(
                                    child: Transform.scale(
                                      scale: 1 - a * 0.4,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Iconsax.message,
                                            color: Colors.white,
                                            size: 24.w,
                                          ),
                                          Positioned(
                                            top: -2,
                                            right: -6,
                                            child: Container(
                                              width: 8.w,
                                              height: 8.w,
                                              decoration: const BoxDecoration(
                                                color: red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              ignoring: !_active,
                              child: ClipRect(
                                child: SizedBox(
                                  width: targetW,
                                  height: targetH,
                                  child: Opacity(
                                    opacity: a,
                                    child: _ChatPanel(
                                      messages: _messages,
                                      controller: _inputController,
                                      scrollController: _scrollController,
                                      onSend: _send,
                                      onClose: _toggle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.onSend,
    required this.onClose,
  });

  final List<_ChatMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSend;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChatHeader(onClose: onClose),
        Expanded(
          child: Container(
            color: Colors.black.withValues(alpha: 0.03),
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(12.w),
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  _ChatBubble(message: messages[index]),
            ),
          ),
        ),
        _ChatInput(controller: controller, onSend: onSend),
      ],
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_ChatLauncherState.blue, _ChatLauncherState.lightBlue],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
              ),
            ),
            child: const Icon(Iconsax.health, color: Colors.white, size: 18),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Assistant',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2BD67B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Online • replies instantly',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Iconsax.arrow_down_1,
              size: 18.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.58;
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        constraints: BoxConstraints(maxWidth: maxW),
        decoration: BoxDecoration(
          color: isUser
              ? _ChatLauncherState.blue
              : const Color(0xFFE9EFF7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 3),
            bottomRight: Radius.circular(isUser ? 3 : 14),
          ),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: isUser ? Colors.white : const Color(0xFF0F172A),
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      color: _ChatLauncherState.panelBg,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: const Color(0xFF0F172A),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Ask about your health...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: _ChatLauncherState.muted,
                ),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFE9EFF7),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 11.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: _ChatLauncherState.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.send_1, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage(this.text, {required this.isUser});

  final String text;
  final bool isUser;
}
