import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BackgroundGradientWidget extends StatefulWidget {
  const BackgroundGradientWidget({super.key});

  @override
  State<BackgroundGradientWidget> createState() =>
      _BackgroundGradientWidgetState();
}

class _BackgroundGradientWidgetState extends State<BackgroundGradientWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (_gradientAnimation.value * 0.2),
                0.7 + (_gradientAnimation.value * 0.2),
                1.0,
              ],
              colors: [
                const Color(0xFF0F1419),
                AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
                AppTheme.lightTheme.colorScheme.primaryContainer
                    .withOpacity(0.6),
                const Color(0xFF1A1D29),
              ],
            ),
          ),
          child: CustomPaint(
            painter: TradingPatternPainter(
              animationValue: _gradientAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class TradingPatternPainter extends CustomPainter {
  final double animationValue;

  TradingPatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw subtle trading chart pattern in background
    final path = Path();
    final points = [
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.8),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy + (animationValue * 20));
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy + (animationValue * 20));
    }

    canvas.drawPath(path, paint);

    // Draw grid pattern
    paint.color = Colors.white.withOpacity(0.02);
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
