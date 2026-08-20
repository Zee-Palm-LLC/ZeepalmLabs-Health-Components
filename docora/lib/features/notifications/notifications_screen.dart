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

class AppNotification {
  const AppNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

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
  int _filter = 0;

  late List<AppNotification> _today;
  late List<AppNotification> _earlier;

  static const _filters = [
    _FilterOption(label: 'All', icon: Iconsax.notification),
    _FilterOption(label: 'Unread', icon: Iconsax.message_notif),
    _FilterOption(label: 'Appointments', icon: Iconsax.calendar),
    _FilterOption(label: 'Messages', icon: Iconsax.message),
    _FilterOption(label: 'Reminders', icon: Iconsax.clock),
    _FilterOption(label: 'Tips', icon: Iconsax.heart),
  ];

  @override
  void initState() {
    super.initState();
    _today = [
      const AppNotification(
        title: 'Appointment Reminder',
        body: 'Video call with Dr. Esther Howard starts in 30 minutes.',
        time: 'Just now',
        type: NotificationType.reminder,
      ),
      const AppNotification(
        title: 'New Message',
        body: 'Dr. Jacob Jones sent you a follow-up note about your report.',
        time: '12 min ago',
        type: NotificationType.message,
      ),
      const AppNotification(
        title: 'Booking Confirmed',
        body: 'Your appointment with Dr. Bessie Cooper is confirmed for Sunday.',
        time: '1 hr ago',
        type: NotificationType.appointment,
      ),
    ];
    _earlier = [
      const AppNotification(
        title: 'Payment Successful',
        body: 'You paid \$120.00 for consultation with Dr. Darlene Robertson.',
        time: 'Yesterday',
        type: NotificationType.system,
        isRead: true,
      ),
      const AppNotification(
        title: 'Health Tip',
        body: 'Drink enough water today and take a short walk after meals.',
        time: '2 days ago',
        type: NotificationType.promo,
        isRead: true,
      ),
      const AppNotification(
        title: 'Reschedule Request',
        body: 'Dr. Brooklyn Simmons suggested a new slot for Monday 10:00 AM.',
        time: '3 days ago',
        type: NotificationType.appointment,
        isRead: true,
      ),
      const AppNotification(
        title: 'Welcome to Docora',
        body: 'Book trusted doctors nearby and manage appointments easily.',
        time: '1 week ago',
        type: NotificationType.system,
        isRead: true,
      ),
    ];
  }

  List<AppNotification> _applyFilter(List<AppNotification> list) {
    switch (_filter) {
      case 1:
        return list.where((n) => !n.isRead).toList();
      case 2:
        return list.where((n) => n.type == NotificationType.appointment).toList();
      case 3:
        return list.where((n) => n.type == NotificationType.message).toList();
      case 4:
        return list.where((n) => n.type == NotificationType.reminder).toList();
      case 5:
        return list.where((n) => n.type == NotificationType.promo).toList();
      default:
        return list;
    }
  }

  void _markAllRead() {
    setState(() {
      _today = _today.map(_asRead).toList();
      _earlier = _earlier.map(_asRead).toList();
    });
  }

  AppNotification _asRead(AppNotification n) => AppNotification(
        title: n.title,
        body: n.body,
        time: n.time,
        type: n.type,
        isRead: true,
      );

  @override
  Widget build(BuildContext context) {
    final today = _applyFilter(_today);
    final earlier = _applyFilter(_earlier);
    final unreadCount = [..._today, ..._earlier].where((n) => !n.isRead).length;
    final isEmpty = today.isEmpty && earlier.isEmpty;

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

                // Horizontally scrollable chips — also scrolls away with page
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
                    child: SizedBox(
                      height: 40.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        primary: false,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _filters.length,
                        separatorBuilder: (context, index) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          final item = _filters[index];
                          return _FilterChip(
                            label: item.label,
                            icon: item.icon,
                            selected: _filter == index,
                            badge: index == 1 && unreadCount > 0 ? unreadCount : null,
                            onTap: () => setState(() => _filter = index),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                if (isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else ...[
                  if (today.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
                        child: _SectionLabel(
                          label: 'Today',
                          count: today.length,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList.separated(
                        itemCount: today.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final n = today[index];
                          return _NotificationCard(
                            notification: n,
                            onTap: () => _markOneRead(n, isToday: true),
                          );
                        },
                      ),
                    ),
                  ],
                  if (earlier.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                        child: _SectionLabel(
                          label: 'Earlier',
                          count: earlier.length,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList.separated(
                        itemCount: earlier.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final n = earlier[index];
                          return _NotificationCard(
                            notification: n,
                            onTap: () => _markOneRead(n, isToday: false),
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
    setState(() {
      final updated = _asRead(n);
      if (isToday) {
        final i = _today.indexOf(n);
        if (i >= 0) _today[i] = updated;
      } else {
        final i = _earlier.indexOf(n);
        if (i >= 0) _earlier[i] = updated;
      }
    });
  }
}

class _FilterOption {
  const _FilterOption({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: selected ? 12 : 8,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15.sp,
              color: selected ? Colors.white : AppColors.muted,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.body,
              ),
            ),
            if (badge != null) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.22)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$badge',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(notification.type);
    final unread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: unread
                ? AppColors.primary.withValues(alpha: 0.14)
                : AppColors.border.withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
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
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        style.label,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: style.iconColor,
                        ),
                      ),
                      if (unread) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppColors.muted.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'New',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
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

  _NotifStyle _styleFor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const _NotifStyle(
          icon: Iconsax.calendar,
          label: 'Appointment',
          background: AppColors.primaryLight,
          iconColor: AppColors.primary,
        );
      case NotificationType.message:
        return const _NotifStyle(
          icon: Iconsax.message,
          label: 'Message',
          background: AppColors.neuro,
          iconColor: AppColors.neuroIcon,
        );
      case NotificationType.reminder:
        return const _NotifStyle(
          icon: Iconsax.clock,
          label: 'Reminder',
          background: AppColors.derma,
          iconColor: AppColors.dermaIcon,
        );
      case NotificationType.promo:
        return const _NotifStyle(
          icon: Iconsax.heart,
          label: 'Health Tip',
          background: AppColors.cardio,
          iconColor: AppColors.cardioIcon,
        );
      case NotificationType.system:
        return const _NotifStyle(
          icon: Iconsax.tick_circle,
          label: 'System',
          background: Color(0xFFE8FFF3),
          iconColor: AppColors.success,
        );
    }
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
              'Try another filter or check back later',
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
    required this.label,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
}
