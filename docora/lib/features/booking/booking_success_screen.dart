import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_shade.dart';
import '../shell/main_shell.dart';
import 'booking_widgets.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({
    super.key,
    required this.doctor,
    required this.dateLabel,
    required this.timeLabel,
    required this.periodLabel,
  });

  final DoctorModel doctor;
  final String dateLabel;
  final String timeLabel;
  final String periodLabel;

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _in;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _in.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _goHome() {
    Get.offAll(() => const MainShell());
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final checkScale = CurvedAnimation(
      parent: _in,
      curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
    );
    final fade = CurvedAnimation(
      parent: _in,
      curve: const Interval(0.28, 0.85, curve: Curves.easeOutCubic),
    );
    final ticket = CurvedAnimation(
      parent: _in,
      curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          const CustomShade(height: 140),
          // Soft floating orbs
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final t = _pulse.value;
              return Stack(
                children: [
                  Positioned(
                    top: 80.h + t * 8,
                    right: -20.w,
                    child: _GlowOrb(
                      size: 120.w,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    top: 200.h - t * 6,
                    left: -30.w,
                    child: _GlowOrb(
                      size: 100.w,
                      color: const Color(0xFF4A9AFF).withValues(alpha: 0.07),
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  BookingFadeSlide(
                    animation: _in,
                    begin: 0,
                    end: 0.3,
                    child: const BookingStepBar(step: 3),
                  ),
                  const Spacer(flex: 1),
                  ScaleTransition(
                    scale: checkScale,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final glow = 0.25 + _pulse.value * 0.2;
                        return Container(
                          width: 96.w,
                          height: 96.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4A9AFF),
                                AppColors.primary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: glow),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: Icon(
                        Iconsax.tick_circle,
                        size: 48.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  FadeTransition(
                    opacity: fade,
                    child: Column(
                      children: [
                        Text(
                          'You\'re all set!',
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Your appointment is confirmed.\nWe\'ll send a reminder before the visit.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.body,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.h),
                  FadeTransition(
                    opacity: ticket,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(ticket),
                      child: _TicketCard(
                        doctor: d,
                        dateLabel: widget.dateLabel,
                        timeLabel: widget.timeLabel,
                        periodLabel: widget.periodLabel,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  FadeTransition(
                    opacity: fade,
                    child: Column(
                      children: [
                        BookingPrimaryButton(
                          label: 'Back to Home',
                          icon: Iconsax.home_2,
                          onTap: _goHome,
                        ),
                        SizedBox(height: 8.h),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Iconsax.calendar_add,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Add to Calendar',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
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

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.doctor,
    required this.dateLabel,
    required this.timeLabel,
    required this.periodLabel,
  });

  final DoctorModel doctor;
  final String dateLabel;
  final String timeLabel;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header strip
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
              gradient: const LinearGradient(
                colors: [Color(0xFF4A9AFF), AppColors.primary],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 44.w,
                      height: 44.w,
                      child: doctor.imageUrl != null
                          ? AppImage(
                              path: doctor.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : ColoredBox(color: doctor.avatarColor),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        doctor.specialty,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '\$${doctor.fee.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Perforation
          SizedBox(
            height: 20.h,
            child: CustomPaint(
              painter: _PerforationPainter(),
              child: const SizedBox.expand(),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TicketCell(
                        icon: Iconsax.calendar_1,
                        label: 'Date',
                        value: dateLabel,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _TicketCell(
                        icon: Iconsax.clock,
                        label: 'Time',
                        value: '$timeLabel · $periodLabel',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _TicketCell(
                  icon: Iconsax.hospital,
                  label: 'Hospital',
                  value: doctor.hospital,
                  full: true,
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.scan_barcode,
                        size: 16.sp,
                        color: AppColors.muted,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'DOC-${doctor.id.toUpperCase()}-${dateLabel.hashCode.abs() % 9000 + 1000}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: AppColors.body,
                        ),
                      ),
                    ],
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

class _TicketCell extends StatelessWidget {
  const _TicketCell({
    required this.icon,
    required this.label,
    required this.value,
    this.full = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: full ? double.infinity : null,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: AppColors.muted,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
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

class _PerforationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.85)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dash = 5.0;
    const gap = 4.0;
    var x = 16.0;
    final y = size.height / 2;
    while (x < size.width - 16) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, size.width - 16), y), paint);
      x += dash + gap;
    }

    final hole = Paint()..color = AppColors.background;
    canvas.drawCircle(Offset(0, y), 8, hole);
    canvas.drawCircle(Offset(size.width, y), 8, hole);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
