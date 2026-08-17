import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CustomSearchField extends StatefulWidget {
  const CustomSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search doctor, drugs, articles...',
    this.onTap,
    this.onChanged,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  late final FocusNode _focusNode;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _inset => _pressed || _focusNode.hasFocus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            },
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: _NeumorphicDecoration.box(radius: 100.r, inset: _inset),
        child: Row(
          children: [
            Icon(
              Iconsax.search_normal,
              size: 20.sp,
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                readOnly: widget.readOnly,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1B1F2A),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeumorphicDecoration {
  static BoxDecoration box({required double radius, required bool inset}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      gradient: inset
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF3F4F6), Color(0xFFFFFFFF)],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FA)],
            ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.95),
        width: 1.2,
      ),
      boxShadow: inset ? _insetShadows : _raisedShadows,
    );
  }

  static List<BoxShadow> get _raisedShadows => [
        BoxShadow(
          color: const Color(0xFF9CA3AF).withValues(alpha: 0.28),
          offset: Offset(4.w, 5.h),
          blurRadius: 10.r,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.95),
          offset: Offset(-3.w, -3.h),
          blurRadius: 8.r,
        ),
        BoxShadow(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.6),
          offset: Offset(0, 2.h),
          blurRadius: 4.r,
        ),
      ];

  static List<BoxShadow> get _insetShadows => [
        BoxShadow(
          color: const Color(0xFFD1D5DB).withValues(alpha: 0.35),
          offset: Offset(1.5.w, 1.5.h),
          blurRadius: 4.r,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.9),
          offset: Offset(-1.w, -1.h),
          blurRadius: 3.r,
        ),
      ];
}
