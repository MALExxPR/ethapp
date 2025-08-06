import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountEquityHeaderWidget extends StatefulWidget {
  final double currentBalance;
  final double percentageChange;
  final bool isUsdDenomination;
  final VoidCallback onToggleDenomination;

  const AccountEquityHeaderWidget({
    Key? key,
    required this.currentBalance,
    required this.percentageChange,
    required this.isUsdDenomination,
    required this.onToggleDenomination,
  }) : super(key: key);

  @override
  State<AccountEquityHeaderWidget> createState() =>
      _AccountEquityHeaderWidgetState();
}

class _AccountEquityHeaderWidgetState extends State<AccountEquityHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    final bool isPositive = widget.percentageChange >= 0;
    final Color changeColor = isPositive
        ? AppTheme.lightTheme.colorScheme.tertiary
        : AppTheme.lightTheme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patrimonio de la Cuenta',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              GestureDetector(
                onTap: widget.onToggleDenomination,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.onPrimary
                          .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isUsdDenomination ? 'USD' : 'ETH',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'swap_horiz',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            widget.isUsdDenomination
                ? '\$${widget.currentBalance.toStringAsFixed(2)}'
                : '${(widget.currentBalance / 2850.0).toStringAsFixed(6)} ETH',
            style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 32.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: isPositive ? 'trending_up' : 'trending_down',
                color: changeColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                '${isPositive ? '+' : ''}${widget.percentageChange.toStringAsFixed(2)}%',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'desde la última sesión',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
