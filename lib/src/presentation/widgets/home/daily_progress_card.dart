// lib/src/presentation/widgets/home/daily_progress_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/core/utils/app_utils.dart';

/// A card widget that displays the user's daily hydration progress.
class DailyProgressCard extends StatelessWidget {
  /// The amount of water consumed so far today, in milliliters.
  final double consumed;
  /// The user's daily hydration goal, in milliliters.
  final double goal;
  /// The measurement unit to display the values in.
  final MeasurementUnit unit;

  /// Creates a `DailyProgressCard`.
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
    final double progress = goal > 0 ? math.min(consumed / goal, 1.0) : 0.0;

    final double consumedInPreferredUnit =
        AppUtils.convertToPreferredUnit(consumed, unit);
    final double goalInPreferredUnit =
        AppUtils.convertToPreferredUnit(goal, unit);
    final double remainingInPreferredUnit =
        math.max(0, goalInPreferredUnit - consumedInPreferredUnit);

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your Daily Goal',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyLarge,
                      children: [
                        TextSpan(
                          text: AppUtils.formatAmount(consumedInPreferredUnit,
                              decimalDigits:
                                  unit == MeasurementUnit.oz ? 1 : 0),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' / ${AppUtils.formatAmount(goalInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (progress >= 1.0)
                  Icon(Symbols.check_circle_rounded,
                      color: theme.colorScheme.tertiary,
                      size: 28.sp) // Adjusted size
                else
                  Text(
                    '${AppUtils.formatAmount(remainingInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString left',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(4.r),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}% completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
