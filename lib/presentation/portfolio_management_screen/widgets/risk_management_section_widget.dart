import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RiskManagementSectionWidget extends StatefulWidget {
  final double currentDrawdown;
  final double maxDrawdownLimit;
  final bool isTradingHalted;
  final VoidCallback? onShowRiskAnalytics;

  const RiskManagementSectionWidget({
    Key? key,
    required this.currentDrawdown,
    required this.maxDrawdownLimit,
    required this.isTradingHalted,
    this.onShowRiskAnalytics,
  }) : super(key: key);

  @override
  State<RiskManagementSectionWidget> createState() =>
      _RiskManagementSectionWidgetState();
}

class _RiskManagementSectionWidgetState
    extends State<RiskManagementSectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isTradingHalted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RiskManagementSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTradingHalted && !oldWidget.isTradingHalted) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isTradingHalted && oldWidget.isTradingHalted) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double drawdownPercentage =
        widget.currentDrawdown / widget.maxDrawdownLimit;
    final bool isInRedZone = drawdownPercentage >= 0.8;
    final bool isInDangerZone = drawdownPercentage >= 1.0;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -10) {
          widget.onShowRiskAnalytics?.call();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestión de Riesgo',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'keyboard_arrow_up',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withOpacity(0.6),
                      size: 20,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Deslizar',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isTradingHalted ? _pulseAnimation.value : 1.0,
                  child: Card(
                    elevation: widget.isTradingHalted ? 4 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: widget.isTradingHalted
                          ? BorderSide(
                              color: AppTheme.lightTheme.colorScheme.error,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: widget.isTradingHalted
                            ? LinearGradient(
                                colors: [
                                  AppTheme.lightTheme.colorScheme.error
                                      .withOpacity(0.1),
                                  AppTheme.lightTheme.colorScheme.surface,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Drawdown Diario',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    '${widget.currentDrawdown.toStringAsFixed(2)}% / ${widget.maxDrawdownLimit.toStringAsFixed(0)}%',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.isTradingHalted)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'stop',
                                        color: AppTheme
                                            .lightTheme.colorScheme.onError,
                                        size: 16,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'DETENIDO',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.onError,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progreso del Límite',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '${(drawdownPercentage * 100).toStringAsFixed(0)}%',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      color:
                                          _getProgressColor(drawdownPercentage),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 1.h,
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Container(
                                    width: (drawdownPercentage.clamp(0.0, 1.0) *
                                                100)
                                            .w *
                                        0.84,
                                    height: 1.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _getProgressGradient(
                                            drawdownPercentage),
                                        stops: [0.0, 0.8, 1.0],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  if (isInRedZone)
                                    Positioned(
                                      left: 80.w * 0.84,
                                      top: -0.5.h,
                                      child: Container(
                                        width: 0.5.w,
                                        height: 2.h,
                                        color: AppTheme
                                            .lightTheme.colorScheme.error,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Seguro',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                    ),
                                  ),
                                  Text(
                                    'Zona Roja',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (widget.isTradingHalted) ...[
                            SizedBox(height: 3.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.error
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.lightTheme.colorScheme.error
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'warning',
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    size: 24,
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Trading Automático Detenido',
                                          style: AppTheme
                                              .lightTheme.textTheme.titleSmall
                                              ?.copyWith(
                                            color: AppTheme
                                                .lightTheme.colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          'Se ha alcanzado el límite de drawdown diario. El trading se reanudará mañana.',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 1.0) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (percentage >= 0.8) {
      return Colors.orange;
    } else if (percentage >= 0.6) {
      return Colors.yellow[700]!;
    } else {
      return AppTheme.lightTheme.colorScheme.tertiary;
    }
  }

  List<Color> _getProgressGradient(double percentage) {
    if (percentage >= 1.0) {
      return [
        AppTheme.lightTheme.colorScheme.tertiary,
        Colors.orange,
        AppTheme.lightTheme.colorScheme.error,
      ];
    } else if (percentage >= 0.8) {
      return [
        AppTheme.lightTheme.colorScheme.tertiary,
        Colors.orange,
        AppTheme.lightTheme.colorScheme.error.withOpacity(0.7),
      ];
    } else {
      return [
        AppTheme.lightTheme.colorScheme.tertiary,
        AppTheme.lightTheme.primaryColor,
        AppTheme.lightTheme.primaryColor,
      ];
    }
  }
}
