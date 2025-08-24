import 'package:flutter/material.dart';

import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/main_navigation_screen/main_navigation_screen.dart';
import '../presentation/live_chart_screen/live_chart_screen.dart';
import '../presentation/portfolio_management_screen/portfolio_management_screen.dart';
import '../presentation/risk_management_screen/risk_management_screen.dart';
import '../presentation/trading_history_screen/trading_history_screen.dart';
import '../presentation/trading_settings_screen/trading_settings_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String mainNavigation = '/main-navigation';
  static const String liveChart = '/live-chart';
  static const String liveChartScreen = '/live-chart-screen';
  static const String portfolioManagement = '/portfolio-management';
  static const String riskManagement = '/risk-management';
  static const String tradingHistory = '/trading-history';
  static const String tradingSettings = '/trading-settings';
  static const String tradingSettingsScreen = '/trading-settings-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    mainNavigation: (context) => const MainNavigationScreen(),
    liveChart: (context) => const LiveChartScreen(),
    liveChartScreen: (context) => const LiveChartScreen(),
    portfolioManagement: (context) => const PortfolioManagementScreen(),
    riskManagement: (context) => const RiskManagementScreen(),
    tradingHistory: (context) => const TradingHistoryScreen(),
    tradingSettings: (context) => const TradingSettingsScreen(),
    tradingSettingsScreen: (context) => const TradingSettingsScreen(),
  };
}