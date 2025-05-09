// lib/src/presentation/widgets/home/daily_progress_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit
import 'package:minum/src/core/utils/app_utils.dart'; // For formatting amount

class DailyProgressCard extends StatelessWidget {
  final double consumed;
  final double goal;
  final MeasurementUnit unit;

  const DailyProgressCard({
    super.key,
    required this.consumed,
    required this.goal,
    required this.unit,
  });

  String get _unitString => unit == MeasurementUnit.ml ? 'mL' : 'oz';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ensure goal is not zero to prevent division by zero, and cap progress at 100%
    final double progress = goal > 0 ? math.min(consumed / goal, 1.0) : 0.0;

    // Convert amounts to preferred unit for display
    final double consumedInPreferredUnit = AppUtils.convertToPreferredUnit(consumed, unit);
    final double goalInPreferredUnit = AppUtils.convertToPreferredUnit(goal, unit);
    // Ensure remaining is not negative
    final double remainingInPreferredUnit = math.max(0, goalInPreferredUnit - consumedInPreferredUnit);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your Daily Goal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withAlpha((255 * 0.8).round()),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end, // Align text baselines
              children: <Widget>[
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppUtils.formatAmount(consumedInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${AppUtils.formatAmount(goalInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                if (progress >= 1.0)
                  Icon(Icons.check_circle_rounded, color: AppColors.successColor, size: 30.sp)
                else
                  Text(
                    '${AppUtils.formatAmount(remainingInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString left',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10.h,
                backgroundColor: AppColors.primaryColor.withAlpha((255 * 0.2).round()),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}% completed',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
