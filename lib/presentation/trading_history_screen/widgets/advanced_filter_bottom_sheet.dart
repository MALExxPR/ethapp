import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedFilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const AdvancedFilterBottomSheet({
    Key? key,
    required this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<AdvancedFilterBottomSheet> createState() =>
      _AdvancedFilterBottomSheetState();
}

class _AdvancedFilterBottomSheetState extends State<AdvancedFilterBottomSheet> {
  late Map<String, dynamic> _filters;
  late RangeValues _profitRange;
  late RangeValues _durationRange;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _profitRange = RangeValues(
      (_filters['minProfit'] as num?)?.toDouble() ?? -1000.0,
      (_filters['maxProfit'] as num?)?.toDouble() ?? 1000.0,
    );
    _durationRange = RangeValues(
      (_filters['minDuration'] as num?)?.toDouble() ?? 0.0,
      (_filters['maxDuration'] as num?)?.toDouble() ?? 360.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros Avanzados',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Rango de Ganancias/Pérdidas'),
                  SizedBox(height: 2.h),
                  _buildProfitRangeSlider(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Duración del Trade (minutos)'),
                  SizedBox(height: 2.h),
                  _buildDurationRangeSlider(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Indicadores Técnicos'),
                  SizedBox(height: 2.h),
                  _buildTechnicalIndicatorFilters(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Señales de Trading'),
                  SizedBox(height: 2.h),
                  _buildSignalFilters(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    child: Text('Limpiar'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text('Aplicar Filtros'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildProfitRangeSlider() {
    return Column(
      children: [
        RangeSlider(
          values: _profitRange,
          min: -1000.0,
          max: 1000.0,
          divisions: 100,
          labels: RangeLabels(
            '\$${_profitRange.start.toStringAsFixed(0)}',
            '\$${_profitRange.end.toStringAsFixed(0)}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _profitRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mín: \$${_profitRange.start.toStringAsFixed(0)}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Text(
              'Máx: \$${_profitRange.end.toStringAsFixed(0)}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationRangeSlider() {
    return Column(
      children: [
        RangeSlider(
          values: _durationRange,
          min: 0.0,
          max: 360.0,
          divisions: 72,
          labels: RangeLabels(
            '${_durationRange.start.toStringAsFixed(0)}m',
            '${_durationRange.end.toStringAsFixed(0)}m',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _durationRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mín: ${_durationRange.start.toStringAsFixed(0)}m',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Text(
              'Máx: ${_durationRange.end.toStringAsFixed(0)}m',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicalIndicatorFilters() {
    final List<String> indicators = [
      'EMA 9/21',
      'RSI 14',
      'Bollinger Bands',
      'MACD',
      'Stochastic'
    ];
    final List<String> selectedIndicators =
        (_filters['indicators'] as List<String>?) ?? [];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: indicators.map((indicator) {
        final bool isSelected = selectedIndicators.contains(indicator);
        return FilterChip(
          label: Text(indicator),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedIndicators.add(indicator);
              } else {
                selectedIndicators.remove(indicator);
              }
              _filters['indicators'] = selectedIndicators;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSignalFilters() {
    final List<String> signals = [
      'EMA Cross',
      'RSI Oversold',
      'RSI Overbought',
      'BB Squeeze',
      'MACD Signal'
    ];
    final List<String> selectedSignals =
        (_filters['signals'] as List<String>?) ?? [];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: signals.map((signal) {
        final bool isSelected = selectedSignals.contains(signal);
        return FilterChip(
          label: Text(signal),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedSignals.add(signal);
              } else {
                selectedSignals.remove(signal);
              }
              _filters['signals'] = selectedSignals;
            });
          },
        );
      }).toList(),
    );
  }

  void _resetFilters() {
    setState(() {
      _filters.clear();
      _profitRange = const RangeValues(-1000.0, 1000.0);
      _durationRange = const RangeValues(0.0, 360.0);
    });
  }

  void _applyFilters() {
    _filters['minProfit'] = _profitRange.start;
    _filters['maxProfit'] = _profitRange.end;
    _filters['minDuration'] = _durationRange.start;
    _filters['maxDuration'] = _durationRange.end;

    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }
}
