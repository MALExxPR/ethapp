import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RiskStatusGaugeWidget extends StatelessWidget {
  final double riskPercentage;
  final String riskLevel;

  const RiskStatusGaugeWidget({
    Key? key,
    required this.riskPercentage,
    required this.riskLevel,
  }) : super(key: key);

  Color _getRiskColor() {
    if (riskPercentage <= 30) {
      return AppTheme.lightTheme.colorScheme.tertiary; // Green
    } else if (riskPercentage <= 70) {
      return Colors.orange; // Yellow/Orange
    } else {
      return AppTheme.lightTheme.colorScheme.error; // Red
    }
  }

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
        children: [
          Text(
            'Estado del Riesgo',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 30.w,
                height: 30.w,
                child: CircularProgressIndicator(
                  value: riskPercentage / 100,
                  strokeWidth: 2.w,
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(_getRiskColor()),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${riskPercentage.toStringAsFixed(1)}%',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: _getRiskColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    riskLevel,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Límite diario de drawdown consumido',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
