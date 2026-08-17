import 'dart:ui';

import 'package:docora/features/home/components/custom_icon_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.blurProgress = 0,
  });

  /// 0 = fully transparent, 1 = full blur overlay
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
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 14 * progress,
                  sigmaY: 14 * progress,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75 * progress),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black.withValues(alpha: 0.05 * progress),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      leading: Center(
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            'https://plus.unsplash.com/premium_photo-1693258698597-1b2b1bf943cc?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          ),
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
        CustomIconBtn(icon: Iconsax.message, onTap: () {}),
        SizedBox(width: 10.w),
        CustomIconBtn(icon: Iconsax.notification, onTap: () {}),
        SizedBox(width: 16.w),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
