import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChartToolsWidget extends StatelessWidget {
  final VoidCallback? onDrawingTool;
  final VoidCallback? onSupportResistance;
  final VoidCallback? onScreenshot;
  final VoidCallback? onFullscreen;

  const ChartToolsWidget({
    Key? key,
    this.onDrawingTool,
    this.onSupportResistance,
    this.onScreenshot,
    this.onFullscreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 2.h,
      right: 2.w,
      child: Column(
        children: [
          _buildToolButton(
            icon: 'edit',
            tooltip: 'Herramientas de Dibujo',
            onTap: onDrawingTool,
          ),
          SizedBox(height: 1.h),
          _buildToolButton(
            icon: 'horizontal_rule',
            tooltip: 'Soporte/Resistencia',
            onTap: onSupportResistance,
          ),
          SizedBox(height: 1.h),
          _buildToolButton(
            icon: 'camera_alt',
            tooltip: 'Captura de Pantalla',
            onTap: onScreenshot,
          ),
          SizedBox(height: 1.h),
          _buildToolButton(
            icon: 'fullscreen',
            tooltip: 'Pantalla Completa',
            onTap: onFullscreen,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required String icon,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
