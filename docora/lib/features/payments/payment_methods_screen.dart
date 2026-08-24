import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/data/mock_data.dart';
import '../../core/navigation/app_nav.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import '../messages/components/message_motion.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late String _defaultId;

  @override
  void initState() {
    super.initState();
    _defaultId = MockData.payments.firstWhere((p) => p.isDefault).id;
  }

  @override
  Widget build(BuildContext context) {
    final cards = MockData.payments;

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
          'Payment Methods',
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
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) SizedBox(height: 12.h),
                  FadeScaleIn(
                    delay: Duration(milliseconds: 40 + i * 60),
                    child: _PaymentCard(
                      card: cards[i],
                      isDefault: cards[i].id == _defaultId,
                      onDefaultChanged: (v) {
                        if (v) setState(() => _defaultId = cards[i].id);
                      },
                    ),
                  ),
                ],
                SizedBox(height: 18.h),
                FadeScaleIn(
                  delay: const Duration(milliseconds: 160),
                  child: PressScale(
                    onTap: () => Get.snackbar(
                      'Add card',
                      'Card form coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.white,
                      colorText: AppColors.ink,
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12.r,
                    ),
                    child: Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.card, size: 18.sp, color: AppColors.primary),
                          SizedBox(width: 8.w),
                          Text(
                            'Add new card',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.card,
    required this.isDefault,
    required this.onDefaultChanged,
  });

  final PaymentCardModel card;
  final bool isDefault;
  final ValueChanged<bool> onDefaultChanged;

  bool get _isVisa => card.brand.toLowerCase().contains('visa');

  @override
  Widget build(BuildContext context) {
    final gradient = _isVisa
        ? const [Color(0xFF1A3A6B), Color(0xFF1677FF)]
        : const [Color(0xFF1B1F2A), Color(0xFF4B5563)];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.card, size: 22.sp, color: Colors.white),
                  const Spacer(),
                  Text(
                    card.brand,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              Text(
                '••••  ••••  ••••  ${card.last4}',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card holder',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        card.holder,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Expires',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        card.expiry,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
          ),
          child: Row(
            children: [
              Text(
                'Set as default',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: isDefault,
                onChanged: onDefaultChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
