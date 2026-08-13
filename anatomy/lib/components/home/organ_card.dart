import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/organ.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class OrganCard extends StatelessWidget {
  const OrganCard({
    super.key,
    required this.organ,
    this.selected = false,
    this.onTap,
  });

  final Organ organ;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? organ.accent : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? organ.accent.withValues(alpha: 0.2)
                    : AppColors.ink.withValues(alpha: 0.04),
                blurRadius: selected ? 18.r : 12.r,
                offset: Offset(0, selected ? 8.h : 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(19.r)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        organ.thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: organ.accent.withValues(alpha: 0.12),
                          alignment: Alignment.center,
                          child: Text(
                            organ.name.isNotEmpty ? organ.name[0] : '?',
                            style: AppTypography.display(
                              size: 36,
                              color: organ.accent,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 48.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.ink.withValues(alpha: 0.35),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (selected)
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: organ.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organ.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 16),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      organ.poetic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 11,
                        color: AppColors.muted,
                        fontStyle: FontStyle.italic,
                        weight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      organ.system,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        size: 10,
                        color: AppColors.accentMuted,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
