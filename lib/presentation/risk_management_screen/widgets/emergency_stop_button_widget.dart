import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class EmergencyStopButtonWidget extends StatefulWidget {
  final VoidCallback onEmergencyStop;
  final bool isTrading;

  const EmergencyStopButtonWidget({
    Key? key,
    required this.onEmergencyStop,
    required this.isTrading,
  }) : super(key: key);

  @override
  State<EmergencyStopButtonWidget> createState() =>
      _EmergencyStopButtonWidgetState();
}

class _EmergencyStopButtonWidgetState extends State<EmergencyStopButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isTrading) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EmergencyStopButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTrading && !oldWidget.isTrading) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isTrading && oldWidget.isTrading) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleEmergencyStop() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isPressed = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text('Parada de Emergencia'),
            ],
          ),
          content: Text(
            '¿Está seguro de que desea detener todas las operaciones de trading inmediatamente?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isPressed = false;
                });
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onEmergencyStop();
                setState(() {
                  _isPressed = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: Text('Detener Trading'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isTrading ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.isTrading ? _handleEmergencyStop : null,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: widget.isTrading
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.textSecondaryLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isTrading
                        ? AppTheme.lightTheme.colorScheme.error
                            .withOpacity(0.3)
                        : AppTheme.shadowLight,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'stop',
                  color: Colors.white,
                  size: 8.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
