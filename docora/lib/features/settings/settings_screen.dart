import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/components/custom_shade.dart';
import '../appointments/my_appointments_screen.dart';
import '../messages/components/message_motion.dart';
import '../payments/payment_methods_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../records/medical_records_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _biometrics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 56.h,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: Stack(
        children: [
          const CustomShade(height: 96),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 118.h),
              child: Column(
                children: [
                  FadeScaleIn(child: _ProfileHero()),
                  SizedBox(height: 14.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 70),
                    child: _StatsRow(),
                  ),
                  SizedBox(height: 16.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 120),
                    child: _SettingsGroup(
                      title: 'Preferences',
                      children: [
                        _ToggleTile(
                          icon: Iconsax.notification,
                          tint: AppColors.primaryLight,
                          iconColor: AppColors.primary,
                          title: 'Notifications',
                          subtitle: 'Appointment reminders',
                          value: _notifications,
                          onChanged: (v) => setState(() => _notifications = v),
                        ),
                        _ToggleTile(
                          icon: Iconsax.moon,
                          tint: const Color(0xFFEEE8FF),
                          iconColor: const Color(0xFF7C5CFF),
                          title: 'Dark mode',
                          subtitle: 'Coming with next update',
                          value: _darkMode,
                          onChanged: (v) => setState(() => _darkMode = v),
                        ),
                        _ToggleTile(
                          icon: Iconsax.finger_scan,
                          tint: const Color(0xFFE8FFF3),
                          iconColor: AppColors.success,
                          title: 'Face ID / Touch ID',
                          subtitle: 'Faster, safer login',
                          value: _biometrics,
                          onChanged: (v) => setState(() => _biometrics = v),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 170),
                    child: _SettingsGroup(
                      title: 'Account',
                      children: [
                        _LinkTile(
                          icon: Iconsax.user_edit,
                          tint: Color(0xFFE8F1FF),
                          iconColor: AppColors.primary,
                          title: 'Personal details',
                          onTap: () => AppNav.to(const EditProfileScreen()),
                        ),
                        _LinkTile(
                          icon: Iconsax.card,
                          tint: Color(0xFFFFF3E0),
                          iconColor: AppColors.dermaIcon,
                          title: 'Payment methods',
                          onTap: () => AppNav.to(const PaymentMethodsScreen()),
                        ),
                        _LinkTile(
                          icon: Iconsax.document,
                          tint: Color(0xFFF4F6FA),
                          iconColor: AppColors.body,
                          title: 'Medical records',
                          onTap: () => AppNav.to(const MedicalRecordsScreen()),
                        ),
                        _LinkTile(
                          icon: Iconsax.shield_tick,
                          tint: Color(0xFFE8FFF3),
                          iconColor: AppColors.success,
                          title: 'Privacy & security',
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 220),
                    child: _SettingsGroup(
                      title: 'Support',
                      children: [
                        _LinkTile(
                          icon: Iconsax.message_question,
                          tint: Color(0xFFEAF3FF),
                          iconColor: AppColors.neuroIcon,
                          title: 'Help center',
                        ),
                        _LinkTile(
                          icon: Iconsax.document_text,
                          tint: Color(0xFFF4F6FA),
                          iconColor: AppColors.body,
                          title: 'Terms & policies',
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 270),
                    child: PressScale(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.cardioIcon.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          'Log out',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cardioIcon,
                          ),
                        ),
                      ),
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

class _ProfileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A9AFF), AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 28.r,
              backgroundImage: const AssetImage(AppImages.userAvatar),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockData.userName,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Premium member',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Edit',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            value: '12',
            label: 'Visits',
            onTap: () => AppNav.to(const MyAppointmentsScreen()),
          ),
        ),
        SizedBox(width: 8.w),
        const Expanded(child: _StatChip(value: '5', label: 'Saved')),
        SizedBox(width: 8.w),
        const Expanded(child: _StatChip(value: '4.9', label: 'Rating')),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label, this.onTap});

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.body),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.7),
                    width: 0.6,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 17.sp, color: iconColor),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
            Icon(Iconsax.arrow_right_3, size: 16.sp, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.7),
                  width: 0.6,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 17.sp, color: iconColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.body,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
