import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_filter_bottom_sheet.dart';
import './widgets/date_range_picker_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/summary_stats_widget.dart';
import './widgets/trade_card_widget.dart';

class TradingHistoryScreen extends StatefulWidget {
  const TradingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TradingHistoryScreen> createState() => _TradingHistoryScreenState();
}

class _TradingHistoryScreenState extends State<TradingHistoryScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  String _selectedTradeType = 'TODOS';
  String _selectedOutcome = 'TODOS';
  String _selectedMode = 'TODOS';
  DateTimeRange? _selectedDateRange;
  Map<String, dynamic> _advancedFilters = {};

  // UI states
  bool _isLoading = false;
  bool _isSearchVisible = false;
  bool _isMultiSelectMode = false;
  List<int> _selectedTradeIds = [];

  // Data
  List<Map<String, dynamic>> _allTrades = [];
  List<Map<String, dynamic>> _filteredTrades = [];
  Map<String, dynamic> _summaryStats = {};

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    _allTrades = [
      {
        "id": 1,
        "type": "BUY",
        "mode": "LIVE",
        "entryPrice": 2456.78,
        "exitPrice": 2489.34,
        "pnl": 156.78,
        "quantity": 0.0641,
        "timestamp": "06/08/2025 14:23",
        "duration": "2h 15m",
        "signal": "EMA Cross",
        "indicators": ["EMA 9/21", "RSI 14"],
        "notes": "Señal alcista confirmada con volumen alto"
      },
      {
        "id": 2,
        "type": "SELL",
        "mode": "LIVE",
        "entryPrice": 2489.34,
        "exitPrice": 2467.12,
        "pnl": -89.45,
        "quantity": 0.0641,
        "timestamp": "06/08/2025 12:08",
        "duration": "1h 45m",
        "signal": "RSI Overbought",
        "indicators": ["RSI 14", "Bollinger Bands"],
        "notes": "Resistencia fuerte en 2490"
      },
      {
        "id": 3,
        "type": "BUY",
        "mode": "PAPER",
        "entryPrice": 2434.56,
        "exitPrice": 2456.78,
        "pnl": 67.89,
        "quantity": 0.0305,
        "timestamp": "06/08/2025 09:45",
        "duration": "3h 12m",
        "signal": "BB Squeeze",
        "indicators": ["Bollinger Bands", "MACD"],
        "notes": "Breakout después de consolidación"
      },
      {
        "id": 4,
        "type": "SELL",
        "mode": "LIVE",
        "entryPrice": 2467.12,
        "exitPrice": null,
        "pnl": -23.45,
        "quantity": 0.0487,
        "timestamp": "06/08/2025 08:30",
        "duration": "5h 54m",
        "signal": "MACD Signal",
        "indicators": ["MACD", "EMA 9/21"],
        "notes": "Posición activa - Stop loss ajustado"
      },
      {
        "id": 5,
        "type": "BUY",
        "mode": "LIVE",
        "entryPrice": 2398.45,
        "exitPrice": 2434.56,
        "pnl": 234.67,
        "quantity": 0.0651,
        "timestamp": "05/08/2025 16:20",
        "duration": "4h 25m",
        "signal": "RSI Oversold",
        "indicators": ["RSI 14", "Stochastic"],
        "notes": "Rebote desde soporte clave"
      },
    ];

    _summaryStats = {
      "totalTrades": _allTrades.length,
      "winRate": 60.0,
      "avgPnL": 69.29,
      "bestTrade": 234.67,
      "worstTrade": -89.45,
      "totalPnL": 346.44,
    };

    _applyFilters();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading) {
      _loadMoreTrades();
    }
  }

  Future<void> _loadMoreTrades() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Add more mock trades
    final List<Map<String, dynamic>> moreTrades = [
      {
        "id": _allTrades.length + 1,
        "type": "SELL",
        "mode": "PAPER",
        "entryPrice": 2378.90,
        "exitPrice": 2356.12,
        "pnl": -45.23,
        "quantity": 0.0198,
        "timestamp": "05/08/2025 14:15",
        "duration": "1h 30m",
        "signal": "EMA Cross",
        "indicators": ["EMA 9/21"],
        "notes": "Señal bajista confirmada"
      },
    ];

    setState(() {
      _allTrades.addAll(moreTrades);
      _isLoading = false;
    });

    _applyFilters();
  }

  Future<void> _refreshTrades() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // Simulate getting fresh data
    _initializeMockData();

    setState(() {
      _isLoading = false;
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allTrades);

    // Apply basic filters
    if (_selectedTradeType != 'TODOS') {
      filtered = filtered
          .where((trade) => trade['type'] == _selectedTradeType)
          .toList();
    }

    if (_selectedOutcome != 'TODOS') {
      if (_selectedOutcome == 'GANANCIA') {
        filtered =
            filtered.where((trade) => (trade['pnl'] as num) > 0).toList();
      } else if (_selectedOutcome == 'PÉRDIDA') {
        filtered =
            filtered.where((trade) => (trade['pnl'] as num) < 0).toList();
      }
    }

    if (_selectedMode != 'TODOS') {
      filtered =
          filtered.where((trade) => trade['mode'] == _selectedMode).toList();
    }

    // Apply date range filter
    if (_selectedDateRange != null) {
      // In a real app, you would parse the timestamp and filter by date
      // For now, we'll keep all trades as they're all recent
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((trade) {
        return trade['signal'].toString().toLowerCase().contains(searchTerm) ||
            trade['notes'].toString().toLowerCase().contains(searchTerm) ||
            trade['timestamp'].toString().toLowerCase().contains(searchTerm);
      }).toList();
    }

    // Apply advanced filters
    if (_advancedFilters.isNotEmpty) {
      if (_advancedFilters['minProfit'] != null) {
        filtered = filtered
            .where((trade) =>
                (trade['pnl'] as num) >= _advancedFilters['minProfit'])
            .toList();
      }
      if (_advancedFilters['maxProfit'] != null) {
        filtered = filtered
            .where((trade) =>
                (trade['pnl'] as num) <= _advancedFilters['maxProfit'])
            .toList();
      }
      if (_advancedFilters['indicators'] != null &&
          (_advancedFilters['indicators'] as List).isNotEmpty) {
        filtered = filtered.where((trade) {
          final tradeIndicators = trade['indicators'] as List<String>;
          return (_advancedFilters['indicators'] as List<String>)
              .any((indicator) => tradeIndicators.contains(indicator));
        }).toList();
      }
    }

    setState(() {
      _filteredTrades = filtered;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _applyFilters();
      }
    });
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedTradeIds.clear();
      }
    });
  }

  void _toggleTradeSelection(int tradeId) {
    setState(() {
      if (_selectedTradeIds.contains(tradeId)) {
        _selectedTradeIds.remove(tradeId);
      } else {
        _selectedTradeIds.add(tradeId);
      }
    });
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterBottomSheet(
        currentFilters: _advancedFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _advancedFilters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _exportTrades() {
    // In a real app, this would generate and download a CSV file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportando ${_filteredTrades.length} trades...'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () {},
        ),
      ),
    );
  }

  void _viewTradeDetails(Map<String, dynamic> trade) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTradeDetailsSheet(trade),
    );
  }

  Widget _buildTradeDetailsSheet(Map<String, dynamic> trade) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalles del Trade #${trade['id']}',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trade summary card would go here
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Trade',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Señal: ${trade['signal']}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Notas: ${trade['notes']}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Indicadores: ${(trade['indicators'] as List<String>).join(', ')}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Historial de Trading'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _toggleSearch,
            child: CustomIconWidget(
              iconName: _isSearchVisible ? 'search_off' : 'search',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: _exportTrades,
            child: CustomIconWidget(
              iconName: 'file_download',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: _toggleMultiSelect,
            child: CustomIconWidget(
              iconName: _isMultiSelectMode ? 'check_circle' : 'checklist',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_isSearchVisible)
            Container(
              padding: EdgeInsets.all(4.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por fecha, señal o notas...',
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                          child: CustomIconWidget(
                            iconName: 'clear',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        )
                      : null,
                ),
                onChanged: (value) => _applyFilters(),
              ),
            ),

          // Date range picker
          DateRangePickerWidget(
            selectedRange: _selectedDateRange,
            onRangeChanged: (range) {
              setState(() {
                _selectedDateRange = range;
              });
              _applyFilters();
            },
          ),

          // Filter chips
          FilterChipsWidget(
            selectedTradeType: _selectedTradeType,
            selectedOutcome: _selectedOutcome,
            selectedMode: _selectedMode,
            onTradeTypeChanged: (value) {
              setState(() {
                _selectedTradeType = value;
              });
              _applyFilters();
            },
            onOutcomeChanged: (value) {
              setState(() {
                _selectedOutcome = value;
              });
              _applyFilters();
            },
            onModeChanged: (value) {
              setState(() {
                _selectedMode = value;
              });
              _applyFilters();
            },
          ),

          // Summary stats
          SummaryStatsWidget(stats: _summaryStats),

          // Multi-select actions
          if (_isMultiSelectMode && _selectedTradeIds.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  Text(
                    '${_selectedTradeIds.length} seleccionados',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Tag selected trades
                    },
                    icon: CustomIconWidget(
                      iconName: 'label',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    label: Text('Etiquetar'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Group selected trades
                    },
                    icon: CustomIconWidget(
                      iconName: 'folder',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    label: Text('Agrupar'),
                  ),
                ],
              ),
            ),

          // Trade list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTrades,
              child: _filteredTrades.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'history',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 48,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No se encontraron trades',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Ajusta los filtros para ver más resultados',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredTrades.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredTrades.length) {
                          return Container(
                            padding: EdgeInsets.all(4.w),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final trade = _filteredTrades[index];
                        final tradeId = trade['id'] as int;
                        final isSelected = _selectedTradeIds.contains(tradeId);

                        return TradeCardWidget(
                          trade: trade,
                          isSelected: isSelected,
                          onTap: () {
                            if (_isMultiSelectMode) {
                              _toggleTradeSelection(tradeId);
                            } else {
                              _viewTradeDetails(trade);
                            }
                          },
                          onSwipeLeft: () {
                            // Show similar trades analysis
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Analizando trades similares...'),
                              ),
                            );
                          },
                          onSwipeRight: () {
                            // Share trade details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Compartiendo detalles del trade...'),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAdvancedFilters,
        child: CustomIconWidget(
          iconName: 'tune',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }
}
