import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/alert_history_widget.dart';
import './widgets/current_positions_widget.dart';
import './widgets/emergency_stop_button_widget.dart';
import './widgets/risk_analytics_cards_widget.dart';
import './widgets/risk_calculator_widget.dart';
import './widgets/risk_guard_system_widget.dart';
import './widgets/risk_status_gauge_widget.dart';

class RiskManagementScreen extends StatefulWidget {
  const RiskManagementScreen({Key? key}) : super(key: key);

  @override
  State<RiskManagementScreen> createState() => _RiskManagementScreenState();
}

class _RiskManagementScreenState extends State<RiskManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isTrading = true;

  // Mock data for risk management
  final Map<String, dynamic> _riskData = {
    'currentRiskPercentage': 35.7,
    'riskLevel': 'Medio',
    'isTrading': true,
  };

  final List<Map<String, dynamic>> _currentPositions = [
    {
      'symbol': 'ETH-USDT',
      'side': 'BUY',
      'quantity': 0.5432,
      'entryPrice': 2456.78,
      'unrealizedPnl': 45.67,
      'timeRemaining': '4h 23m',
      'riskPercentage': 1.2,
    },
    {
      'symbol': 'ETH-USDT',
      'side': 'SELL',
      'quantity': 0.2156,
      'entryPrice': 2478.90,
      'unrealizedPnl': -12.34,
      'timeRemaining': '2h 45m',
      'riskPercentage': 0.8,
    },
  ];

  final Map<String, dynamic> _riskMetrics = {
    'maxDrawdownToday': 2.34,
    'drawdownTrend': 'down',
    'consecutiveLosses': 1,
    'lossesTrend': 'neutral',
    'volatility': 15.6,
    'volatilityTrend': 'up',
    'sharpeRatio': 1.45,
    'sharpeTrend': 'up',
  };

  final List<Map<String, dynamic>> _alertHistory = [
    {
      'id': 1,
      'title': 'Drawdown Alto Detectado',
      'description':
          'El drawdown diario ha alcanzado el 3.2%, acercándose al límite del 5%. Se recomienda revisar las posiciones actuales.',
      'type': 'drawdown',
      'severity': 'medium',
      'timestamp': '06/08/2025 14:23',
      'actionTaken': 'Notificación enviada',
    },
    {
      'id': 2,
      'title': 'Pérdida Consecutiva',
      'description':
          'Segunda operación perdedora consecutiva detectada. El sistema está monitoreando para activar protecciones.',
      'type': 'loss',
      'severity': 'low',
      'timestamp': '06/08/2025 13:45',
      'actionTaken': 'Monitoreo activado',
    },
    {
      'id': 3,
      'title': 'Volatilidad Extrema',
      'description':
          'Volatilidad del mercado ETH-USDT ha superado el 20%. Trading suspendido temporalmente por seguridad.',
      'type': 'volatility',
      'severity': 'high',
      'timestamp': '06/08/2025 12:15',
      'actionTaken': 'Trading suspendido',
    },
  ];

  Map<String, bool> _guardSettings = {
    'dailyLossLimit': true,
    'consecutiveLosses': true,
    'highVolatility': false,
    'maxExposure': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isTrading = _riskData['isTrading'] as bool;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleEmergencyStop() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isTrading = false;
      _riskData['isTrading'] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          CustomIconWidget(
              iconName: 'check_circle', color: Colors.white, size: 5.w),
          SizedBox(width: 2.w),
          Text('Trading detenido exitosamente'),
        ]),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating));
  }

  void _handleGuardToggle(String key, bool value) {
    // Simulate biometric confirmation
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Row(children: [
                CustomIconWidget(
                    iconName: 'fingerprint',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 6.w),
                SizedBox(width: 2.w),
                Text('Confirmación Biométrica'),
              ]),
              content: Text(
                  'Confirme el cambio en la configuración de protección usando su huella dactilar o Face ID.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _guardSettings[key] = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Configuración actualizada'),
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.tertiary,
                          behavior: SnackBarBehavior.floating));
                    },
                    child: Text('Confirmar')),
              ]);
        });
  }

  void _showAdvancedSettings() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                  decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(5.w))),
                  child: Column(children: [
                    Container(
                        margin: EdgeInsets.only(top: 2.h),
                        width: 12.w,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                            color: AppTheme.borderLight,
                            borderRadius: BorderRadius.circular(1.w))),
                    Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Row(children: [
                          CustomIconWidget(
                              iconName: 'settings',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 6.w),
                          SizedBox(width: 2.w),
                          Text('Configuración Avanzada',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ])),
                    Expanded(
                        child: SingleChildScrollView(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Column(children: [
                              RiskGuardSystemWidget(
                                  guardSettings: _guardSettings,
                                  onGuardToggle: _handleGuardToggle),
                              SizedBox(height: 3.h),
                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(3.w),
                                      boxShadow: [
                                        BoxShadow(
                                            color: AppTheme.shadowLight,
                                            blurRadius: 8,
                                            offset: const Offset(0, 2)),
                                      ]),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          CustomIconWidget(
                                              iconName: 'notifications',
                                              color: AppTheme
                                                  .lightTheme.primaryColor,
                                              size: 5.w),
                                          SizedBox(width: 2.w),
                                          Text('Preferencias de Notificación',
                                              style: AppTheme.lightTheme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                        ]),
                                        SizedBox(height: 3.h),
                                        _buildNotificationToggle(
                                            'Alertas Push',
                                            'Recibir notificaciones inmediatas en el dispositivo',
                                            true),
                                        SizedBox(height: 2.h),
                                        _buildNotificationToggle(
                                            'Integración Telegram',
                                            'Alertas críticas enviadas a Telegram',
                                            true),
                                        SizedBox(height: 2.h),
                                        _buildNotificationToggle(
                                            'Alertas por Email',
                                            'Resumen diario de riesgos por correo',
                                            false),
                                      ])),
                              SizedBox(height: 5.h),
                            ]))),
                  ]));
            }));
  }

  Widget _buildNotificationToggle(String title, String subtitle, bool value) {
    return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(2.w)),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: AppTheme.lightTheme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 0.5.h),
                Text(subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.textSecondaryLight)),
              ])),
          Switch(
              value: value,
              onChanged: (newValue) {
                // Handle notification toggle
              },
              activeColor: AppTheme.lightTheme.colorScheme.tertiary),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            elevation: 2,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(iconName: 'arrow_back', size: 6.w)),
            title: Text('Gestión de Riesgos',
                style: AppTheme.lightTheme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            actions: [
              EmergencyStopButtonWidget(
                  onEmergencyStop: _handleEmergencyStop, isTrading: _isTrading),
              SizedBox(width: 4.w),
            ],
            bottom: TabBar(controller: _tabController, tabs: [
              Tab(
                  icon: CustomIconWidget(
                      iconName: 'dashboard',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 5.w),
                  text: 'Monitor'),
              Tab(
                  icon: CustomIconWidget(
                      iconName: 'calculate',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 5.w),
                  text: 'Calculadora'),
              Tab(
                  icon: CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 5.w),
                  text: 'Historial'),
            ])),
        body: TabBarView(controller: _tabController, children: [
          // Monitor Tab
          SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(children: [
                RiskStatusGaugeWidget(
                    riskPercentage:
                        _riskData['currentRiskPercentage'] as double,
                    riskLevel: _riskData['riskLevel'] as String),
                SizedBox(height: 3.h),
                CurrentPositionsWidget(positions: _currentPositions),
                SizedBox(height: 3.h),
                RiskAnalyticsCardsWidget(riskMetrics: _riskMetrics),
                SizedBox(height: 3.h),
                ElevatedButton.icon(
                    onPressed: _showAdvancedSettings,
                    icon: CustomIconWidget(
                        iconName: 'settings', color: Colors.white, size: 4.w),
                    label: Text('Configuración Avanzada'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 6.h))),
              ])),
          // Calculator Tab
          SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(children: [
                RiskCalculatorWidget(),
                SizedBox(height: 3.h),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(3.w),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.shadowLight,
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ]),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            CustomIconWidget(
                                iconName: 'lightbulb',
                                color: Colors.orange,
                                size: 5.w),
                            SizedBox(width: 2.w),
                            Text('Recomendaciones',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ]),
                          SizedBox(height: 2.h),
                          _buildRecommendationItem(
                              'Nunca arriesgue más del 2% de su capital por operación',
                              'account_balance_wallet'),
                          SizedBox(height: 1.h),
                          _buildRecommendationItem(
                              'Mantenga un ratio riesgo/beneficio mínimo de 1:2',
                              'trending_up'),
                          SizedBox(height: 1.h),
                          _buildRecommendationItem(
                              'Diversifique sus posiciones para reducir correlación',
                              'pie_chart'),
                        ])),
              ])),
          // History Tab
          SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(children: [
                AlertHistoryWidget(alerts: _alertHistory),
              ])),
        ]));
  }

  Widget _buildRecommendationItem(String text, String iconName) {
    return Row(children: [
      CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.tertiary,
          size: 4.w),
      SizedBox(width: 2.w),
      Expanded(
          child: Text(text,
              style: AppTheme.lightTheme.textTheme.bodySmall
                  ?.copyWith(color: AppTheme.textSecondaryLight))),
    ]);
  }
}
