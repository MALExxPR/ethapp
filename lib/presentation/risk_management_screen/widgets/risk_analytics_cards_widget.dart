import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class RiskAnalyticsCardsWidget extends StatelessWidget {
  final Map<String, dynamic> riskMetrics;

  const RiskAnalyticsCardsWidget({
    Key? key,
    required this.riskMetrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                title: 'Drawdown Máximo Hoy',
                value:
                    '${(riskMetrics['maxDrawdownToday'] as double).toStringAsFixed(2)}%',
                trend: riskMetrics['drawdownTrend'] as String,
                icon: 'trending_down',
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildAnalyticsCard(
                title: 'Pérdidas Consecutivas',
                value: '${riskMetrics['consecutiveLosses'] as int}',
                trend: riskMetrics['lossesTrend'] as String,
                icon: 'close',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                title: 'Volatilidad',
                value:
                    '${(riskMetrics['volatility'] as double).toStringAsFixed(1)}%',
                trend: riskMetrics['volatilityTrend'] as String,
                icon: 'show_chart',
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildAnalyticsCard(
                title: 'Ratio Sharpe',
                value:
                    (riskMetrics['sharpeRatio'] as double).toStringAsFixed(2),
                trend: riskMetrics['sharpeTrend'] as String,
                icon: 'analytics',
                color: AppTheme.lightTheme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required String trend,
    required String icon,
    required Color color,
  }) {
    final isPositiveTrend = trend == 'up';
    final isNeutralTrend = trend == 'neutral';

    return Container(
      padding: EdgeInsets.all(3.w),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: color,
                size: 5.w,
              ),
              CustomIconWidget(
                iconName: isNeutralTrend
                    ? 'remove'
                    : isPositiveTrend
                        ? 'keyboard_arrow_up'
                        : 'keyboard_arrow_down',
                color: isNeutralTrend
                    ? AppTheme.textSecondaryLight
                    : isPositiveTrend
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : AppTheme.lightTheme.colorScheme.error,
                size: 4.w,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
