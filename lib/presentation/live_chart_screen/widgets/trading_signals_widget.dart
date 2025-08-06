import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TradingSignalsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> signals;
  final Function(Map<String, dynamic>)? onSignalTap;

  const TradingSignalsWidget({
    Key? key,
    required this.signals,
    this.onSignalTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (signals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 15.h,
      left: 2.w,
      right: 2.w,
      child: Container(
        height: 8.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: signals.length,
          itemBuilder: (context, index) {
            final signal = signals[index];
            return Container(
              margin: EdgeInsets.only(right: 2.w),
              child: _buildSignalCard(signal),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignalCard(Map<String, dynamic> signal) {
    final signalType = signal['type'] as String;
    final isBuy = signalType.toLowerCase() == 'buy';
    final strength = signal['strength'] as String;
    final price = signal['price'] as double;
    final timestamp = signal['timestamp'] as DateTime;

    return GestureDetector(
      onTap: () => onSignalTap?.call(signal),
      child: Container(
        width: 35.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBuy ? AppTheme.successLight : AppTheme.warningLight,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: isBuy
                        ? AppTheme.successLight.withOpacity(0.1)
                        : AppTheme.warningLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: isBuy ? 'trending_up' : 'trending_down',
                        color: isBuy
                            ? AppTheme.successLight
                            : AppTheme.warningLight,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        signalType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: isBuy
                              ? AppTheme.successLight
                              : AppTheme.warningLight,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStrengthIndicator(strength),
              ],
            ),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthIndicator(String strength) {
    Color strengthColor;
    int strengthLevel;

    switch (strength.toLowerCase()) {
      case 'weak':
        strengthColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        strengthLevel = 1;
        break;
      case 'moderate':
        strengthColor = AppTheme.warningLight;
        strengthLevel = 2;
        break;
      case 'strong':
        strengthColor = AppTheme.successLight;
        strengthLevel = 3;
        break;
      default:
        strengthColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        strengthLevel = 1;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 1.w,
          height: 2.h,
          margin: EdgeInsets.only(left: index > 0 ? 0.5.w : 0),
          decoration: BoxDecoration(
            color: index < strengthLevel
                ? strengthColor
                : strengthColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}
