import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TimeframeSelectorWidget extends StatelessWidget {
  final String selectedTimeframe;
  final Function(String) onTimeframeChanged;

  const TimeframeSelectorWidget({
    Key? key,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeframes = ['1m', '5m', '15m', '1h'];

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: timeframes.map((timeframe) {
          final isSelected = selectedTimeframe == timeframe;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTimeframeChanged(timeframe),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                padding: EdgeInsets.symmetric(vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    timeframe,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
