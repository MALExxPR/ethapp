import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/api_configuration_section.dart';
import './widgets/export_section.dart';
import './widgets/notification_preferences_section.dart';
import './widgets/paper_trading_section.dart';
import './widgets/risk_management_section.dart';
import './widgets/technical_indicators_section.dart';
import './widgets/trading_execution_section.dart';

class TradingSettingsScreen extends StatefulWidget {
  const TradingSettingsScreen({super.key});

  @override
  State<TradingSettingsScreen> createState() => _TradingSettingsScreenState();
}

class _TradingSettingsScreenState extends State<TradingSettingsScreen> {
  // Risk Management Settings
  double _riskPerTrade = 0.5;
  double _maxDailyDrawdown = 5.0;
  double _positionHoldTime = 6.0;

  // Technical Indicators Settings
  bool _emaEnabled = true;
  int _emaPeriod1 = 9;
  int _emaPeriod2 = 21;
  bool _rsiEnabled = true;
  int _rsiPeriod = 14;
  bool _bollingerBandsEnabled = true;

  // Trading Execution Settings
  double _stopLossMultiplier = 1.5;
  double _takeProfitRatio = 3.0;
  String _orderType = 'market';

  // Notification Settings
  bool _pushAlertsEnabled = true;
  bool _telegramEnabled = false;
  String _telegramBotToken = '';
  double _drawdownThreshold = 3.0;
  bool _equityHighAlerts = true;

  // API Configuration
  String _apiKey = 'bx_demo_key_123456789';
  String _secretKey = 'bx_demo_secret_987654321';
  int _rateLimitCalls = 60;

