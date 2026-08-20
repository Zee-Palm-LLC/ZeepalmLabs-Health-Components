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
        leadingWidth: 56.w,
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
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            Text(
              unreadTotal > 0 ? '$unreadTotal unread chats' : 'All caught up',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.body,
              ),
            ),
          ],
        ),
        actions: [
          CustomIconBtn(icon: Iconsax.edit_2, onTap: () {}),
          SizedBox(width: 16.w),
        ],
      ),
      body: Stack(
        children: [
          const CustomShade(height: 120),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                    child: CustomSearchField(
                      hintText: 'Search conversations...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 86.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      primary: false,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _chats.where((c) => c.isOnline).length + 1,
                      separatorBuilder: (context, index) => SizedBox(width: 14.w),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const _OnlineChip(
                            label: 'New Chat',
                            isAdd: true,
                          );
                        }
                        final online = _chats.where((c) => c.isOnline).toList();
                        final chat = online[index - 1];
                        return _OnlineChip(
                          label: chat.name.split(' ').last,
                          imageUrl: chat.imageUrl,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (chats.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 80.h),
                      child: _EmptyState(
                        icon: Iconsax.message,
                        title: 'No chats found',
                        subtitle: 'Try a different name or specialty',
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                      child: Column(
                        children: [
                          for (var i = 0; i < chats.length; i++) ...[
                            if (i > 0) SizedBox(height: 12.h),
                            _MessageCard(chat: chats[i]),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
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
  });

  final String label;
  final String? imageUrl;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.w,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAdd ? AppColors.primaryLight : AppColors.border,
                  border: Border.all(
                    color: isAdd ? AppColors.primary.withValues(alpha: 0.25) : Colors.white,
                    width: 2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: isAdd
                    ? Icon(Iconsax.add, color: AppColors.primary, size: 22.sp)
                    : AppImage(path: imageUrl!, fit: BoxFit.cover),
              ),
              if (!isAdd)
                Positioned(
                  right: 2.w,
                  bottom: 2.h,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
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
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.chat});

  final ChatPreview chat;

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unread > 0;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: hasUnread
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.border.withValues(alpha: 0.7),
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: hasUnread ? 0.08 : 0.04),
            blurRadius: 14,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: SizedBox(
                  width: 54.w,
                  height: 54.w,
                  child: AppImage(path: chat.imageUrl, fit: BoxFit.cover),
                ),
              ),
              if (chat.isOnline)
                Positioned(
                  right: -2.w,
                  bottom: -2.h,
                  child: Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
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
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      chat.time,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: hasUnread ? AppColors.primary : AppColors.muted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  chat.specialty,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.body,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat.isTyping ? 'Typing...' : chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          color: chat.isTyping
                              ? AppColors.primary
                              : hasUnread
                                  ? AppColors.ink
                                  : AppColors.body,
                          fontStyle: chat.isTyping ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ),
                    if (hasUnread) ...[
                      SizedBox(width: 8.w),
                      Container(
                        constraints: BoxConstraints(minWidth: 20.w),
                        height: 20.w,
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${chat.unread}',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: AppColors.body,
            ),
          ),
        ],
      ),
    );
  }
}
