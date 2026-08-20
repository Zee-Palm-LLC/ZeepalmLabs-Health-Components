import 'package:docora/core/constants/app_images.dart';
import 'package:docora/features/home/components/custom_icon_btn.dart';
import 'package:docora/features/messages/messages_screen.dart';
import 'package:docora/features/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.blurProgress = 0,
  });

  /// 0 = fully transparent, 1 = solid frosted overlay
  final double blurProgress;

  @override
  Widget build(BuildContext context) {
    final progress = blurProgress.clamp(0.0, 1.0);

    return AppBar(
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: progress > 0
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92 * progress),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.05 * progress),
                  ),
                ),
              ),
            )
          : null,
      leading: Center(
        child: CircleAvatar(
          backgroundImage: const AssetImage(AppImages.userAvatar),
        ),
      ),
      titleSpacing: 10.w,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, Good Morning',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          Text(
            'Dr. John Doe',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
      actions: [
        CustomIconBtn(
          icon: Iconsax.message,
          onTap: () => Get.to(() => const MessagesScreen()),
        ),
        SizedBox(width: 10.w),
        CustomIconBtn(
          icon: Iconsax.notification,
          onTap: () => Get.to(() => const NotificationsScreen()),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
