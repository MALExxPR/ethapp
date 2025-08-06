import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LoadingIndicatorWidget extends StatefulWidget {
  final String loadingText;
  final double progress;

  const LoadingIndicatorWidget({
    super.key,
    required this.loadingText,
    required this.progress,
  });

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotAnimationController;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _dotAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _dotAnimation = IntTween(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _dotAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _dotAnimationController.repeat();
  }

  @override
  void dispose() {
    _dotAnimationController.dispose();
    super.dispose();
  }

  String _buildDots(int count) {
    return '.' * count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60.w,
          height: 0.8.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color:
                AppTheme.lightTheme.colorScheme.surface.withOpacity(0.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
          ),
        ),
        SizedBox(height: 3.h),
        AnimatedBuilder(
          animation: _dotAnimation,
          builder: (context, child) {
            return Text(
              '${widget.loadingText}${_buildDots(_dotAnimation.value)}',
              style: GoogleFonts.inter(
                fontSize: 3.5.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
        SizedBox(height: 1.h),
        Text(
          '${(widget.progress * 100).toInt()}%',
          style: GoogleFonts.inter(
            fontSize: 3.sp,
            fontWeight: FontWeight.w300,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}