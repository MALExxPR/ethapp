import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/status_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  double _progress = 0.0;
  String _loadingText = 'Inicializando servicios de trading';
  String _statusText = 'Conectando a BingX API';
  bool _isConnected = false;
  bool _showRetry = false;

  // Mock initialization data
  final List<Map<String, dynamic>> _initializationSteps = [
    {
      'text': 'Verificando credenciales API',
      'status': 'Autenticando con BingX',
      'duration': 800,
      'progress': 0.2,
    },
    {
      'text': 'Estableciendo conexión WebSocket',
      'status': 'Conectando a datos de mercado',
      'duration': 1000,
      'progress': 0.4,
    },
    {
      'text': 'Cargando preferencias de usuario',
      'status': 'Configurando parámetros de trading',
      'duration': 600,
      'progress': 0.6,
    },
    {
      'text': 'Preparando datos históricos',
      'status': 'Cargando gráficos ETH-USDT',
      'duration': 900,
      'progress': 0.8,
    },
    {
      'text': 'Finalizando configuración',
      'status': 'Sistema listo para trading',
      'duration': 500,
      'progress': 1.0,
    },
  ];

  int _currentStep = 0;
  bool _hasApiCredentials = true; // Mock credential check
  bool _networkTimeout = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setSystemUIOverlay();
    _startInitialization();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _startInitialization() async {
    try {
      for (int i = 0; i < _initializationSteps.length; i++) {
        if (mounted) {
          setState(() {
            _currentStep = i;
            _loadingText = _initializationSteps[i]['text'] as String;
            _statusText = _initializationSteps[i]['status'] as String;
            _isConnected = i > 0; // Show connected after first step
            _showRetry = false;
          });

          // Simulate network timeout on step 1 (WebSocket connection)
          if (i == 1) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              setState(() {
                _networkTimeout = true;
                _isConnected = false;
                _statusText = 'Error de conexión - Reintentando';
                _showRetry = true;
              });
            }
            await Future.delayed(const Duration(milliseconds: 1500));
            if (mounted) {
              setState(() {
                _networkTimeout = false;
                _isConnected = true;
                _statusText = _initializationSteps[i]['status'] as String;
                _showRetry = false;
              });
            }
          }

          // Animate progress
          final targetProgress = _initializationSteps[i]['progress'] as double;
          final duration = _initializationSteps[i]['duration'] as int;

          await _animateProgress(targetProgress, duration);
        }
      }

      // Complete initialization
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _statusText = 'Error de inicialización';
          _showRetry = true;
        });
      }
    }
  }

  Future<void> _animateProgress(double target, int duration) async {
    final startProgress = _progress;
    final progressDiff = target - startProgress;
    const steps = 20;
    const stepDuration = 50;

    for (int i = 0; i <= steps; i++) {
      if (mounted) {
        setState(() {
          _progress = startProgress + (progressDiff * (i / steps));
        });
        await Future.delayed(const Duration(milliseconds: stepDuration));
      }
    }
  }

  void _retryConnection() {
    setState(() {
      _progress = 0.0;
      _currentStep = 0;
      _showRetry = false;
      _networkTimeout = false;
    });
    _startInitialization();
  }

  void _navigateToNextScreen() {
    if (_hasApiCredentials) {
      Navigator.pushReplacementNamed(context, '/live-chart-screen');
    } else {
      Navigator.pushReplacementNamed(context, '/trading-settings-screen');
    }
  }

  void _navigateToMainScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/main-navigation',
          arguments: {'initialTab': 0}, // Start with live chart
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          const BackgroundGradientWidget(),

          // Safe area content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Navigation buttons row
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/live-chart'),
                          child: Container(
                            padding: EdgeInsets.all(2.5.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: CustomIconWidget(
                              iconName: 'arrow_back',
                              color: Colors.white.withOpacity(0.8),
                              size: 5.w,
                            ),
                          ),
                        ),

                        // Home button
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/live-chart'),
                          child: Container(
                            padding: EdgeInsets.all(2.5.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: CustomIconWidget(
                              iconName: 'home',
                              color: Colors.white.withOpacity(0.8),
                              size: 5.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top spacer (reduced from 15.h to 10.h to accommodate buttons)
                  SizedBox(height: 10.h),

                  // App logo with animation
                  const AnimatedLogoWidget(),

                  // App title
                  SizedBox(height: 4.h),
                  Text(
                    'ETH Trading Bot',
                    style: GoogleFonts.inter(
                      fontSize: 6.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  // Subtitle
                  SizedBox(height: 1.h),
                  Text(
                    'Bot de Trading Automatizado',
                    style: GoogleFonts.inter(
                      fontSize: 3.5.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                  ),

                  // Spacer
                  SizedBox(height: 12.h),

                  // Loading indicator
                  LoadingIndicatorWidget(
                    loadingText: _loadingText,
                    progress: _progress,
                  ),

                  // Spacer
                  SizedBox(height: 8.h),

                  // Status indicator
                  StatusIndicatorWidget(
                    status: _statusText,
                    isConnected: _isConnected,
                    onRetry: _showRetry ? _retryConnection : null,
                  ),

                  // Bottom spacer
                  const Spacer(),

                  // Version info
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Column(
                      children: [
                        Text(
                          'Versión 1.0.0',
                          style: GoogleFonts.inter(
                            fontSize: 2.5.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Datos en tiempo real de BingX',
                          style: GoogleFonts.inter(
                            fontSize: 2.2.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Emergency exit (development only)
          if (_showRetry && _networkTimeout)
            Positioned(
              top: 8.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(
                    context, '/trading-settings-screen'),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: CustomIconWidget(
                    iconName: 'settings',
                    color: Colors.white.withOpacity(0.6),
                    size: 5.w,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}