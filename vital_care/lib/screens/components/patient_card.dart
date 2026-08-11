import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vital_care/screens/components/card_shell.dart';
import 'package:iconsax/iconsax.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({super.key});

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color heartRed = Color(0xFFFF5A63);
  static const Color mutedText = Color(0xFF64748B);
  static const Color statusGreen = Color(0xFF2BD67B);

  @override
  Widget build(BuildContext context) {
    return CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _PatientAvatar(),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(6.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFFFF), Color(0xFFF2F6FF)],
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: _Field(
                              icon: Iconsax.user,
                              label: 'Name',
                              value: 'Jackson Wang',
                            ),
                          ),
                          const _Field(
                            icon: Iconsax.activity,
                            label: 'Age',
                            value: '42',
                            alignEnd: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              const Row(
                children: [
                  Expanded(
                    child: _Field(
                      icon: Iconsax.user_tag,
                      label: 'Patient ID',
                      value: 'RM-0962-TO',
                    ),
                  ),
                  _Field(
                    icon: Iconsax.calendar_1,
                    label: 'Checkup Date',
                    value: 'August 12, 2026',
                    alignEnd: true,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 11.sp,
                    color: PatientCard.primaryBlue.withValues(alpha: 0.8),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Primary Complaint',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: PatientCard.mutedText,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  color: PatientCard.heartRed.withValues(alpha: 0.04),
                  border: Border(
                    left: BorderSide(
                      color: PatientCard.primaryBlue.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Text(
                    'Patient reports a persistent dry cough for the past 5 days, associated with mild chest discomfort and shortness of breath, particularly during physical activity. Symptoms have gradually worsened over the last two days.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: const Color(0xFF0F172A),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 700.ms)
        .slideY(begin: 0.06, end: 0, duration: 700.ms, curve: Curves.easeOut);
  }
}

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.r,
      height: 60.r,
      child: Stack(
        children: [
          Positioned.fill(
            child:
                Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            PatientCard.heartRed.withValues(alpha: 0.22),
                            PatientCard.heartRed.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1.15, 1.15),
                      duration: 1600.ms,
                      curve: Curves.easeInOut,
                    ),
          ),
          Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [PatientCard.primaryBlue, Color(0xFF38BDF8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: PatientCard.heartRed.withValues(alpha: 0.25),
                  blurRadius: 12.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 1.r,
            bottom: 2.r,
            child: Container(
              width: 14.r,
              height: 14.r,
              decoration: BoxDecoration(
                color: PatientCard.statusGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: PatientCard.statusGreen.withValues(alpha: 0.7),
                    blurRadius: 8.r,
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
    required this.icon,
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11.sp,
              color: PatientCard.primaryBlue.withValues(alpha: 0.8),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: PatientCard.mutedText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
