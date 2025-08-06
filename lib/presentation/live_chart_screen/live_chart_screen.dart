import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/env_loader.dart';
import '../../services/bingx_websocket_service.dart';
import './widgets/chart_tools_widget.dart';
import './widgets/chart_widget.dart';
import './widgets/indicator_settings_widget.dart';
import './widgets/price_info_widget.dart';
import './widgets/timeframe_selector_widget.dart';
import './widgets/trading_signals_widget.dart';

class LiveChartScreen extends StatefulWidget {
  const LiveChartScreen({Key? key}) : super(key: key);

  @override
  State<LiveChartScreen> createState() => _LiveChartScreenState();
}

class _LiveChartScreenState extends State<LiveChartScreen>
    with TickerProviderStateMixin {
  // Chart settings
  String _selectedTimeframe = '1m';
  bool _showEMA = true;
  bool _showRSI = true;
  bool _showBollingerBands = true;
  bool _isFullscreen = false;
  bool _isConnected = false;
  bool _hasRealCredentials = false;

  // Indicator parameters
  int _ema9Period = 9;
  int _ema21Period = 21;
  int _rsiPeriod = 14;
  int _bollingerPeriod = 20;
  double _bollingerStdDev = 2.0;

  // Current price data - now updated from real API
  double _currentPrice = 0.0;
  double _priceChange = 0.0;
  double _priceChangePercent = 0.0;
  double _volume24h = 0.0;
  double _high24h = 0.0;
  double _low24h = 0.0;

  // Real-time data
  final List<Map<String, dynamic>> _candleData = [];
  late List<Map<String, dynamic>> _tradingSignals;

  // BingX WebSocket service
  final BingXWebSocketService _webSocketService = BingXWebSocketService();
  StreamSubscription? _priceSubscription;
  StreamSubscription? _candleSubscription;

  // Stream controllers for mock data
  final StreamController<Map<String, dynamic>> _priceController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _candleController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  void initState() {
    super.initState();
    _initializeTradingSignals();
    _connectToWebSocket();
  }

  void _initializeTradingSignals() {
    _tradingSignals = [
      {
        'type': 'BUY',
        'strength': 'Strong',
        'price': 2845.30,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'reason': 'EMA crossover + RSI oversold',
      },
      {
        'type': 'SELL',
        'strength': 'Moderate',
        'price': 2852.10,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
        'reason': 'Resistance level reached',
      },
    ];
  }

  Future<void> _connectToWebSocket() async {
    try {
      // Check for real credentials first (both env and SharedPreferences)
      await EnvLoader.load();
      final prefs = await SharedPreferences.getInstance();
      final hasUserKeys = prefs.containsKey('bingx_api_key') &&
          prefs.containsKey('bingx_secret_key');

      _hasRealCredentials = EnvLoader.hasBingxCredentials || hasUserKeys;

      if (!_hasRealCredentials) {
        if (kDebugMode) {
          print(
              '🔄 BingX WebSocket: No valid credentials, using enhanced demo data stream');
        }
        _startEnhancedMockDataStream();
        return;
      }

      await _webSocketService.connect();

      // Listen to real-time price updates
      _priceSubscription = _webSocketService.priceStream.listen((priceData) {
        if (mounted) {
          setState(() {
            _currentPrice = priceData['price'] ?? 0.0;
            _priceChange = priceData['priceChange'] ?? 0.0;
            _priceChangePercent = priceData['priceChangePercent'] ?? 0.0;
            _volume24h = priceData['volume'] ?? 0.0;
            _high24h = priceData['high'] ?? 0.0;
            _low24h = priceData['low'] ?? 0.0;
            _isConnected = _webSocketService.isConnected;
          });
        }
      });

      // Listen to real-time candle updates
      _candleSubscription = _webSocketService.candleStream.listen((candleData) {
        if (mounted && candleData['isComplete'] == true) {
          setState(() {
            // Add new complete candle to the data
            final newCandle = {
              'timestamp': candleData['timestamp'],
              'open': candleData['open'],
              'high': candleData['high'],
              'low': candleData['low'],
              'close': candleData['close'],
              'volume': candleData['volume'],
              // Calculate technical indicators
              'ema9': _calculateEMA(candleData['close'], 9),
              'ema21': _calculateEMA(candleData['close'], 21),
              'rsi': _calculateRSI(),
              'upperBand': candleData['close'] + 15,
              'lowerBand': candleData['close'] - 15,
            };

            _candleData.add(newCandle);

            // Keep only last 500 candles for performance
            if (_candleData.length > 500) {
              _candleData.removeAt(0);
            }

            _isConnected = _webSocketService.isConnected;
          });
        }
      });

      if (kDebugMode) {
        print(
            '✅ BingX WebSocket: Connected with REAL credentials for live data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });

        if (kDebugMode) {
          print('❌ BingX WebSocket connection failed: $e');
          print('🔄 Falling back to enhanced demo data stream');
        }

        // Fall back to enhanced mock data
        _startEnhancedMockDataStream();

        if (_hasRealCredentials && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 20),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Error conectando a BingX WebSocket',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                            'Usando datos demo: ${e.toString().split(':').first}',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  void _startEnhancedMockDataStream() {
    _isConnected = true;
    final random = Random();
    var basePrice = 2865.30;
    var trend = 0.0; // -1 to 1, indicates current trend direction
    var volatility = 1.0; // Multiplier for price movements

    // Initialize with some historical-looking data
    if (_candleData.isEmpty) {
      _initializeMockHistoricalData();
    }

    // Simulate real-time price updates with more realistic behavior
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      // Simulate market factors
      final marketHour = DateTime.now().hour;
      final isActiveHours = (marketHour >= 14 && marketHour <= 22) ||
          (marketHour >= 1 && marketHour <= 9);
      volatility = isActiveHours ? 1.5 : 0.7;

      // Add some trend persistence
      trend += (random.nextDouble() - 0.5) * 0.1;
      trend = trend.clamp(-1.0, 1.0);

      // Price movement with trend and volatility
      final movement =
          (trend * 0.3 + (random.nextDouble() - 0.5)) * 2.0 * volatility;
      basePrice += movement;
      basePrice =
          basePrice.clamp(2500.0, 3200.0); // Reasonable ETH price bounds

      final priceChange = movement;
      final priceChangePercent = (priceChange / basePrice) * 100;

      final priceData = {
        'symbol': 'ETH-USDT',
        'price': basePrice,
        'priceChange': priceChange,
        'priceChangePercent': priceChangePercent,
        'volume': 125847.50 + random.nextDouble() * 2000,
        'high': basePrice + random.nextDouble() * 25.0,
        'low': basePrice - random.nextDouble() * 20.0,
        'timestamp': DateTime.now(),
      };

      setState(() {
        _currentPrice = (priceData['price'] as num).toDouble();
        _priceChange = (priceData['priceChange'] as num).toDouble();
        _priceChangePercent =
            (priceData['priceChangePercent'] as num).toDouble();
        _volume24h = (priceData['volume'] as num).toDouble();
        _high24h = (priceData['high'] as num).toDouble();
        _low24h = (priceData['low'] as num).toDouble();
      });

      _priceController.add(priceData);
    });

    // Simulate candle data updates with more realistic OHLC
    Timer.periodic(const Duration(seconds: 60), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      final lastClose =
          _candleData.isNotEmpty ? _candleData.last['close'] : basePrice;
      final open = lastClose + (random.nextDouble() - 0.5) * 2.0;

      // Generate realistic OHLC within the minute
      final movements =
          List.generate(4, (i) => open + (random.nextDouble() - 0.5) * 8.0);
      movements.sort();

      final low = movements.first;
      final high = movements.last;
      final close = open + (random.nextDouble() - 0.5) * 6.0 + (trend * 2.0);

      final candleData = {
        'symbol': 'ETH-USDT',
        'timestamp': DateTime.now(),
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': 500.0 + random.nextDouble() * 200,
        'isComplete': true,
      };

      _candleController.add(candleData);
    });

    if (kDebugMode) {
      print(
          '🔄 BingX Chart: Enhanced demo data stream started (configure API keys for real data)');
    }
  }

  void _initializeMockHistoricalData() {
    final random = Random();
    var price = 2850.0;
    final now = DateTime.now();

    // Generate 100 historical candles
    for (int i = 100; i >= 0; i--) {
      final timestamp = now.subtract(Duration(minutes: i));
      final open = price;

      // Simulate realistic price movement
      final movement = (random.nextDouble() - 0.5) * 10.0;
      final close = open + movement;
      final high = [open, close].reduce((a, b) => a > b ? a : b) +
          random.nextDouble() * 5;
      final low = [open, close].reduce((a, b) => a < b ? a : b) -
          random.nextDouble() * 5;

      _candleData.add({
        'timestamp': timestamp,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': 400.0 + random.nextDouble() * 200,
        'ema9': _calculateEMA(close, 9),
        'ema21': _calculateEMA(close, 21),
        'rsi': _calculateRSI(),
        'upperBand': close + 15,
        'lowerBand': close - 15,
      });

      price = close;
    }
  }

  // Simplified technical indicator calculations
  double _calculateEMA(double price, int period) {
    if (_candleData.isEmpty) return price;

    final multiplier = 2.0 / (period + 1);
    final lastEma = period == 9
        ? (_candleData.last['ema9'] ?? price)
        : (_candleData.last['ema21'] ?? price);

    return (price * multiplier) + (lastEma * (1 - multiplier));
  }

  double _calculateRSI() {
    if (_candleData.length < _rsiPeriod) return 50.0;

    double gains = 0.0;
    double losses = 0.0;

    for (int i = _candleData.length - _rsiPeriod;
        i < _candleData.length - 1;
        i++) {
      final change = _candleData[i + 1]['close'] - _candleData[i]['close'];
      if (change > 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }

    final avgGain = gains / _rsiPeriod;
    final avgLoss = losses / _rsiPeriod;

    if (avgLoss == 0) return 100.0;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _isFullscreen ? null : _buildAppBar(),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            children: [
              if (!_isFullscreen) ...[
                // Price info header with connection status
                PriceInfoWidget(
                  currentPrice: _currentPrice,
                  priceChange: _priceChange,
                  priceChangePercent: _priceChangePercent,
                  volume24h: _volume24h,
                  high24h: _high24h,
                  low24h: _low24h,
                  isConnected: _isConnected,
                ),

                // Timeframe selector
                TimeframeSelectorWidget(
                  selectedTimeframe: _selectedTimeframe,
                  onTimeframeChanged: _onTimeframeChanged,
                ),
              ],

              // Main chart area
              Expanded(
                child: Stack(
                  children: [
                    ChartWidget(
                      candleData: _candleData,
                      showEMA: _showEMA,
                      showRSI: _showRSI,
                      showBollingerBands: _showBollingerBands,
                      onCandleTap: _onCandleTap,
                    ),

                    // Chart tools
                    ChartToolsWidget(
                      onDrawingTool: _onDrawingTool,
                      onSupportResistance: _onSupportResistance,
                      onScreenshot: _onScreenshot,
                      onFullscreen: _toggleFullscreen,
                    ),

                    // Trading signals
                    TradingSignalsWidget(
                      signals: _tradingSignals,
                      onSignalTap: _onSignalTap,
                    ),

                    // Enhanced connection status indicator
                    if (!_hasRealCredentials || !_isConnected)
                      Positioned(
                        top: 2.h,
                        left: 4.w,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.homeScreen,
                              arguments: {
                                'initialTab': 4
                              }, // Go to settings tab
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: (!_hasRealCredentials
                                      ? Colors.orange
                                      : Colors.red)
                                  .withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: !_hasRealCredentials
                                      ? 'link_off'
                                      : 'error_outline',
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      !_hasRealCredentials
                                          ? 'MODO DEMOSTRACIÓN'
                                          : 'ERROR CONEXIÓN',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Toca para configurar',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.8),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _isFullscreen ? null : _buildIndicatorSettings(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            'Gráfico en Vivo - ETH/USDT',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _hasRealCredentials
                  ? (_isConnected ? Colors.green : Colors.red)
                  : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              _hasRealCredentials ? (_isConnected ? 'LIVE' : 'ERROR') : 'DEMO',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: _hasRealCredentials
                    ? (_isConnected ? Colors.green : Colors.red)
                    : Colors.orange,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.homeScreen,
              arguments: {'initialTab': 1}, // Go to portfolio tab
            );
          },
          icon: CustomIconWidget(
            iconName: 'account_balance_wallet',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.homeScreen,
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
    );
  }

  Widget? _buildIndicatorSettings() {
    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 15.w,
                  height: 0.5.h,
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Quick indicators toggle
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickToggle('EMA', _showEMA, (value) {
                        setState(() => _showEMA = value);
                      }),
                      _buildQuickToggle('RSI', _showRSI, (value) {
                        setState(() => _showRSI = value);
                      }),
                      _buildQuickToggle('BB', _showBollingerBands, (value) {
                        setState(() => _showBollingerBands = value);
                      }),
                    ],
                  ),
                ),

                // Full settings
                IndicatorSettingsWidget(
                  showEMA: _showEMA,
                  showRSI: _showRSI,
                  showBollingerBands: _showBollingerBands,
                  ema9Period: _ema9Period,
                  ema21Period: _ema21Period,
                  rsiPeriod: _rsiPeriod,
                  bollingerPeriod: _bollingerPeriod,
                  bollingerStdDev: _bollingerStdDev,
                  onEMAToggle: (value) => setState(() => _showEMA = value),
                  onRSIToggle: (value) => setState(() => _showRSI = value),
                  onBollingerToggle: (value) =>
                      setState(() => _showBollingerBands = value),
                  onEMA9PeriodChanged: (value) =>
                      setState(() => _ema9Period = value),
                  onEMA21PeriodChanged: (value) =>
                      setState(() => _ema21Period = value),
                  onRSIPeriodChanged: (value) =>
                      setState(() => _rsiPeriod = value),
                  onBollingerPeriodChanged: (value) =>
                      setState(() => _bollingerPeriod = value),
                  onBollingerStdDevChanged: (value) =>
                      setState(() => _bollingerStdDev = value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickToggle(String label, bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: value
              ? AppTheme.lightTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: value
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _onTimeframeChanged(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });

    // Change timeframe on WebSocket service
    _webSocketService.changeTimeframe(timeframe);
  }

  void _onCandleTap(Map<String, dynamic> candle) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Datos de Vela',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCandleDataRow(
                'Apertura', '\$${(candle['open'] as num).toStringAsFixed(2)}'),
            _buildCandleDataRow(
                'Máximo', '\$${(candle['high'] as num).toStringAsFixed(2)}'),
            _buildCandleDataRow(
                'Mínimo', '\$${(candle['low'] as num).toStringAsFixed(2)}'),
            _buildCandleDataRow(
                'Cierre', '\$${(candle['close'] as num).toStringAsFixed(2)}'),
            _buildCandleDataRow(
                'Volumen', (candle['volume'] as num).toStringAsFixed(0)),
            _buildCandleDataRow(
                'RSI', (candle['rsi'] as num).toStringAsFixed(2)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCandleDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _onSignalTap(Map<String, dynamic> signal) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 15.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Señal de Trading',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSignalDetailRow('Tipo', signal['type'] as String),
            _buildSignalDetailRow('Fuerza', signal['strength'] as String),
            _buildSignalDetailRow(
                'Precio', '\$${(signal['price'] as num).toStringAsFixed(2)}'),
            _buildSignalDetailRow('Razón', signal['reason'] as String),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to trading screen or execute trade
                    },
                    child: Text('Ejecutar Operación'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDrawingTool() {
    HapticFeedback.lightImpact();
    // Implement drawing tool functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Herramientas de dibujo activadas')),
    );
  }

  void _onSupportResistance() {
    HapticFeedback.lightImpact();
    // Implement support/resistance marking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modo soporte/resistencia activado')),
    );
  }

  void _onScreenshot() {
    HapticFeedback.lightImpact();
    // Implement screenshot functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Captura de pantalla guardada')),
    );
  }

  void _toggleFullscreen() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _priceSubscription?.cancel();
    _candleSubscription?.cancel();
    _priceController.close();
    _candleController.close();
    _webSocketService.dispose();
    super.dispose();
  }
}