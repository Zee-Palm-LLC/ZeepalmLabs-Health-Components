import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../messages/components/message_motion.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _dob;
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: MockData.userName);
    _email = TextEditingController(text: 'farhan@docora.app');
    _phone = TextEditingController(text: '+1 555 0199');
    _dob = TextEditingController(text: '12 Mar 1996');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    super.dispose();
  }

  void _save() {
    Get.snackbar(
      'Profile updated',
      'Your changes have been saved',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: AppColors.ink,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
    AppNav.back();
  }

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
        scrolledUnderElevation: 0,
        leadingWidth: 56.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: CustomIconBtn(
            icon: Iconsax.arrow_left_2,
            onTap: AppNav.back,
          ),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const CustomShade(height: 100),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
              child: Column(
                children: [
                  FadeScaleIn(
                    child: Column(
                      children: [
                        Container(
                          width: 88.w,
                          height: 88.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: Offset(0, 6.h),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const AppImage(
                            path: AppImages.userAvatar,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Change photo',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 60),
                    child: Column(
                      children: [
                        _Field(label: 'Full name', controller: _name),
                        SizedBox(height: 12.h),
                        _Field(
                          label: 'Email',
                          controller: _email,
                          keyboard: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          label: 'Phone',
                          controller: _phone,
                          keyboard: TextInputType.phone,
                        ),
                        SizedBox(height: 12.h),
                        _GenderField(
                          value: _gender,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          label: 'Date of birth',
                          controller: _dob,
                          icon: Iconsax.calendar,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  FadeScaleIn(
                    delay: const Duration(milliseconds: 120),
                    child: PressScale(
                      onTap: _save,
                      child: Container(
                        height: 52.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4A9AFF),
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: Offset(0, 6.h),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboard,
    this.icon,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.body,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboard,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 16.sp, color: AppColors.muted),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _options = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.body,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            for (final o in _options) ...[
              if (o != _options.first) SizedBox(width: 8.w),
              Expanded(
                child: PressScale(
                  onTap: () => onChanged(o),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: value == o ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color: value == o
                            ? AppColors.primary
                            : AppColors.border.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Text(
                      o,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: value == o ? Colors.white : AppColors.body,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
