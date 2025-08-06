import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaperTradingSection extends StatefulWidget {
  final bool isPaperTradingEnabled;
  final Function(bool) onPaperTradingChanged;
  final VoidCallback onActivateLiveTrading;

  const PaperTradingSection({
    super.key,
    required this.isPaperTradingEnabled,
    required this.onPaperTradingChanged,
    required this.onActivateLiveTrading,
  });

  @override
  State<PaperTradingSection> createState() => _PaperTradingSectionState();
}

class _PaperTradingSectionState extends State<PaperTradingSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: widget.isPaperTradingEnabled
            ? AppTheme.lightTheme.primaryColor.withOpacity(0.1)
            : AppTheme.warningLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isPaperTradingEnabled
              ? AppTheme.lightTheme.primaryColor.withOpacity(0.3)
              : AppTheme.warningLight.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: widget.isPaperTradingEnabled
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: widget.isPaperTradingEnabled ? 'school' : 'warning',
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isPaperTradingEnabled
                          ? 'Modo Simulación Activo'
                          : 'Trading en Vivo Activo',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.isPaperTradingEnabled
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.warningLight,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      widget.isPaperTradingEnabled
                          ? 'Practica sin riesgo real'
                          : 'Operando con dinero real',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.isPaperTradingEnabled,
                onChanged: (value) {
                  if (!value) {
                    _showLiveTradingConfirmation();
                  } else {
                    widget.onPaperTradingChanged(value);
                  }
                },
                activeColor: AppTheme.lightTheme.primaryColor,
                inactiveThumbColor: AppTheme.warningLight,
                inactiveTrackColor:
                    AppTheme.warningLight.withOpacity(0.3),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildTradingModeInfo(),
          if (!widget.isPaperTradingEnabled) ...[
            SizedBox(height: 3.h),
            _buildLiveTradingWarning(),
          ],
        ],
      ),
    );
  }

  Widget _buildTradingModeInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  widget.isPaperTradingEnabled
                      ? 'Información del Modo Simulación'
                      : 'Información del Trading en Vivo',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...widget.isPaperTradingEnabled
              ? _buildPaperTradingFeatures()
              : _buildLiveTradingFeatures(),
        ],
      ),
    );
  }

  List<Widget> _buildPaperTradingFeatures() {
    final features = [
      'Balance virtual de \$10,000 USD',
      'Todas las funciones del bot disponibles',
      'Datos de mercado en tiempo real',
      'Sin riesgo financiero real',
      'Ideal para aprender y probar estrategias',
    ];

    return features
        .map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.successLight,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> _buildLiveTradingFeatures() {
    final features = [
      'Operaciones con dinero real',
      'Conexión directa a BingX',
      'Todas las medidas de seguridad activas',
      'Monitoreo de riesgo en tiempo real',
      'Requiere fondos suficientes en la cuenta',
    ];

    return features
        .map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.warningLight,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildLiveTradingWarning() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.warningLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningLight.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.warningLight,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  '¡ADVERTENCIA!',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'El trading en vivo implica riesgo real de pérdida de capital. Asegúrate de entender completamente los riesgos antes de activar este modo.',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showLiveTradingConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.warningLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              const Text('Activar Trading en Vivo'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que quieres activar el trading en vivo?',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Esto significa que:',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '• Se utilizará dinero real de tu cuenta\n'
                '• Existe riesgo de pérdida de capital\n'
                '• Todas las operaciones serán ejecutadas\n'
                '• Los límites de riesgo deben estar configurados',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onPaperTradingChanged(false);
                widget.onActivateLiveTrading();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningLight,
              ),
              child: const Text('Activar Trading en Vivo'),
            ),
          ],
        );
      },
    );
  }
}