  // Paper Trading
  bool _isPaperTradingEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              PaperTradingSection(
                isPaperTradingEnabled: _isPaperTradingEnabled,
                onPaperTradingChanged: (value) {
                  setState(() => _isPaperTradingEnabled = value);
                  _saveSettings();
                },
                onActivateLiveTrading: _onActivateLiveTrading,
              ),
              SizedBox(height: 2.h),
              RiskManagementSection(
                riskPerTrade: _riskPerTrade,
                maxDailyDrawdown: _maxDailyDrawdown,
                positionHoldTime: _positionHoldTime,
                onRiskPerTradeChanged: (value) {
                  setState(() => _riskPerTrade = value);
                  _saveSettings();
                },
                onMaxDailyDrawdownChanged: (value) {
                  setState(() => _maxDailyDrawdown = value);
                  _saveSettings();
                },
                onPositionHoldTimeChanged: (value) {
                  setState(() => _positionHoldTime = value);
                  _saveSettings();
                },
              ),
              TechnicalIndicatorsSection(
                emaEnabled: _emaEnabled,
                emaPeriod1: _emaPeriod1,
                emaPeriod2: _emaPeriod2,
                rsiEnabled: _rsiEnabled,
                rsiPeriod: _rsiPeriod,
                bollingerBandsEnabled: _bollingerBandsEnabled,
                onEmaEnabledChanged: (value) {
                  setState(() => _emaEnabled = value);
                  _saveSettings();
                },
                onEmaPeriod1Changed: (value) {
                  setState(() => _emaPeriod1 = value);
                  _saveSettings();
                },
                onEmaPeriod2Changed: (value) {
                  setState(() => _emaPeriod2 = value);
                  _saveSettings();
                },
                onRsiEnabledChanged: (value) {
                  setState(() => _rsiEnabled = value);
                  _saveSettings();
                },
                onRsiPeriodChanged: (value) {
                  setState(() => _rsiPeriod = value);
                  _saveSettings();
                },
                onBollingerBandsEnabledChanged: (value) {
                  setState(() => _bollingerBandsEnabled = value);
                  _saveSettings();
                },
              ),
              TradingExecutionSection(
                stopLossMultiplier: _stopLossMultiplier,
                takeProfitRatio: _takeProfitRatio,
                orderType: _orderType,
                onStopLossMultiplierChanged: (value) {
                  setState(() => _stopLossMultiplier = value);
                  _saveSettings();
                },
                onTakeProfitRatioChanged: (value) {
                  setState(() => _takeProfitRatio = value);
                  _saveSettings();
                },
                onOrderTypeChanged: (value) {
                  setState(() => _orderType = value);
                  _saveSettings();
                },
              ),
              NotificationPreferencesSection(
                pushAlertsEnabled: _pushAlertsEnabled,
                telegramEnabled: _telegramEnabled,
                telegramBotToken: _telegramBotToken,
                drawdownThreshold: _drawdownThreshold,
                equityHighAlerts: _equityHighAlerts,
                onPushAlertsChanged: (value) {
                  setState(() => _pushAlertsEnabled = value);
                  _saveSettings();
                },
                onTelegramEnabledChanged: (value) {
                  setState(() => _telegramEnabled = value);
                  _saveSettings();
                },
                onTelegramBotTokenChanged: (value) {
                  setState(() => _telegramBotToken = value);
                  _saveSettings();
                },
                onDrawdownThresholdChanged: (value) {
                  setState(() => _drawdownThreshold = value);
                  _saveSettings();
                },
                onEquityHighAlertsChanged: (value) {
                  setState(() => _equityHighAlerts = value);
                  _saveSettings();
                },
              ),
              ApiConfigurationSection(
                apiKey: _apiKey,
                secretKey: _secretKey,
                rateLimitCalls: _rateLimitCalls,
                onApiKeyChanged: (value) {
                  setState(() => _apiKey = value);
                  _saveSettings();
                },
                onSecretKeyChanged: (value) {
                  setState(() => _secretKey = value);
                  _saveSettings();
                },
                onRateLimitChanged: (value) {
                  setState(() => _rateLimitCalls = value);
                  _saveSettings();
                },
                onTestConnection: _onTestConnection,
                onUpdateCredentials: _onUpdateCredentials,
              ),
              ExportSection(
                onExportTradingHistory: _onExportTradingHistory,
                onGeneratePerformanceReport: _onGeneratePerformanceReport,
              ),
              SizedBox(height: 3.h),
              _buildResetButton(),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Configuración de Trading',
        style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
      ),
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'help_outline',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 24,
          ),
          onPressed: _showHelpDialog,
        ),
      ],
      elevation: AppTheme.lightTheme.appBarTheme.elevation,
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
    );
  }

  Widget _buildResetButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showResetConfirmation,
        icon: CustomIconWidget(
          iconName: 'restore',
          color: AppTheme.warningLight,
          size: 20,
        ),
        label: const Text('Restablecer a Valores por Defecto'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.warningLight,
          side: const BorderSide(color: AppTheme.warningLight),
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
      ),
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Load API Configuration (most important for this fix)
      _apiKey = prefs.getString('api_key') ?? 'bx_demo_key_123456789';
      _secretKey = prefs.getString('secret_key') ?? 'bx_demo_secret_987654321';
      _rateLimitCalls = prefs.getInt('rate_limit_calls') ?? 60;

      // Load Risk Management Settings
      _riskPerTrade = prefs.getDouble('risk_per_trade') ?? 0.5;
      _maxDailyDrawdown = prefs.getDouble('max_daily_drawdown') ?? 5.0;
      _positionHoldTime = prefs.getDouble('position_hold_time') ?? 6.0;

      // Load Technical Indicators Settings
      _emaEnabled = prefs.getBool('ema_enabled') ?? true;
      _emaPeriod1 = prefs.getInt('ema_period_1') ?? 9;
      _emaPeriod2 = prefs.getInt('ema_period_2') ?? 21;
      _rsiEnabled = prefs.getBool('rsi_enabled') ?? true;
      _rsiPeriod = prefs.getInt('rsi_period') ?? 14;
      _bollingerBandsEnabled = prefs.getBool('bollinger_bands_enabled') ?? true;

      // Load Trading Execution Settings
      _stopLossMultiplier = prefs.getDouble('stop_loss_multiplier') ?? 1.5;
      _takeProfitRatio = prefs.getDouble('take_profit_ratio') ?? 3.0;
      _orderType = prefs.getString('order_type') ?? 'market';

      // Load Notification Settings
      _pushAlertsEnabled = prefs.getBool('push_alerts_enabled') ?? true;
      _telegramEnabled = prefs.getBool('telegram_enabled') ?? false;
      _telegramBotToken = prefs.getString('telegram_bot_token') ?? '';
      _drawdownThreshold = prefs.getDouble('drawdown_threshold') ?? 3.0;
      _equityHighAlerts = prefs.getBool('equity_high_alerts') ?? true;

      // Load Paper Trading
      _isPaperTradingEnabled = prefs.getBool('paper_trading_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save API Configuration (most critical)
      await prefs.setString('api_key', _apiKey);
      await prefs.setString('secret_key', _secretKey);
      await prefs.setInt('rate_limit_calls', _rateLimitCalls);

      // Save Risk Management Settings
      await prefs.setDouble('risk_per_trade', _riskPerTrade);
      await prefs.setDouble('max_daily_drawdown', _maxDailyDrawdown);
      await prefs.setDouble('position_hold_time', _positionHoldTime);

      // Save Technical Indicators Settings
      await prefs.setBool('ema_enabled', _emaEnabled);
      await prefs.setInt('ema_period_1', _emaPeriod1);
      await prefs.setInt('ema_period_2', _emaPeriod2);
      await prefs.setBool('rsi_enabled', _rsiEnabled);
      await prefs.setInt('rsi_period', _rsiPeriod);
      await prefs.setBool('bollinger_bands_enabled', _bollingerBandsEnabled);

      // Save Trading Execution Settings
      await prefs.setDouble('stop_loss_multiplier', _stopLossMultiplier);
      await prefs.setDouble('take_profit_ratio', _takeProfitRatio);
      await prefs.setString('order_type', _orderType);

      // Save Notification Settings
      await prefs.setBool('push_alerts_enabled', _pushAlertsEnabled);
      await prefs.setBool('telegram_enabled', _telegramEnabled);
      await prefs.setString('telegram_bot_token', _telegramBotToken);
      await prefs.setDouble('drawdown_threshold', _drawdownThreshold);
      await prefs.setBool('equity_high_alerts', _equityHighAlerts);

      // Save Paper Trading
      await prefs.setBool('paper_trading_enabled', _isPaperTradingEnabled);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                const Text('Configuración guardada exitosamente'),
              ],
            ),
            duration: const Duration(milliseconds: 1500),
            backgroundColor: AppTheme.successLight,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: 10.h,
              left: 4.w,
              right: 4.w,
            ),
          ),
        );
      }
    } catch (e) {
      // Handle save error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                const Text('Error al guardar configuración'),
              ],
            ),
            backgroundColor: AppTheme.warningLight,
          ),
        );
      }
    }
  }

  void _onActivateLiveTrading() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trading en vivo activado. ¡Ten cuidado!'),
        backgroundColor: AppTheme.warningLight,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onTestConnection() {
    // Connection test handled in ApiConfigurationSection
  }

  void _onUpdateCredentials() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Credenciales actualizadas exitosamente'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _onExportTradingHistory() {
    // Export handled in ExportSection
  }

  void _onGeneratePerformanceReport() {
    // Report generation handled in ExportSection
  }

  void _showResetConfirmation() {
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
              const Text('Restablecer Configuración'),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que quieres restablecer toda la configuración a los valores por defecto? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetToDefaults();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningLight,
              ),
              child: const Text('Restablecer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetToDefaults() async {
    setState(() {
      // Risk Management
      _riskPerTrade = 0.5;
      _maxDailyDrawdown = 5.0;
      _positionHoldTime = 6.0;

      // Technical Indicators
      _emaEnabled = true;
      _emaPeriod1 = 9;
      _emaPeriod2 = 21;
      _rsiEnabled = true;
      _rsiPeriod = 14;
      _bollingerBandsEnabled = true;

      // Trading Execution
      _stopLossMultiplier = 1.5;
      _takeProfitRatio = 3.0;
      _orderType = 'market';

      // Notifications
      _pushAlertsEnabled = true;
      _telegramEnabled = false;
      _telegramBotToken = '';
      _drawdownThreshold = 3.0;
      _equityHighAlerts = true;

      // API Configuration
      _apiKey = 'bx_demo_key_123456789';
      _secretKey = 'bx_demo_secret_987654321';
      _rateLimitCalls = 60;

      // Paper Trading
      _isPaperTradingEnabled = true;
    });

    // Save default settings to persistence
    await _saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración restablecida a valores por defecto'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'help',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 3.w),
              const Text('Ayuda'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Configuración del Bot de Trading ETH',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                const Text(
                  '• Gestión de Riesgo: Controla el riesgo por operación y límites de pérdida\n'
                  '• Indicadores Técnicos: Configura EMA, RSI y Bandas de Bollinger\n'
                  '• Ejecución: Ajusta stop loss, take profit y tipo de órdenes\n'
                  '• Notificaciones: Configura alertas push y Telegram\n'
                  '• API: Conecta con tu cuenta de BingX\n'
                  '• Modo Simulación: Practica sin riesgo real',
                ),
                SizedBox(height: 2.h),
                Text(
                  'Para más información, visita nuestra documentación.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
