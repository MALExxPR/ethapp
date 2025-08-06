import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class RiskCalculatorWidget extends StatefulWidget {
  const RiskCalculatorWidget({Key? key}) : super(key: key);

  @override
  State<RiskCalculatorWidget> createState() => _RiskCalculatorWidgetState();
}

class _RiskCalculatorWidgetState extends State<RiskCalculatorWidget> {
  double _tradeAmount = 1000.0;
  double _stopLossDistance = 2.0;
  double _portfolioValue = 10000.0;

  double get _riskAmount => (_tradeAmount * _stopLossDistance) / 100;
  double get _riskPercentage => (_riskAmount / _portfolioValue) * 100;

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
                iconName: 'calculate',
                color: AppTheme.lightTheme.primaryColor,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Calculadora de Riesgo',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSliderSection(
            title: 'Monto de Operación',
            value: _tradeAmount,
            min: 100.0,
            max: 5000.0,
            divisions: 49,
            suffix: ' USDT',
            onChanged: (value) {
              setState(() {
                _tradeAmount = value;
              });
            },
          ),
          SizedBox(height: 3.h),
          _buildSliderSection(
            title: 'Distancia Stop Loss',
            value: _stopLossDistance,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            suffix: '%',
            onChanged: (value) {
              setState(() {
                _stopLossDistance = value;
              });
            },
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: _riskPercentage > 2.0
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.tertiary,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riesgo Calculado:',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${_riskAmount.toStringAsFixed(2)}',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: _riskPercentage > 2.0
                            ? AppTheme.lightTheme.colorScheme.error
                            : AppTheme.lightTheme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Porcentaje del Portfolio:',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_riskPercentage.toStringAsFixed(2)}%',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: _riskPercentage > 2.0
                            ? AppTheme.lightTheme.colorScheme.error
                            : AppTheme.lightTheme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_riskPercentage > 2.0) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'warning',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          'Riesgo alto: Excede el límite recomendado del 2%',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(value < 10 ? 1 : 0)}$suffix',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.lightTheme.primaryColor,
            thumbColor: AppTheme.lightTheme.primaryColor,
            overlayColor:
                AppTheme.lightTheme.primaryColor.withOpacity(0.2),
            inactiveTrackColor: AppTheme.borderLight,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
