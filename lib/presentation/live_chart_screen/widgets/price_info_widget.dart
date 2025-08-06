import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PriceInfoWidget extends StatelessWidget {
  final double currentPrice;
  final double priceChange;
  final double priceChangePercent;
  final double volume24h;
  final double high24h;
  final double low24h;
  final bool isConnected;

  const PriceInfoWidget({
    Key? key,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    required this.isConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = priceChange >= 0;
    final changeColor =
        isPositive ? AppTheme.successLight : AppTheme.warningLight;

    return Container(
      padding: EdgeInsets.all(3.w),
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
      child: Column(
        children: [
          // Main price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'ETH/USDT',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AppTheme.successLight
                              : AppTheme.warningLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName:
                              isPositive ? 'arrow_upward' : 'arrow_downward',
                          color: changeColor,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${isPositive ? '+' : ''}\$${priceChange.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: changeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // 24h stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: '24h Alto',
                  value: '\$${high24h.toStringAsFixed(2)}',
                  color: AppTheme.successLight,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: '24h Bajo',
                  value: '\$${low24h.toStringAsFixed(2)}',
                  color: AppTheme.warningLight,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: '24h Volumen',
                  value: _formatVolume(volume24h),
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toStringAsFixed(0);
    }
  }
}
