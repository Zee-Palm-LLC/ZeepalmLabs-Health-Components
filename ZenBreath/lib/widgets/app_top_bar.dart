import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text.dart';

/// Serif screen title bar shared by Library, Progress and Profile. Transparent
/// so the page gradient painted by the shell reads straight through it.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  static const _height = 60.0;

  @override
  Size get preferredSize => Size.fromHeight(_height.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _height.h,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20.w,
      title: Text(title, style: AppText.screenTitle()),
      actions: [
        ...?actions,
        SizedBox(width: 12.w),
      ],
    );
  }
}
