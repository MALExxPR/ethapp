import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> candleData;
  final bool showEMA;
  final bool showRSI;
  final bool showBollingerBands;
  final Function(Map<String, dynamic>)? onCandleTap;

  const ChartWidget({
    Key? key,
    required this.candleData,
    this.showEMA = true,
    this.showRSI = true,
    this.showBollingerBands = true,
    this.onCandleTap,
  }) : super(key: key);

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  bool _showCrosshair = false;
  Offset? _crosshairPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50.h,
        width: double.infinity,
        padding: EdgeInsets.all(2.w),
        child: Column(children: [
          // Main candlestick chart
          Expanded(
              flex: 3,
              child: GestureDetector(
                  onLongPressStart: (details) {
                    setState(() {
                      _showCrosshair = true;
                      _crosshairPosition = details.localPosition;
                    });
                  },
                  onLongPressMoveUpdate: (details) {
                    setState(() {
                      _crosshairPosition = details.localPosition;
                    });
                  },
                  onLongPressEnd: (details) {
                    setState(() {
                      _showCrosshair = false;
                      _crosshairPosition = null;
                    });
                  },
                  child: Stack(children: [
                    LineChart(_buildCandlestickChart()),
                    if (_showCrosshair && _crosshairPosition != null)
                      _buildCrosshair(),
                  ]))),

          // Volume chart
          Expanded(
              flex: 1,
              child: Container(
                  margin: EdgeInsets.only(top: 2.h),
                  child: BarChart(_buildVolumeChart()))),

          // RSI indicator
          if (widget.showRSI)
            Expanded(
                flex: 1,
                child: Container(
                    margin: EdgeInsets.only(top: 2.h),
                    child: LineChart(_buildRSIChart()))),
        ]));
  }

  LineChartData _buildCandlestickChart() {
    final spots = <FlSpot>[];
    final ema9Spots = <FlSpot>[];
    final ema21Spots = <FlSpot>[];
    final upperBandSpots = <FlSpot>[];
    final lowerBandSpots = <FlSpot>[];

    for (int i = 0; i < widget.candleData.length; i++) {
      final candle = widget.candleData[i];
      final close = (candle['close'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), close));

      if (widget.showEMA) {
        ema9Spots.add(FlSpot(i.toDouble(), (candle['ema9'] as num).toDouble()));
        ema21Spots
            .add(FlSpot(i.toDouble(), (candle['ema21'] as num).toDouble()));
      }

      if (widget.showBollingerBands) {
        upperBandSpots
            .add(FlSpot(i.toDouble(), (candle['upperBand'] as num).toDouble()));
        lowerBandSpots
            .add(FlSpot(i.toDouble(), (candle['lowerBand'] as num).toDouble()));
      }
    }

    return LineChartData(
        gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 10,
            verticalInterval: 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withOpacity(0.3),
                  strokeWidth: 0.5);
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withOpacity(0.3),
                  strokeWidth: 0.5);
            }),
        titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 15.w,
                    getTitlesWidget: (value, meta) {
                      return Text('\$${value.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              fontSize: 10.sp));
                    })),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 4.h,
                    interval: 50,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.candleData.length) {
                        final timestamp =
                            widget.candleData[index]['timestamp'] as DateTime;
                        return Text(
                            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                fontSize: 10.sp));
                      }
                      return const SizedBox.shrink();
                    }))),
        borderData: FlBorderData(
            show: true,
            border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.5),
                width: 1)),
        lineBarsData: [
          // Main price line
          LineChartBarData(
              spots: spots,
              isCurved: false,
              color: AppTheme.lightTheme.primaryColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false)),
          // EMA 9
          if (widget.showEMA)
            LineChartBarData(
                spots: ema9Spots,
                isCurved: true,
                color: AppTheme.secondaryLight,
                barWidth: 1.5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false)),
          // EMA 21
          if (widget.showEMA)
            LineChartBarData(
                spots: ema21Spots,
                isCurved: true,
                color: AppTheme.warningLight,
                barWidth: 1.5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false)),
          // Bollinger Bands
          if (widget.showBollingerBands) ...[
            LineChartBarData(
                spots: upperBandSpots,
                isCurved: true,
                color: AppTheme.lightTheme.colorScheme.outline,
                barWidth: 1,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false)),
            LineChartBarData(
                spots: lowerBandSpots,
                isCurved: true,
                color: AppTheme.lightTheme.colorScheme.outline,
                barWidth: 1,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false)),
          ],
        ],
        lineTouchData: LineTouchData(
            enabled: true,
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
              if (touchResponse != null && touchResponse.lineBarSpots != null) {
                final spot = touchResponse.lineBarSpots!.first;
                final index = spot.x.toInt();
                if (index >= 0 && index < widget.candleData.length) {
                  widget.onCandleTap?.call(widget.candleData[index]);
                }
              }
            },
            touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index >= 0 && index < widget.candleData.length) {
                  final candle = widget.candleData[index];
                  return LineTooltipItem(
                      'O: \$${(candle['open'] as num).toStringAsFixed(2)}\n'
                      'H: \$${(candle['high'] as num).toStringAsFixed(2)}\n'
                      'L: \$${(candle['low'] as num).toStringAsFixed(2)}\n'
                      'C: \$${(candle['close'] as num).toStringAsFixed(2)}\n'
                      'V: ${(candle['volume'] as num).toStringAsFixed(0)}',
                      TextStyle(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500));
                }
                return LineTooltipItem('', const TextStyle());
              }).toList();
            })));
  }

  BarChartData _buildVolumeChart() {
    final volumeBars = <BarChartGroupData>[];

    for (int i = 0; i < widget.candleData.length; i++) {
      final candle = widget.candleData[i];
      final volume = (candle['volume'] as num).toDouble();
      final isGreen = (candle['close'] as num) > (candle['open'] as num);

      volumeBars.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
            toY: volume,
            color: isGreen ? AppTheme.successLight : AppTheme.warningLight,
            width: 2,
            borderRadius: BorderRadius.zero),
      ]));
    }

    return BarChartData(
        barGroups: volumeBars,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 15.w,
                    getTitlesWidget: (value, meta) {
                      return Text('${(value / 1000).toStringAsFixed(0)}K',
                          style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              fontSize: 9.sp));
                    })),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false));
  }

  LineChartData _buildRSIChart() {
    final rsiSpots = <FlSpot>[];

    for (int i = 0; i < widget.candleData.length; i++) {
      final candle = widget.candleData[i];
      final rsi = (candle['rsi'] as num).toDouble();
      rsiSpots.add(FlSpot(i.toDouble(), rsi));
    }

    return LineChartData(
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              Color lineColor = AppTheme.lightTheme.colorScheme.outline
                  .withOpacity(0.3);
              if (value == 70 || value == 30) {
                lineColor =
                    value == 70 ? AppTheme.warningLight : AppTheme.successLight;
              }
              return FlLine(
                  color: lineColor,
                  strokeWidth: value == 70 || value == 30 ? 1 : 0.5,
                  dashArray: value == 70 || value == 30 ? [5, 5] : null);
            }),
        titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 10.w,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString(),
                          style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              fontSize: 9.sp));
                    })),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        borderData: FlBorderData(
            show: true,
            border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.5),
                width: 1)),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
              spots: rsiSpots,
              isCurved: true,
              color: AppTheme.lightTheme.primaryColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                  show: true,
                  color:
                      AppTheme.lightTheme.primaryColor.withOpacity(0.1))),
        ],
        lineTouchData: LineTouchData(enabled: false));
  }

  Widget _buildCrosshair() {
    return Positioned.fill(
        child: CustomPaint(
            painter: CrosshairPainter(
                position: _crosshairPosition!,
                color: AppTheme.lightTheme.primaryColor)));
  }
}

class CrosshairPainter extends CustomPainter {
  final Offset position;
  final Color color;

  CrosshairPainter({required this.position, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical line
    canvas.drawLine(
        Offset(position.dx, 0), Offset(position.dx, size.height), paint);

    // Horizontal line
    canvas.drawLine(
        Offset(0, position.dy), Offset(size.width, position.dy), paint);
  }

  @override
  bool shouldRepaint(CrosshairPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.color != color;
  }
}
