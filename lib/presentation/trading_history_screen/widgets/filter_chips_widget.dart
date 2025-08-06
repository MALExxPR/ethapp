import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterChipsWidget extends StatelessWidget {
  final String selectedTradeType;
  final String selectedOutcome;
  final String selectedMode;
  final Function(String) onTradeTypeChanged;
  final Function(String) onOutcomeChanged;
  final Function(String) onModeChanged;

  const FilterChipsWidget({
    Key? key,
    required this.selectedTradeType,
    required this.selectedOutcome,
    required this.selectedMode,
    required this.onTradeTypeChanged,
    required this.onOutcomeChanged,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            _buildFilterChipGroup(
              'Tipo',
              ['TODOS', 'BUY', 'SELL'],
              selectedTradeType,
              onTradeTypeChanged,
            ),
            SizedBox(width: 4.w),
            _buildFilterChipGroup(
              'Resultado',
              ['TODOS', 'GANANCIA', 'PÉRDIDA'],
              selectedOutcome,
              onOutcomeChanged,
            ),
            SizedBox(width: 4.w),
            _buildFilterChipGroup(
              'Modo',
              ['TODOS', 'LIVE', 'PAPER'],
              selectedMode,
              onModeChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipGroup(
    String label,
    List<String> options,
    String selected,
    Function(String) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 2.w),
        ...options
            .map((option) => Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: FilterChip(
                    label: Text(
                      option,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: selected == option
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: selected == option,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        onChanged(option);
                      }
                    },
                    backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                    selectedColor: AppTheme.lightTheme.colorScheme.primary,
                    checkmarkColor: AppTheme.lightTheme.colorScheme.onPrimary,
                    side: BorderSide(
                      color: selected == option
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: 1,
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
