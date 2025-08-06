import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationPreferencesSection extends StatefulWidget {
  final bool pushAlertsEnabled;
  final bool telegramEnabled;
  final String telegramBotToken;
  final double drawdownThreshold;
  final bool equityHighAlerts;
  final Function(bool) onPushAlertsChanged;
  final Function(bool) onTelegramEnabledChanged;
  final Function(String) onTelegramBotTokenChanged;
  final Function(double) onDrawdownThresholdChanged;
  final Function(bool) onEquityHighAlertsChanged;

  const NotificationPreferencesSection({
    super.key,
    required this.pushAlertsEnabled,
    required this.telegramEnabled,
    required this.telegramBotToken,
    required this.drawdownThreshold,
    required this.equityHighAlerts,
    required this.onPushAlertsChanged,
    required this.onTelegramEnabledChanged,
    required this.onTelegramBotTokenChanged,
    required this.onDrawdownThresholdChanged,
    required this.onEquityHighAlertsChanged,
  });

  @override
  State<NotificationPreferencesSection> createState() =>
      _NotificationPreferencesSectionState();
}

class _NotificationPreferencesSectionState
    extends State<NotificationPreferencesSection> {
  final TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tokenController.text = widget.telegramBotToken;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Preferencias de Notificación',
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: CustomIconWidget(
        iconName: 'notifications',
        color: AppTheme.lightTheme.primaryColor,
        size: 24,
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              _buildNotificationToggle(
                title: 'Alertas Push',
                subtitle: 'Notificaciones en el dispositivo',
                value: widget.pushAlertsEnabled,
                onChanged: widget.onPushAlertsChanged,
                icon: 'notifications_active',
              ),
              SizedBox(height: 2.h),
              _buildNotificationToggle(
                title: 'Integración Telegram',
                subtitle: 'Alertas críticas por Telegram',
                value: widget.telegramEnabled,
                onChanged: widget.onTelegramEnabledChanged,
                icon: 'telegram',
                child: widget.telegramEnabled ? _buildTelegramSettings() : null,
              ),
              SizedBox(height: 2.h),
              _buildNotificationToggle(
                title: 'Alertas de Nuevos Máximos',
                subtitle: 'Notificar cuando se alcance nuevo equity alto',
                value: widget.equityHighAlerts,
                onChanged: widget.onEquityHighAlertsChanged,
                icon: 'trending_up',
              ),
              SizedBox(height: 3.h),
              _buildDrawdownThresholdSetting(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required String icon,
    Widget? child,
  }) {
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
                iconName: icon,
                color: value
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
          if (child != null) ...[
            SizedBox(height: 2.h),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildTelegramSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Token del Bot de Telegram',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _tokenController,
          decoration: InputDecoration(
            hintText: 'Ingresa el token de tu bot',
            prefixIcon: CustomIconWidget(
              iconName: 'key',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: CustomIconWidget(
                iconName: 'visibility',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: () {
                // Toggle visibility
              },
            ),
          ),
          obscureText: true,
          onChanged: widget.onTelegramBotTokenChanged,
        ),
        SizedBox(height: 1.h),
        Text(
          'Obtén tu token creando un bot con @BotFather en Telegram',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawdownThresholdSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Umbral de Alerta de Pérdida',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.drawdownThreshold.toStringAsFixed(1)}%',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warningLight,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Recibir alerta cuando las pérdidas superen este porcentaje',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.warningLight,
            inactiveTrackColor: AppTheme.warningLight.withOpacity(0.2),
            thumbColor: AppTheme.warningLight,
            overlayColor: AppTheme.warningLight.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: widget.drawdownThreshold,
            min: 1.0,
            max: 10.0,
            divisions: 18,
            onChanged: widget.onDrawdownThresholdChanged,
          ),
        ),
      ],
    );
  }
}
