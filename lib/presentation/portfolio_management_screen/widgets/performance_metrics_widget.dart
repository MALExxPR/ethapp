import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PerformanceMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> performanceData;

  const PerformanceMetricsWidget({
    Key? key,
    required this.performanceData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas de Rendimiento',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Ratio de Sharpe',
                  (performanceData['sharpeRatio'] as double).toStringAsFixed(2),
                  'trending_up',
                  _getSharpeRatioColor(
                      performanceData['sharpeRatio'] as double),
                  (performanceData['sharpeRatio'] as double) / 3.0,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildMetricCard(
                  'Drawdown Máximo',
                  '${(performanceData['maxDrawdown'] as double).toStringAsFixed(1)}%',
                  'trending_down',
                  AppTheme.lightTheme.colorScheme.error,
                  (performanceData['maxDrawdown'] as double) / 20.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Tasa de Ganancia',
                  '${(performanceData['winRate'] as double).toStringAsFixed(1)}%',
                  'check_circle',
                  AppTheme.lightTheme.colorScheme.tertiary,
                  (performanceData['winRate'] as double) / 100.0,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildMetricCard(
                  'Operaciones Totales',
                  (performanceData['totalTrades'] as int).toString(),
                  'bar_chart',
                  AppTheme.lightTheme.primaryColor,
                  ((performanceData['totalTrades'] as int) / 1000.0)
                      .clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildWinLossStatistics(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String iconName,
    Color color,
    double progress,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIconWidget(
                  iconName: iconName,
                  color: color,
                  size: 24,
                ),
                Container(
                  width: 8.w,
                  height: 8.w,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 3,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinLossStatistics() {
    return Builder(
      builder: (BuildContext context) {
        final int totalTrades = performanceData['totalTrades'] as int;
        final double winRate = performanceData['winRate'] as double;
        final int winningTrades = (totalTrades * winRate / 100).round();
        final int losingTrades = totalTrades - winningTrades;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estadísticas de Operaciones',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () => _showTooltip(context,
                          'Muestra el desglose detallado de operaciones ganadoras vs perdedoras'),
                      child: CustomIconWidget(
                        iconName: 'info_outline',
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withOpacity(0.6),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      flex: winningTrades,
                      child: Container(
                        height: 1.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.tertiary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                            topRight: losingTrades == 0
                                ? Radius.circular(4)
                                : Radius.zero,
                            bottomRight: losingTrades == 0
                                ? Radius.circular(4)
                                : Radius.zero,
                          ),
                        ),
                      ),
                    ),
                    if (losingTrades > 0)
                      Expanded(
                        flex: losingTrades,
                        child: Container(
                          height: 1.h,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
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
                        Row(
                          children: [
                            Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Ganadoras',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '$winningTrades operaciones',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Perdedoras',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '$losingTrades operaciones',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSharpeRatioColor(double sharpeRatio) {
    if (sharpeRatio >= 2.0) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else if (sharpeRatio >= 1.0) {
      return AppTheme.lightTheme.primaryColor;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  void _showTooltip(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 4.w,
        right: 4.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
