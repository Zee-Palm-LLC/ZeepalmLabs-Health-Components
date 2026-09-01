import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: Center(
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            'https://thumbs.dreamstime.com/b/realistic-d-avatar-man-classic-suit-tie-white-shirt-background-representing-office-worker-lawyer-ideal-341136098.jpg',
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Good Morning,', style: AppTextStyles.greeting),
          Text('Alex 👋', style: AppTextStyles.userName),
        ],
      ),
      actions: [
        Icon(Iconsax.notification),
        SizedBox(width: 16.w),
      ],
    );
  }
}
