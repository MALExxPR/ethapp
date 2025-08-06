import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportSection extends StatefulWidget {
  final VoidCallback onExportTradingHistory;
  final VoidCallback onGeneratePerformanceReport;

  const ExportSection({
    super.key,
    required this.onExportTradingHistory,
    required this.onGeneratePerformanceReport,
  });

  @override
  State<ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends State<ExportSection> {
  bool _isExportingHistory = false;
  bool _isGeneratingReport = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Exportar Datos',
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: CustomIconWidget(
        iconName: 'download',
        color: AppTheme.lightTheme.primaryColor,
        size: 24,
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              _buildExportOption(
                title: 'Historial de Operaciones',
                subtitle: 'Exportar todas las operaciones en formato CSV',
                icon: 'history',
                isLoading: _isExportingHistory,
                onTap: _exportTradingHistory,
              ),
              SizedBox(height: 2.h),
              _buildExportOption(
                title: 'Reporte de Rendimiento',
                subtitle: 'Generar reporte completo con métricas y gráficos',
                icon: 'assessment',
                isLoading: _isGeneratingReport,
                onTap: _generatePerformanceReport,
              ),
              SizedBox(height: 3.h),
              _buildExportInfo(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportOption({
    required String title,
    required String subtitle,
    required String icon,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.primaryColor,
                  ),
                ),
              )
            : CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
        onTap: isLoading ? null : onTap,
      ),
    );
  }

  Widget _buildExportInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Text(
                'Información de Exportación',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInfoItem(
            'Historial CSV incluye:',
            'Fecha, hora, símbolo, tipo, precio, cantidad, P&L, comisiones',
          ),
          SizedBox(height: 1.h),
          _buildInfoItem(
            'Reporte PDF incluye:',
            'Métricas de rendimiento, gráficos, análisis de riesgo, recomendaciones',
          ),
          SizedBox(height: 1.h),
          _buildInfoItem(
            'Período de datos:',
            'Últimos 12 meses o desde el inicio de la cuenta',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          description,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _exportTradingHistory() async {
    setState(() => _isExportingHistory = true);

    try {
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));

      widget.onExportTradingHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial exportado exitosamente'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al exportar el historial'),
            backgroundColor: AppTheme.warningLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingHistory = false);
      }
    }
  }

  Future<void> _generatePerformanceReport() async {
    setState(() => _isGeneratingReport = true);

    try {
      // Simulate report generation
      await Future.delayed(const Duration(seconds: 3));

      widget.onGeneratePerformanceReport();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte generado exitosamente'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al generar el reporte'),
            backgroundColor: AppTheme.warningLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }
}
