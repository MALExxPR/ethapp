import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SummaryStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const SummaryStatsWidget({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                iconName: 'analytics',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Resumen de Trading',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Trades',
                  stats['totalTrades'].toString(),
                  CustomIconWidget(
                    iconName: 'swap_horiz',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Tasa de Éxito',
                  '${(stats['winRate'] as num).toStringAsFixed(1)}%',
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'P&L Promedio',
                  '\$${(stats['avgPnL'] as num).toStringAsFixed(2)}',
                  CustomIconWidget(
                    iconName: 'account_balance',
                    color: AppTheme.getProfitLossColor(
                      (stats['avgPnL'] as num).toDouble(),
                      isLight: true,
                    ),
                    size: 16,
                  ),
                  valueColor: AppTheme.getProfitLossColor(
                    (stats['avgPnL'] as num).toDouble(),
                    isLight: true,
                  ),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Mejor Trade',
                  '\$${(stats['bestTrade'] as num).toStringAsFixed(2)}',
                  CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 16,
                  ),
                  valueColor: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Widget icon, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon,
            SizedBox(width: 1.w),
            Expanded(
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.getDataTextStyle(
            isLight: true,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
