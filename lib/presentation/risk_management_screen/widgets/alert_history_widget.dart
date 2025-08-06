import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class AlertHistoryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> alerts;

  const AlertHistoryWidget({
    Key? key,
    required this.alerts,
  }) : super(key: key);

  @override
  State<AlertHistoryWidget> createState() => _AlertHistoryWidgetState();
}

class _AlertHistoryWidgetState extends State<AlertHistoryWidget> {
  int? _expandedIndex;

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
                iconName: 'history',
                color: AppTheme.lightTheme.primaryColor,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Historial de Alertas',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          widget.alerts.isEmpty
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
                        iconName: 'notifications_off',
                        color: AppTheme.textSecondaryLight,
                        size: 6.w,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'No hay alertas recientes',
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
                  itemCount: widget.alerts.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final alert = widget.alerts[index];
                    final isExpanded = _expandedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border(
                            left: BorderSide(
                              width: 1.w,
                              color: _getAlertColor(alert['severity'] as String),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: _getAlertColor(
                                            alert['severity'] as String)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(1.w),
                                  ),
                                  child: CustomIconWidget(
                                    iconName:
                                        _getAlertIcon(alert['type'] as String),
                                    color: _getAlertColor(
                                        alert['severity'] as String),
                                    size: 4.w,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert['title'] as String,
                                        style: AppTheme
                                            .lightTheme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        alert['timestamp'] as String,
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomIconWidget(
                                  iconName: isExpanded
                                      ? 'expand_less'
                                      : 'expand_more',
                                  color: AppTheme.textSecondaryLight,
                                  size: 5.w,
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              SizedBox(height: 2.h),
                              Text(
                                alert['description'] as String,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Acción tomada:',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.textSecondaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(1.w),
                                    ),
                                    child: Text(
                                      alert['actionTaken'] as String,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.tertiary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppTheme.lightTheme.colorScheme.error;
      case 'medium':
        return Colors.orange;
      case 'low':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.textSecondaryLight;
    }
  }

  String _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'drawdown':
        return 'trending_down';
      case 'loss':
        return 'close';
      case 'volatility':
        return 'show_chart';
      case 'position':
        return 'account_balance';
      default:
        return 'warning';
    }
  }
}