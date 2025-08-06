import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class StatusIndicatorWidget extends StatelessWidget {
  final String status;
  final bool isConnected;
  final VoidCallback? onRetry;

  const StatusIndicatorWidget({
    super.key,
    required this.status,
    required this.isConnected,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: isConnected
              ? AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.3)
              : AppTheme.warningLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.warningLight,
              boxShadow: [
                BoxShadow(
                  color: (isConnected
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.warningLight)
                      .withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 2.8.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (!isConnected && onRetry != null) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.warningLight.withOpacity(0.2),
                ),
                child: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.warningLight,
                  size: 3.w,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}