import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/components/custom_icon_btn.dart';
import '../../features/home/components/custom_search_field.dart';
import '../../features/home/components/custom_shade.dart';
import 'chat_screen.dart';
import 'components/message_motion.dart';

class ChatPreview {
  const ChatPreview({
    required this.name,
    required this.specialty,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    this.unread = 0,
    this.isOnline = false,
    this.isTyping = false,
  });

  final String name;
  final String specialty;
  final String lastMessage;
  final String time;
  final String imageUrl;
  final int unread;
  final bool isOnline;
  final bool isTyping;
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const _chats = [
    ChatPreview(
      name: 'Dr. Esther Howard',
      specialty: 'Heart specialist',
      lastMessage: 'Your lab reports look good. See you on Sunday.',
      time: '2 min',
      unread: 2,
      isOnline: true,
      imageUrl: AppImages.esther,
    ),
    ChatPreview(
      name: 'Dr. Jacob Jones',
      specialty: 'Neurologist',
      lastMessage: 'Please take the prescribed medicine after meals.',
      time: '18 min',
      unread: 1,
      isOnline: true,
      isTyping: true,
      imageUrl: AppImages.jacob,
    ),
    ChatPreview(
      name: 'Dr. Bessie Cooper',
      specialty: 'Ophthalmologist',
      lastMessage: 'Thanks for confirming the appointment.',
      time: '1 hr',
      imageUrl: AppImages.bessie,
    ),
    ChatPreview(
      name: 'Dr. Darlene Robertson',
      specialty: 'Dermatologist',
      lastMessage: 'Apply the cream twice daily for a week.',
      time: 'Yesterday',
      imageUrl: AppImages.darlene,
    ),
    ChatPreview(
      name: 'Dr. Brooklyn Simmons',
      specialty: 'Cardiologist',
      lastMessage: 'Looking forward to our video consultation.',
      time: 'Mon',
      imageUrl: AppImages.brooklyn,
    ),
    ChatPreview(
      name: 'Support Docora',
      specialty: 'Care team',
      lastMessage: 'How was your recent appointment experience?',
      time: 'Sun',
      imageUrl: AppImages.supportAvatar,
    ),
  ];

  String _query = '';

  void _openChat(ChatPreview chat) {
    Get.to(
      () => ChatScreen(chat: chat),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 280),
      curve: const Cubic(0.16, 1, 0.3, 1),
    );
  }

  List<ChatPreview> get _filtered {
    if (_query.trim().isEmpty) return _chats;
    final q = _query.toLowerCase();
    return _chats
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.specialty.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filtered;
    final unreadTotal = _chats.fold<int>(0, (sum, c) => sum + c.unread);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarHeight: 56.h,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages',
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.2,
              ),
            ),
            Text(
              unreadTotal > 0 ? '$unreadTotal unread' : 'All caught up',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.body,
                height: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          CustomIconBtn(icon: Iconsax.edit_2, onTap: () {}),
          SizedBox(width: 14.w),
        ],
      ),
      body: Stack(
        children: [
          const CustomShade(height: 96),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 10.h),
                  child: FadeScaleIn(
                    child: CustomSearchField(
                      hintText: 'Search conversations...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                ),
                FadeScaleIn(
                  delay: const Duration(milliseconds: 60),
                  child: SizedBox(
                    height: 74.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _chats.where((c) => c.isOnline).length + 1,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const _OnlineChip(label: 'New', isAdd: true);
                        }
                        final online = _chats.where((c) => c.isOnline).toList();
                        final chat = online[index - 1];
                        return _OnlineChip(
                          label: chat.name.split(' ').last,
                          imageUrl: chat.imageUrl,
                          onTap: () => _openChat(chat),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: chats.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
                          physics: const BouncingScrollPhysics(),
                          itemCount: chats.length,
                          itemBuilder: (context, i) {
                            return FadeScaleIn(
                              delay: Duration(milliseconds: 50 + i * 45),
                              child: _MessageTile(
                                chat: chats[i],
                                showDivider: i != chats.length - 1,
                                onTap: () => _openChat(chats[i]),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineChip extends StatelessWidget {
  const _OnlineChip({
    required this.label,
    this.imageUrl,
    this.isAdd = false,
    this.onTap,
  });

  final String label;
  final String? imageUrl;
  final bool isAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: SizedBox(
        width: 58.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAdd ? AppColors.primaryLight : AppColors.border,
                    border: Border.all(color: Colors.white, width: 1.5.w),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isAdd
                      ? Icon(Iconsax.add, color: AppColors.primary, size: 18.sp)
                      : AppImage(path: imageUrl!, fit: BoxFit.cover),
                ),
                if (!isAdd)
                  Positioned(right: 0, bottom: 0, child: PulseDot(size: 10)),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.chat,
    required this.onTap,
    this.showDivider = true,
  });

  final ChatPreview chat;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unread > 0;

    return PressScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.8),
                    width: 0.6,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: SizedBox(
                    width: 48.w,
                    height: 48.w,
                    child: AppImage(path: chat.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: -1.w,
                    bottom: -1.h,
                    child: const PulseDot(size: 11),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      Text(
                        chat.time,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: hasUnread
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: chat.isTyping
                            ? Row(
                                children: [
                                  const TypingDots(),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Typing',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: hasUnread
                                      ? AppColors.ink
                                      : AppColors.body,
                                ),
                              ),
                      ),
                      if (hasUnread) ...[
                        SizedBox(width: 8.w),
                        Container(
                          constraints: BoxConstraints(minWidth: 18.w),
                          height: 18.w,
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${chat.unread}',
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.message, color: AppColors.muted, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            'No chats found',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
