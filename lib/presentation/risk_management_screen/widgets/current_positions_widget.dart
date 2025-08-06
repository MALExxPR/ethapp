import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CurrentPositionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> positions;

  const CurrentPositionsWidget({
    Key? key,
    required this.positions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.lightTheme.primaryColor,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Posiciones Actuales',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          positions.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'info',
                        color: AppTheme.textSecondaryLight,
                        size: 6.w,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'No hay posiciones activas',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: positions.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final position = positions[index];
                    final isProfit = (position['unrealizedPnl'] as double) >= 0;
                    final timeRemaining = position['timeRemaining'] as String;

                    return Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: isProfit
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme.lightTheme.colorScheme.error,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: position['side'] == 'BUY'
                                          ? AppTheme
                                              .lightTheme.colorScheme.tertiary
                                          : AppTheme
                                              .lightTheme.colorScheme.error,
                                      borderRadius: BorderRadius.circular(1.w),
                                    ),
                                    child: Text(
                                      position['side'] as String,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    position['symbol'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${(position['quantity'] as double).toStringAsFixed(4)} ETH',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'P&L No Realizado',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.textSecondaryLight,
                                    ),
                                  ),
                                  Text(
                                    '\$${(position['unrealizedPnl'] as double).toStringAsFixed(2)}',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      color: isProfit
                                          ? AppTheme
                                              .lightTheme.colorScheme.tertiary
                                          : AppTheme
                                              .lightTheme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Tiempo Restante',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.textSecondaryLight,
                                    ),
                                  ),
                                  Text(
                                    timeRemaining,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Riesgo: ${(position['riskPercentage'] as double).toStringAsFixed(2)}%',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                              Text(
                                'Precio: \$${(position['entryPrice'] as double).toStringAsFixed(2)}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
