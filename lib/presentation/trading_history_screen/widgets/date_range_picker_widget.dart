import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DateRangePickerWidget extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final Function(DateTimeRange?) onRangeChanged;

  const DateRangePickerWidget({
    Key? key,
    required this.selectedRange,
    required this.onRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showDateRangePicker(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'date_range',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        selectedRange != null
                            ? '${_formatDate(selectedRange!.start)} - ${_formatDate(selectedRange!.end)}'
                            : 'Seleccionar rango de fechas',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: selectedRange != null
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (selectedRange != null) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () => onRangeChanged(null),
              child: Container(
                padding: EdgeInsets.all(1.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2019, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onRangeChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
