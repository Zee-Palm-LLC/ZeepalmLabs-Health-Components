import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../features/home/components/custom_icon_btn.dart';
import '../../features/home/components/custom_shade.dart';

enum NotificationType { appointment, message, reminder, promo, system }

enum _NotifMenuAction { markRead, markUnread, delete }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final NotificationType type;
  final bool isRead;
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _today;
  late List<AppNotification> _earlier;

  @override
  void initState() {
    super.initState();
    _today = [
      const AppNotification(
        id: 't1',
        title: 'Appointment Reminder',
        body: 'Video call with Dr. Esther Howard starts in 30 minutes.',
        time: 'Just now',
        type: NotificationType.reminder,
      ),
      const AppNotification(
        id: 't2',
        title: 'New Message',
        body: 'Dr. Jacob Jones sent you a follow-up note about your report.',
        time: '12 min ago',
        type: NotificationType.message,
      ),
      const AppNotification(
        id: 't3',
        title: 'Booking Confirmed',
        body: 'Your appointment with Dr. Bessie Cooper is confirmed for Sunday.',
        time: '1 hr ago',
        type: NotificationType.appointment,
      ),
    ];
    _earlier = [
      const AppNotification(
        id: 'e1',
        title: 'Payment Successful',
        body: 'You paid \$120.00 for consultation with Dr. Darlene Robertson.',
        time: 'Yesterday',
        type: NotificationType.system,
        isRead: true,
      ),
      const AppNotification(
        id: 'e2',
        title: 'Health Tip',
        body: 'Drink enough water today and take a short walk after meals.',
        time: '2 days ago',
        type: NotificationType.promo,
        isRead: true,
      ),
      const AppNotification(
        id: 'e3',
        title: 'Reschedule Request',
        body: 'Dr. Brooklyn Simmons suggested a new slot for Monday 10:00 AM.',
        time: '3 days ago',
        type: NotificationType.appointment,
        isRead: true,
      ),
      const AppNotification(
        id: 'e4',
        title: 'Welcome to Docora',
        body: 'Book trusted doctors nearby and manage appointments easily.',
        time: '1 week ago',
        type: NotificationType.system,
        isRead: true,
      ),
    ];
  }

  void _markAllRead() {
    setState(() {
      _today = _today.map(_asRead).toList();
      _earlier = _earlier.map(_asRead).toList();
    });
  }

  AppNotification _asRead(AppNotification n) => AppNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        time: n.time,
        type: n.type,
        isRead: true,
      );

  AppNotification _asUnread(AppNotification n) => AppNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        time: n.time,
        type: n.type,
      );

  @override
  Widget build(BuildContext context) {
    final unreadCount = [..._today, ..._earlier].where((n) => !n.isRead).length;
    final isEmpty = _today.isEmpty && _earlier.isEmpty;

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
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: CustomIconBtn(
                icon: Iconsax.tick_circle,
                onTap: _markAllRead,
              ),
            ),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CustomIconBtn(icon: Iconsax.setting_2, onTap: () {}),
          ),
        ],
      ),
      body: Stack(
        children: [
          const CustomShade(height: 100),
          SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                    child: Row(
                      children: [
                        Text(
                          unreadCount > 0
                              ? '$unreadCount new updates'
                              : 'You\'re all caught up',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.body,
                          ),
                        ),
                        const Spacer(),
                        if (unreadCount > 0)
                          GestureDetector(
                            onTap: _markAllRead,
                            child: Text(
                              'Mark all read',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else ...[
                  if (_today.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
                        child: _SectionLabel(label: 'Today'),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList.separated(
                        itemCount: _today.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: AppColors.border,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final n = _today[index];
                          return _NotificationTile(
                            notification: n,
                            onTap: () => _markOneRead(n, isToday: true),
                            onLongPress: (pos) => _openContextMenu(
                              n,
                              isToday: true,
                              position: pos,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (_earlier.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
                        child: _SectionLabel(label: 'Earlier'),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList.separated(
                        itemCount: _earlier.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: AppColors.border,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final n = _earlier[index];
                          return _NotificationTile(
                            notification: n,
                            onTap: () => _markOneRead(n, isToday: false),
                            onLongPress: (pos) => _openContextMenu(
                              n,
                              isToday: false,
                              position: pos,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _markOneRead(AppNotification n, {required bool isToday}) {
    if (n.isRead) return;
    _replaceOne(_asRead(n), isToday: isToday);
  }

  void _markOneUnread(AppNotification n, {required bool isToday}) {
    if (!n.isRead) return;
    _replaceOne(_asUnread(n), isToday: isToday);
  }

  void _replaceOne(AppNotification updated, {required bool isToday}) {
    setState(() {
      final list = isToday ? _today : _earlier;
      final i = list.indexWhere((item) => item.id == updated.id);
      if (i >= 0) list[i] = updated;
    });
  }

  void _deleteOne(AppNotification n, {required bool isToday}) {
    setState(() {
      if (isToday) {
        _today.removeWhere((item) => item.id == n.id);
      } else {
        _earlier.removeWhere((item) => item.id == n.id);
      }
    });
  }

  Future<void> _openContextMenu(
    AppNotification n, {
    required bool isToday,
    required Offset position,
  }) async {
    HapticFeedback.mediumImpact();
    final action = await showGeneralDialog<_NotifMenuAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss notification menu',
      barrierColor: Colors.black.withValues(alpha: 0.22),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _NotificationContextMenu(
          position: position,
          isRead: n.isRead,
        );
      },
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _NotifMenuAction.markRead:
        _markOneRead(n, isToday: isToday);
      case _NotifMenuAction.markUnread:
        _markOneUnread(n, isToday: isToday);
      case _NotifMenuAction.delete:
        _deleteOne(n, isToday: isToday);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onLongPress,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final ValueChanged<Offset> onLongPress;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(notification.type);
    final unread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(style.icon, color: style.iconColor, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                notification.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            if (unread) ...[
                              SizedBox(width: 6.w),
                              Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        notification.time,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.body,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotifStyle _styleFor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const _NotifStyle(
          icon: Iconsax.calendar,
          background: AppColors.primaryLight,
          iconColor: AppColors.primary,
        );
      case NotificationType.message:
        return const _NotifStyle(
          icon: Iconsax.message,
          background: AppColors.neuro,
          iconColor: AppColors.neuroIcon,
        );
      case NotificationType.reminder:
        return const _NotifStyle(
          icon: Iconsax.clock,
          background: AppColors.derma,
          iconColor: AppColors.dermaIcon,
        );
      case NotificationType.promo:
        return const _NotifStyle(
          icon: Iconsax.heart,
          background: AppColors.cardio,
          iconColor: AppColors.cardioIcon,
        );
      case NotificationType.system:
        return const _NotifStyle(
          icon: Iconsax.tick_circle,
          background: Color(0xFFE8FFF3),
          iconColor: AppColors.success,
        );
    }
  }
}

class _NotificationContextMenu extends StatelessWidget {
  const _NotificationContextMenu({
    required this.position,
    required this.isRead,
  });

  final Offset position;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final menuWidth = 214.w;
    final menuHeight = 108.h;
    final gap = 10.h;

    var left = position.dx - (menuWidth / 2);
    var top = position.dy + gap;

    left = left.clamp(16.w, size.width - menuWidth - 16.w);
    if (top + menuHeight > size.height - padding.bottom - 16.h) {
      top = position.dy - menuHeight - gap;
    }
    top = top.clamp(padding.top + 8.h, size.height - menuHeight - padding.bottom - 8.h);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) {
                return Opacity(
                  opacity: t,
                  child: Transform.scale(
                    scale: 0.92 + (0.08 * t),
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: menuWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ContextMenuItem(
                      icon: isRead ? Iconsax.eye : Iconsax.tick_circle,
                      label: isRead ? 'Mark as unread' : 'Mark as read',
                      onTap: () => Navigator.of(context).pop(
                        isRead
                            ? _NotifMenuAction.markUnread
                            : _NotifMenuAction.markRead,
                      ),
                    ),
                    Divider(height: 1, color: AppColors.border.withValues(alpha: 0.9)),
                    _ContextMenuItem(
                      icon: Iconsax.trash,
                      label: 'Delete',
                      color: const Color(0xFFE11D48),
                      onTap: () => Navigator.of(context).pop(_NotifMenuAction.delete),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.ink;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: tint),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: tint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.notification,
                color: AppColors.primary,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'No notifications',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Check back later for new updates',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.body,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifStyle {
  const _NotifStyle({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
}
