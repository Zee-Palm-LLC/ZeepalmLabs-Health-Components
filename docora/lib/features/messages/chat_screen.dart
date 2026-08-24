import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/components/custom_icon_btn.dart';
import '../../features/home/components/custom_shade.dart';
import 'components/message_motion.dart';
import 'messages_screen.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isMine,
    required this.time,
  });

  final String text;
  final bool isMine;
  final String time;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});

  final ChatPreview chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focus = FocusNode();
  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<ChatMessage>.from(_seedMessages(widget.chat.name));
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isMine: true, time: 'Now'));
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 72,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarHeight: 58.h,
        leadingWidth: 52.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Center(
            child: CustomIconBtn(
              icon: Iconsax.arrow_left_2,
              onTap: () => Get.back(),
            ),
          ),
        ),
        titleSpacing: 4,
        title: Row(
          children: [
            FadeScaleIn(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.r),
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: AppImage(path: chat.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: FadeScaleIn(
                delay: const Duration(milliseconds: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    chat.isTyping
                        ? Row(
                            children: [
                              const TypingDots(),
                              SizedBox(width: 6.w),
                              Text(
                                'Typing',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            chat.isOnline ? 'Online' : chat.specialty,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: chat.isOnline
                                  ? AppColors.success
                                  : AppColors.body,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          CustomIconBtn(icon: Iconsax.call, onTap: () {}),
          SizedBox(width: 6.w),
          CustomIconBtn(icon: Iconsax.video, onTap: () {}),
          SizedBox(width: 12.w),
        ],
      ),
      body: Stack(
        children: [
          const CustomShade(height: 80),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
                    itemCount: _messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Center(
                            child: Text(
                              'Today',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                      return _Bubble(
                        message: _messages[index - 1],
                        delay: Duration(milliseconds: 40 * (index - 1)),
                      );
                    },
                  ),
                ),
                _Composer(
                  controller: _controller,
                  focus: _focus,
                  onSend: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.delay});

  final ChatMessage message;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    return FadeScaleIn(
      delay: delay,
      duration: const Duration(milliseconds: 380),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 268.w),
          child: Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 6.h),
            decoration: BoxDecoration(
              color: mine ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(mine ? 16.r : 5.r),
                bottomRight: Radius.circular(mine ? 5.r : 16.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: mine ? 0.14 : 0.04,
                  ),
                  blurRadius: 8,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: mine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: mine ? Colors.white : AppColors.ink,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: mine
                            ? Colors.white.withValues(alpha: 0.72)
                            : AppColors.muted,
                      ),
                    ),
                    if (mine) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.done_all_rounded,
                        size: 12.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focus,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final focused = focus.hasFocus;
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
        ),
      ),
      child: Row(
        children: [
          CustomIconBtn(icon: Iconsax.add, onTap: () {}),
          SizedBox(width: 8.w),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: TextField(
                controller: controller,
                focusNode: focus,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.muted,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.r),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(
                        alpha: focused ? 0.35 : 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          PressScale(
            onTap: onSend,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.send_1, color: Colors.white, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }
}

List<ChatMessage> _seedMessages(String name) {
  switch (name) {
    case 'Dr. Esther Howard':
      return const [
        ChatMessage(
          text: 'Hi doctor, I uploaded my latest lab reports.',
          isMine: true,
          time: '10:12 AM',
        ),
        ChatMessage(
          text: 'Thank you. I reviewed them carefully.',
          isMine: false,
          time: '10:14 AM',
        ),
        ChatMessage(
          text: 'Your lab reports look good. See you on Sunday.',
          isMine: false,
          time: '10:15 AM',
        ),
      ];
    case 'Dr. Jacob Jones':
      return const [
        ChatMessage(
          text: 'Should I continue the same dosage this week?',
          isMine: true,
          time: '9:40 AM',
        ),
        ChatMessage(
          text: 'Yes. Please take the medicine after meals.',
          isMine: false,
          time: '9:42 AM',
        ),
      ];
    case 'Dr. Bessie Cooper':
      return const [
        ChatMessage(
          text: 'I will be there at 4:30 PM.',
          isMine: true,
          time: 'Yesterday',
        ),
        ChatMessage(
          text: 'Thanks for confirming the appointment.',
          isMine: false,
          time: 'Yesterday',
        ),
      ];
    default:
      return [
        ChatMessage(
          text: 'Hi, I had a question about my last visit.',
          isMine: true,
          time: '10:00 AM',
        ),
        ChatMessage(
          text: name.contains('Support')
              ? 'How was your recent appointment experience?'
              : 'Happy to help. Let me know how you are feeling.',
          isMine: false,
          time: '10:02 AM',
        ),
      ];
  }
}
