import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../live_chart_screen/live_chart_screen.dart';
import '../portfolio_management_screen/portfolio_management_screen.dart';
import '../risk_management_screen/risk_management_screen.dart';
import '../trading_history_screen/trading_history_screen.dart';
import '../trading_settings_screen/trading_settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const LiveChartScreen(),
    const PortfolioManagementScreen(),
    const TradingHistoryScreen(),
    const RiskManagementScreen(),
    const TradingSettingsScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': 'show_chart',
      'label': 'Gráfico',
      'activeIcon': 'trending_up',
    },
    {
      'icon': 'account_balance_wallet',
      'label': 'Portafolio',
      'activeIcon': 'account_balance_wallet',
    },
    {
      'icon': 'history',
      'label': 'Historial',
      'activeIcon': 'assignment',
    },
    {
      'icon': 'security',
      'label': 'Riesgos',
      'activeIcon': 'verified_user',
    },
    {
      'icon': 'settings',
      'label': 'Config',
      'activeIcon': 'settings',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Get the initial screen from route arguments if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['initialTab'] != null) {
        final initialTab = args['initialTab'] as int;
        if (initialTab >= 0 && initialTab < _screens.length) {
          _onTabTapped(initialTab);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Si no estamos en la primera pestaña, volver a ella
        if (_currentIndex != 0) {
          _onTabTapped(0);
          return false;
        }
        // Si ya estamos en la primera pestaña, mostrar diálogo de confirmación
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir de la aplicación?'),
            content: const Text('¿Estás seguro de que deseas salir?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salir'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.lightTheme.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              if (_currentIndex != 0) {
                _onTabTapped(0);
              }
            },
          ),
          title: Text(
            _navItems[_currentIndex]['label'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                // Recargar la pantalla actual
                setState(() {
                  _pageController.jumpToPage(_currentIndex);
                });
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
        bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 8.h,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(isActive ? 1.5.w : 1.w),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.lightTheme.primaryColor
                                      .withAlpha(38)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName:
                                  isActive ? item['activeIcon'] : item['icon'],
                              color: isActive
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.lightTheme.colorScheme.onSurface
                                      .withAlpha(153),
                              size: isActive ? 26 : 24,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isActive ? 10.sp : 9.sp,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.lightTheme.colorScheme.onSurface
                                      .withAlpha(153),
                            ),
                            child: Text(
                              item['label'],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
