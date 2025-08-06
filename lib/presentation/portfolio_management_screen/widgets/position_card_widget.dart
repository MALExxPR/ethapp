import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PositionCardWidget extends StatefulWidget {
  final Map<String, dynamic> position;
  final VoidCallback? onModifyStopLoss;
  final VoidCallback? onAdjustTakeProfit;
  final VoidCallback? onClosePosition;
  final VoidCallback? onViewDetails;

  const PositionCardWidget({
    Key? key,
    required this.position,
    this.onModifyStopLoss,
    this.onAdjustTakeProfit,
    this.onClosePosition,
    this.onViewDetails,
  }) : super(key: key);

  @override
  State<PositionCardWidget> createState() => _PositionCardWidgetState();
}

class _PositionCardWidgetState extends State<PositionCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isProfit = (widget.position['currentPnL'] as double) >= 0;
    final Color pnlColor = isProfit
        ? AppTheme.lightTheme.colorScheme.tertiary
        : AppTheme.lightTheme.colorScheme.error;

    final DateTime entryTime = widget.position['entryTime'] as DateTime;
    final Duration timeElapsed = DateTime.now().difference(entryTime);
    final Duration maxHoldTime = Duration(hours: 6);
    final double timeProgress = timeElapsed.inMinutes / maxHoldTime.inMinutes;

    return Dismissible(
      key: Key(widget.position['id'].toString()),
      background: _buildSwipeBackground(true),
      secondaryBackground: _buildSwipeBackground(false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          widget.onViewDetails?.call();
        } else {
          _showQuickActions();
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.position['type'] == 'BUY'
                                        ? AppTheme
                                            .lightTheme.colorScheme.tertiary
                                            .withOpacity(0.1)
                                        : AppTheme.lightTheme.colorScheme.error
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.position['type'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: widget.position['type'] == 'BUY'
                                          ? AppTheme
                                              .lightTheme.colorScheme.tertiary
                                          : AppTheme
                                              .lightTheme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'ETH-USDT',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Precio de Entrada: \$${(widget.position['entryPrice'] as double).toStringAsFixed(2)}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isProfit ? '+' : ''}\$${(widget.position['currentPnL'] as double).toStringAsFixed(2)}',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color: pnlColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '${isProfit ? '+' : ''}${((widget.position['currentPnL'] as double) / (widget.position['entryPrice'] as double) * 100).toStringAsFixed(2)}%',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: pnlColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tiempo Restante',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              LinearProgressIndicator(
                                value: timeProgress.clamp(0.0, 1.0),
                                backgroundColor: AppTheme
                                    .lightTheme.colorScheme.outline
                                    .withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  timeProgress > 0.8
                                      ? AppTheme.lightTheme.colorScheme.error
                                      : AppTheme.lightTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                '${(maxHoldTime.inMinutes - timeElapsed.inMinutes).clamp(0, maxHoldTime.inMinutes)} min restantes',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: timeProgress > 0.8
                                      ? AppTheme.lightTheme.colorScheme.error
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        CustomIconWidget(
                          iconName: _isExpanded ? 'expand_less' : 'expand_more',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withOpacity(0.6),
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _expandAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              'Stop Loss',
                              '\$${(widget.position['stopLoss'] as double).toStringAsFixed(2)}',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              'Take Profit',
                              '\$${(widget.position['takeProfit'] as double).toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              'Cantidad',
                              '${(widget.position['quantity'] as double).toStringAsFixed(6)} ETH',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              'Valor Actual',
                              '\$${(widget.position['currentValue'] as double).toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withOpacity(0.6),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeBackground(bool isLeft) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? AppTheme.lightTheme.primaryColor.withOpacity(0.1)
            : AppTheme.lightTheme.colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'info' : 'settings',
                color: isLeft
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.error,
                size: 28,
              ),
              SizedBox(height: 1.h),
              Text(
                isLeft ? 'Detalles' : 'Acciones',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isLeft
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                children: [
                  Text(
                    'Acciones Rápidas',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildActionButton(
                    'Modificar Stop Loss',
                    'tune',
                    widget.onModifyStopLoss,
                  ),
                  SizedBox(height: 2.h),
                  _buildActionButton(
                    'Ajustar Take Profit',
                    'trending_up',
                    widget.onAdjustTakeProfit,
                  ),
                  SizedBox(height: 2.h),
                  _buildActionButton(
                    'Cerrar Posición',
                    'close',
                    widget.onClosePosition,
                    isDestructive: true,
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String iconName,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error.withOpacity(0.3)
                : AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isDestructive
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDestructive
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
