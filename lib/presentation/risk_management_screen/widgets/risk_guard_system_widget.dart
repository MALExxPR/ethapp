import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class RiskGuardSystemWidget extends StatefulWidget {
  final Map<String, bool> guardSettings;
  final Function(String, bool) onGuardToggle;

  const RiskGuardSystemWidget({
    Key? key,
    required this.guardSettings,
    required this.onGuardToggle,
  }) : super(key: key);

  @override
  State<RiskGuardSystemWidget> createState() => _RiskGuardSystemWidgetState();
}

class _RiskGuardSystemWidgetState extends State<RiskGuardSystemWidget> {
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
                iconName: 'security',
                color: AppTheme.lightTheme.primaryColor,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Sistema de Protección',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildGuardToggle(
            title: 'Límite de Pérdida Diaria',
            subtitle: 'Detener trading al alcanzar 5% de drawdown',
            key: 'dailyLossLimit',
            icon: 'trending_down',
          ),
          SizedBox(height: 2.h),
          _buildGuardToggle(
            title: 'Pérdidas Consecutivas',
            subtitle: 'Parar después de 3 operaciones perdedoras seguidas',
            key: 'consecutiveLosses',
            icon: 'close',
          ),
          SizedBox(height: 2.h),
          _buildGuardToggle(
            title: 'Alta Volatilidad',
            subtitle: 'Suspender durante períodos de volatilidad extrema',
            key: 'highVolatility',
            icon: 'show_chart',
          ),
          SizedBox(height: 2.h),
          _buildGuardToggle(
            title: 'Exposición Máxima',
            subtitle: 'Limitar posiciones abiertas simultáneas',
            key: 'maxExposure',
            icon: 'account_balance',
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Los cambios en la protección requieren confirmación biométrica',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardToggle({
    required String title,
    required String subtitle,
    required String key,
    required String icon,
  }) {
    final isEnabled = widget.guardSettings[key] ?? false;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: isEnabled
              ? AppTheme.lightTheme.colorScheme.tertiary
              : AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppTheme.lightTheme.colorScheme.tertiary
                      .withOpacity(0.1)
                  : AppTheme.borderLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: isEnabled
                  ? AppTheme.lightTheme.colorScheme.tertiary
                  : AppTheme.textSecondaryLight,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              widget.onGuardToggle(key, value);
            },
            activeColor: AppTheme.lightTheme.colorScheme.tertiary,
            inactiveThumbColor: AppTheme.textSecondaryLight,
            inactiveTrackColor: AppTheme.borderLight,
          ),
        ],
      ),
    );
  }
}
