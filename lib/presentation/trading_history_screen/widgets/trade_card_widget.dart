import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TradeCardWidget extends StatelessWidget {
  final Map<String, dynamic> trade;
  final VoidCallback? onTap;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final bool isSelected;

  const TradeCardWidget({
    Key? key,
    required this.trade,
    this.onTap,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double pnl = (trade['pnl'] as num).toDouble();
    final bool isProfit = pnl > 0;
    final String tradeType = trade['type'] as String;
    final String mode = trade['mode'] as String;

    return Dismissible(
      key: Key(trade['id'].toString()),
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'analytics',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Análisis Similar',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Compartir',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd && onSwipeLeft != null) {
          onSwipeLeft!();
        } else if (direction == DismissDirection.endToStart &&
            onSwipeRight != null) {
          onSwipeRight!();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1)
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: tradeType == 'BUY'
                                ? AppTheme.lightTheme.colorScheme.secondary
                                    .withOpacity(0.2)
                                : AppTheme.warningLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tradeType,
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: tradeType == 'BUY'
                                  ? AppTheme.lightTheme.colorScheme.secondary
                                  : AppTheme.warningLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: mode == 'LIVE'
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withOpacity(0.2)
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mode,
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: mode == 'LIVE'
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      trade['timestamp'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Precio Entrada',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '\$${(trade['entryPrice'] as num).toStringAsFixed(2)}',
                            style: AppTheme.getDataTextStyle(
                              isLight: true,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Precio Salida',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            trade['exitPrice'] != null
                                ? '\$${(trade['exitPrice'] as num).toStringAsFixed(2)}'
                                : 'Activo',
                            style: AppTheme.getDataTextStyle(
                              isLight: true,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: trade['exitPrice'] != null
                                  ? null
                                  : AppTheme.lightTheme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'P&L',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${isProfit ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                            style: AppTheme.getDataTextStyle(
                              isLight: true,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getProfitLossColor(pnl,
                                  isLight: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'access_time',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          trade['duration'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'trending_up',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          trade['signal'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(trade['quantity'] as num).toStringAsFixed(4)} ETH',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
