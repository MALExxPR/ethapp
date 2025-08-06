import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class IndicatorSettingsWidget extends StatefulWidget {
  final bool showEMA;
  final bool showRSI;
  final bool showBollingerBands;
  final int ema9Period;
  final int ema21Period;
  final int rsiPeriod;
  final int bollingerPeriod;
  final double bollingerStdDev;
  final Function(bool) onEMAToggle;
  final Function(bool) onRSIToggle;
  final Function(bool) onBollingerToggle;
  final Function(int) onEMA9PeriodChanged;
  final Function(int) onEMA21PeriodChanged;
  final Function(int) onRSIPeriodChanged;
  final Function(int) onBollingerPeriodChanged;
  final Function(double) onBollingerStdDevChanged;

  const IndicatorSettingsWidget({
    Key? key,
    required this.showEMA,
    required this.showRSI,
    required this.showBollingerBands,
    required this.ema9Period,
    required this.ema21Period,
    required this.rsiPeriod,
    required this.bollingerPeriod,
    required this.bollingerStdDev,
    required this.onEMAToggle,
    required this.onRSIToggle,
    required this.onBollingerToggle,
    required this.onEMA9PeriodChanged,
    required this.onEMA21PeriodChanged,
    required this.onRSIPeriodChanged,
    required this.onBollingerPeriodChanged,
    required this.onBollingerStdDevChanged,
  }) : super(key: key);

  @override
  State<IndicatorSettingsWidget> createState() =>
      _IndicatorSettingsWidgetState();
}

class _IndicatorSettingsWidgetState extends State<IndicatorSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 15.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            'Configuración de Indicadores',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  // EMA Settings
                  _buildIndicatorSection(
                    title: 'Medias Móviles Exponenciales (EMA)',
                    isEnabled: widget.showEMA,
                    onToggle: widget.onEMAToggle,
                    children: [
                      _buildSliderSetting(
                        label: 'EMA 9 Período',
                        value: widget.ema9Period.toDouble(),
                        min: 5,
                        max: 50,
                        divisions: 45,
                        onChanged: (value) =>
                            widget.onEMA9PeriodChanged(value.toInt()),
                      ),
                      _buildSliderSetting(
                        label: 'EMA 21 Período',
                        value: widget.ema21Period.toDouble(),
                        min: 10,
                        max: 100,
                        divisions: 90,
                        onChanged: (value) =>
                            widget.onEMA21PeriodChanged(value.toInt()),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // RSI Settings
                  _buildIndicatorSection(
                    title: 'Índice de Fuerza Relativa (RSI)',
                    isEnabled: widget.showRSI,
                    onToggle: widget.onRSIToggle,
                    children: [
                      _buildSliderSetting(
                        label: 'RSI Período',
                        value: widget.rsiPeriod.toDouble(),
                        min: 5,
                        max: 50,
                        divisions: 45,
                        onChanged: (value) =>
                            widget.onRSIPeriodChanged(value.toInt()),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Bollinger Bands Settings
                  _buildIndicatorSection(
                    title: 'Bandas de Bollinger',
                    isEnabled: widget.showBollingerBands,
                    onToggle: widget.onBollingerToggle,
                    children: [
                      _buildSliderSetting(
                        label: 'Período',
                        value: widget.bollingerPeriod.toDouble(),
                        min: 10,
                        max: 50,
                        divisions: 40,
                        onChanged: (value) =>
                            widget.onBollingerPeriodChanged(value.toInt()),
                      ),
                      _buildSliderSetting(
                        label: 'Desviación Estándar',
                        value: widget.bollingerStdDev,
                        min: 1.0,
                        max: 3.0,
                        divisions: 20,
                        onChanged: widget.onBollingerStdDevChanged,
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorSection({
    required String title,
    required bool isEnabled,
    required Function(bool) onToggle,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: AppTheme.lightTheme.primaryColor,
              ),
            ],
          ),
          if (isEnabled) ...[
            SizedBox(height: 2.h),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value % 1 == 0
                    ? value.toInt().toString()
                    : value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.lightTheme.primaryColor,
            inactiveTrackColor:
                AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
            thumbColor: AppTheme.lightTheme.primaryColor,
            overlayColor:
                AppTheme.lightTheme.primaryColor.withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }
}
