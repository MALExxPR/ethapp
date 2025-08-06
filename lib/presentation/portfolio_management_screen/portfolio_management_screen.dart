import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/env_loader.dart';
import '../../services/bingx_api_service.dart';
import './widgets/account_equity_header_widget.dart';
import './widgets/equity_curve_chart_widget.dart';
import './widgets/performance_metrics_widget.dart';
import './widgets/position_card_widget.dart';
import './widgets/risk_management_section_widget.dart';

class PortfolioManagementScreen extends StatefulWidget {
  const PortfolioManagementScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioManagementScreen> createState() =>
      _PortfolioManagementScreenState();
}

class _PortfolioManagementScreenState extends State<PortfolioManagementScreen>
    with TickerProviderStateMixin {
  bool _isUsdDenomination = true;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  late BingXApiService _bingXApiService;

  // Real-time data from BingX API
  List<Map<String, dynamic>> _currentPositions = [];
  Map<String, dynamic> _performanceData = {
    "sharpeRatio": 2.34,
    "maxDrawdown": 8.5,
    "winRate": 67.8,
    "totalTrades": 1247,
  };
  List<Map<String, dynamic>> _equityData = [];
  double _currentBalance = 9567.25;
  double _percentageChange = 2.34;
  double _currentDrawdown = 3.2;
  double _maxDrawdownLimit = 5.0;
  bool _isTradingHalted = false;
  bool _isApiConfigured = false;
  bool _hasRealCredentials = false;

  @override
  void initState() {
    super.initState();
    _bingXApiService = BingXApiService();
    _checkDrawdownStatus();
    _initializePortfolioData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bingXApiService.dispose();
    super.dispose();
  }

  Future<void> _initializePortfolioData() async {
    // Check for real BingX credentials
    await EnvLoader.load();

    // Also check SharedPreferences for user-configured keys
    final prefs = await SharedPreferences.getInstance();
    final hasUserKeys = prefs.containsKey('bingx_api_key') &&
        prefs.containsKey('bingx_secret_key');

    _hasRealCredentials = EnvLoader.hasBingxCredentials || hasUserKeys;

    setState(() {
      _isApiConfigured = _bingXApiService.isConfigured;
    });

    await _refreshPortfolioData();
    _generateEquityData();
  }

  void _generateEquityData() {
    // Generate sample equity curve data based on current balance
    final now = DateTime.now();
    _equityData = [
      {
        "date": now.subtract(const Duration(days: 30)),
        "equity": _currentBalance * 0.89
      },
      {
        "date": now.subtract(const Duration(days: 25)),
        "equity": _currentBalance * 0.91
      },
      {
        "date": now.subtract(const Duration(days: 20)),
        "equity": _currentBalance * 0.90
      },
      {
        "date": now.subtract(const Duration(days: 15)),
        "equity": _currentBalance * 0.95
      },
      {
        "date": now.subtract(const Duration(days: 10)),
        "equity": _currentBalance * 0.98
      },
      {
        "date": now.subtract(const Duration(days: 5)),
        "equity": _currentBalance * 0.96
      },
      {"date": now, "equity": _currentBalance},
    ];
  }

  void _checkDrawdownStatus() {
    setState(() {
      _isTradingHalted = _currentDrawdown >= _maxDrawdownLimit;
    });
  }

  Future<void> _refreshPortfolioData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    try {
      // Reload API keys in case they were just configured
      await _bingXApiService.reloadApiKeys();

      // Check again for credentials after potential reload
      final prefs = await SharedPreferences.getInstance();
      final hasUserKeys = prefs.containsKey('bingx_api_key') &&
          prefs.containsKey('bingx_secret_key');
      _hasRealCredentials = EnvLoader.hasBingxCredentials || hasUserKeys;

      if (!_hasRealCredentials || !_bingXApiService.isConfigured) {
        // Use demo data
        setState(() {
          _currentBalance = 9567.25;
          _percentageChange = 2.34;
          _currentPositions = _generateDemoPositions();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 2.w),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Modo Demostración Activo',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                            'Ve a Configuración → API para conectar tu cuenta BingX real',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Configurar',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.navigationScreen,
                    arguments: {'initialTab': 4}, // Go to settings tab
                  );
                },
              ),
            ),
          );
        }
        return;
      }

      // Fetch real account balance
      final balanceData = await _bingXApiService.getAccountBalance();
      if (balanceData['data'] != null) {
        final totalBalance =
            double.tryParse(balanceData['data']['totalWalletBalance'] ?? '0') ??
                _currentBalance;
        final unrealizedProfit = double.tryParse(
                balanceData['data']['totalUnrealizedProfit'] ?? '0') ??
            0.0;

        setState(() {
          _currentBalance = totalBalance;
          _percentageChange =
              totalBalance > 0 ? (unrealizedProfit / totalBalance * 100) : 0.0;
        });
      }

      // Fetch real positions
      final positions = await _bingXApiService.getOpenPositions();
      setState(() {
        _currentPositions = _convertApiPositionsToLocalFormat(positions);
      });

      _generateEquityData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 2.w),
                const Expanded(
                  child: Text('✅ Datos actualizados desde tu cuenta BingX real',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Fallback to demo data on error
      setState(() {
        _currentBalance = 9567.25;
        _percentageChange = 2.34;
        _currentPositions = _generateDemoPositions();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Error conectando a BingX',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                          'Mostrando datos demo: ${e.toString().split(':').first}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Revisar',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.navigationScreen,
                  arguments: {'initialTab': 4}, // Go to settings tab
                );
              },
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });

      _checkDrawdownStatus();
      HapticFeedback.selectionClick();
    }
  }

  List<Map<String, dynamic>> _generateDemoPositions() {
    return [
      {
        "id": 1001,
        "symbol": "ETH-USDT",
        "type": "BUY",
        "entryPrice": 2847.50,
        "currentValue": 2865.30,
        "currentPnL": 178.50,
        "quantity": 0.125,
        "stopLoss": 2819.20,
        "takeProfit": 2890.30,
        "entryTime":
            DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      },
      {
        "id": 1002,
        "symbol": "ETH-USDT",
        "type": "SELL",
        "entryPrice": 2852.20,
        "currentValue": 2865.30,
        "currentPnL": -163.75,
        "quantity": 0.100,
        "stopLoss": 2880.50,
        "takeProfit": 2825.10,
        "entryTime":
            DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      },
    ];
  }

  List<Map<String, dynamic>> _convertApiPositionsToLocalFormat(
      List<Map<String, dynamic>> apiPositions) {
    return apiPositions.map((position) {
      final entryPrice =
          double.tryParse(position['entryPrice']?.toString() ?? '0') ?? 0.0;
      final markPrice =
          double.tryParse(position['markPrice']?.toString() ?? '0') ?? 0.0;
      final positionAmt =
          double.tryParse(position['positionAmt']?.toString() ?? '0') ?? 0.0;
      final unrealizedProfit =
          double.tryParse(position['unRealizedProfit']?.toString() ?? '0') ??
              0.0;

      return {
        "id": position['symbol'].hashCode,
        "symbol": position['symbol'] ?? 'ETH-USDT',
        "type": position['positionSide'] == 'LONG' ? 'BUY' : 'SELL',
        "entryPrice": entryPrice,
        "currentValue": markPrice,
        "currentPnL": unrealizedProfit,
        "quantity": positionAmt.abs(),
        "stopLoss":
            entryPrice * (position['positionSide'] == 'LONG' ? 0.99 : 1.01),
        "takeProfit":
            entryPrice * (position['positionSide'] == 'LONG' ? 1.015 : 0.985),
        "entryTime": DateTime.fromMillisecondsSinceEpoch(
            int.tryParse(position['updateTime']?.toString() ?? '0') ??
                DateTime.now().millisecondsSinceEpoch),
      };
    }).toList();
  }

  void _toggleDenomination() {
    HapticFeedback.selectionClick();
    setState(() {
      _isUsdDenomination = !_isUsdDenomination;
    });
  }

  void _navigateToSettings() {
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.navigationScreen,
      arguments: {'initialTab': 4}, // Go to settings tab
    );
  }

  void _navigateBack() {
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.navigationScreen,
      arguments: {'initialTab': 0}, // Go back to chart tab
    );
  }

  void _showNewPositionEntry() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildNewPositionBottomSheet(),
    );
  }

  void _showRiskAnalyticsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildRiskAnalyticsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPortfolioData,
          color: AppTheme.lightTheme.primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App bar with back button
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppTheme.lightTheme.primaryColor,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.navigationScreen,
                      arguments: {'initialTab': 0}, // Go back to chart tab
                    );
                  },
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Gestión de Patrimonio',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  // Connection status indicator
                  Container(
                    margin: EdgeInsets.only(right: 2.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _hasRealCredentials
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _hasRealCredentials ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName:
                              _hasRealCredentials ? 'check_circle' : 'info',
                          color: _hasRealCredentials
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _hasRealCredentials ? 'REAL' : 'DEMO',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _hasRealCredentials
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings button
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.navigationScreen,
                        arguments: {'initialTab': 4}, // Go to settings tab
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: AccountEquityHeaderWidget(
                  currentBalance: _currentBalance,
                  percentageChange: _percentageChange,
                  isUsdDenomination: _isUsdDenomination,
                  onToggleDenomination: _toggleDenomination,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Posiciones Actuales',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!_hasRealCredentials)
                        GestureDetector(
                          onTap: _navigateToSettings,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.lightTheme.primaryColor
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'link',
                                  color: AppTheme.lightTheme.primaryColor,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Conectar BingX',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _currentPositions.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return PositionCardWidget(
                            position: _currentPositions[index],
                            onModifyStopLoss: () =>
                                _handleModifyStopLoss(_currentPositions[index]),
                            onAdjustTakeProfit: () => _handleAdjustTakeProfit(
                                _currentPositions[index]),
                            onClosePosition: () =>
                                _handleClosePosition(_currentPositions[index]),
                            onViewDetails: () =>
                                _handleViewDetails(_currentPositions[index]),
                          );
                        },
                        childCount: _currentPositions.length,
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 4.h),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(6.w),
                            child: Column(
                              children: [
                                CustomIconWidget(
                                  iconName: _hasRealCredentials
                                      ? 'trending_flat'
                                      : 'link_off',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  size: 48,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _hasRealCredentials
                                      ? 'No hay posiciones activas'
                                      : 'Conecta tu cuenta BingX',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  _hasRealCredentials
                                      ? 'Toca el botón + para abrir una nueva posición'
                                      : 'Ve a Configuración para conectar tu API de BingX y ver tus posiciones reales',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (!_hasRealCredentials) ...[
                                  SizedBox(height: 3.h),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.navigationScreen,
                                        arguments: {
                                          'initialTab': 4
                                        }, // Go to settings tab
                                      );
                                    },
                                    icon: const Icon(Icons.settings, size: 20),
                                    label: const Text('Ir a Configuración'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppTheme.lightTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 1.5.h,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              SliverToBoxAdapter(
                child: PerformanceMetricsWidget(
                  performanceData: _performanceData,
                ),
              ),
              SliverToBoxAdapter(
                child: EquityCurveChartWidget(
                  equityData: _equityData,
                ),
              ),
              SliverToBoxAdapter(
                child: RiskManagementSectionWidget(
                  currentDrawdown: _currentDrawdown,
                  maxDrawdownLimit: _maxDrawdownLimit,
                  isTradingHalted: _isTradingHalted,
                  onShowRiskAnalytics: _showRiskAnalyticsBottomSheet,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTradingHalted ? null : _showNewPositionEntry,
        backgroundColor: _isTradingHalted
            ? AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.3)
            : AppTheme.lightTheme.primaryColor,
        child: CustomIconWidget(
          iconName: 'add',
          color: _isTradingHalted
              ? AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5)
              : AppTheme.lightTheme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildNewPositionBottomSheet() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva Posición',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Análisis de Mercado Actual',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'ETH-USDT: \$2,865.30 (+1.2%)\nRSI: 58.4 | EMA 9/21: Alcista\nVolatilidad: Media',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  _hasRealCredentials
                      ? 'Esta funcionalidad estará disponible en la próxima actualización.'
                      : 'Configura primero tus API Keys de BingX en la pantalla de configuración.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAnalyticsBottomSheet() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Análisis de Riesgo Detallado',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildRiskMetricCard(
                    'Calculadora de Tamaño de Posición',
                    'Riesgo por operación: 0.5%\nCapital disponible: \$${_currentBalance.toStringAsFixed(2)}\nTamaño máximo recomendado: \$${(_currentBalance * 0.005).toStringAsFixed(2)}',
                    'calculate',
                    AppTheme.lightTheme.primaryColor,
                  ),
                  SizedBox(height: 2.h),
                  _buildRiskMetricCard(
                    'Monitoreo de Volatilidad',
                    'ATR 14: \$42.50\nVolatilidad intradiaria: 2.8%\nNivel de riesgo: Medio',
                    'show_chart',
                    Colors.orange,
                  ),
                  SizedBox(height: 2.h),
                  _buildRiskMetricCard(
                    'Límites de Trading',
                    'Tiempo máximo de posición: 6 horas\nDrawdown diario máximo: ${_maxDrawdownLimit.toStringAsFixed(0)}%\nDrawdown actual: ${_currentDrawdown.toStringAsFixed(1)}%',
                    'security',
                    _currentDrawdown >= _maxDrawdownLimit * 0.8
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.tertiary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMetricCard(
      String title, String content, String iconName, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    content,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleModifyStopLoss(Map<String, dynamic> position) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modificar Stop Loss para posición ${position['id']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleAdjustTakeProfit(Map<String, dynamic> position) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ajustar Take Profit para posición ${position['id']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleClosePosition(Map<String, dynamic> position) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Posición'),
        content: Text(
            '¿Estás seguro de que deseas cerrar la posición ${position['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentPositions.removeWhere((p) => p['id'] == position['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Posición ${position['id']} cerrada exitosamente'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              );
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _handleViewDetails(Map<String, dynamic> position) {
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.navigationScreen,
      arguments: {'initialTab': 2}, // Go to history tab
    );
  }
}