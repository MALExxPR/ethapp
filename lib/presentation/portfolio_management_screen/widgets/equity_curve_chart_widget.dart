import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class EquityCurveChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> equityData;

  const EquityCurveChartWidget({
    Key? key,
    required this.equityData,
  }) : super(key: key);

  @override
  State<EquityCurveChartWidget> createState() => _EquityCurveChartWidgetState();
}

class _EquityCurveChartWidgetState extends State<EquityCurveChartWidget> {
  String _selectedPeriod = '1D';
  final List<String> _periods = ['1D', '1W', '1M', '3M'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Curva de Patrimonio',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildPeriodSelector(),
            ],
          ),
          SizedBox(height: 2.h),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              height: 40.h,
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Expanded(
                    child: Semantics(
                      label: "Gráfico de Curva de Patrimonio",
                      child: LineChart(
                        _buildLineChartData(),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildChartLegend(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _periods.map((period) {
          final bool isSelected = period == _selectedPeriod;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = period;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                period,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final List<FlSpot> spots = [];
    final filteredData = _getFilteredData();

    for (int i = 0; i < filteredData.length; i++) {
      spots.add(FlSpot(
        i.toDouble(),
        (filteredData[i]['equity'] as double),
      ));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 500,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color:
                AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color:
                AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _getBottomInterval(),
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < filteredData.length) {
                final date = filteredData[value.toInt()]['date'] as DateTime;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _formatDateLabel(date),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1000,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  '\$${(value / 1000).toStringAsFixed(0)}K',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.6),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      minX: 0,
      maxX: (filteredData.length - 1).toDouble(),
      minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 500,
      maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 500,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.colorScheme.secondary,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.primaryColor.withOpacity(0.3),
                AppTheme.lightTheme.colorScheme.secondary
                    .withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              if (flSpot.x.toInt() >= 0 &&
                  flSpot.x.toInt() < filteredData.length) {
                final date = filteredData[flSpot.x.toInt()]['date'] as DateTime;
                return LineTooltipItem(
                  '\$${flSpot.y.toStringAsFixed(2)}\n${_formatTooltipDate(date)}',
                  AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 4.w,
          height: 0.5.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.primaryColor,
                AppTheme.lightTheme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          'Patrimonio Total',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredData() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case '1D':
        startDate = now.subtract(Duration(days: 1));
        break;
      case '1W':
        startDate = now.subtract(Duration(days: 7));
        break;
      case '1M':
        startDate = now.subtract(Duration(days: 30));
        break;
      case '3M':
        startDate = now.subtract(Duration(days: 90));
        break;
      default:
        startDate = now.subtract(Duration(days: 1));
    }

    return widget.equityData.where((data) {
      final date = data['date'] as DateTime;
      return date.isAfter(startDate);
    }).toList();
  }

  double _getBottomInterval() {
    switch (_selectedPeriod) {
      case '1D':
        return 6; // Every 6 hours
      case '1W':
        return 1; // Every day
      case '1M':
        return 7; // Every week
      case '3M':
        return 15; // Every 2 weeks
      default:
        return 1;
    }
  }

  String _formatDateLabel(DateTime date) {
    switch (_selectedPeriod) {
      case '1D':
        return '${date.hour.toString().padLeft(2, '0')}:00';
      case '1W':
        return '${date.day}/${date.month}';
      case '1M':
      case '3M':
        return '${date.day}/${date.month}';
      default:
        return '${date.day}/${date.month}';
    }
  }

  String _formatTooltipDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
