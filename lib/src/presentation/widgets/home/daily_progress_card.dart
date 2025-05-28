// lib/src/presentation/widgets/home/daily_progress_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final double consumedInPreferredUnit =
        AppUtils.convertToPreferredUnit(consumed, unit);
    final double goalInPreferredUnit =
        AppUtils.convertToPreferredUnit(goal, unit);
    // Ensure remaining is not negative
    final double remainingInPreferredUnit =
        math.max(0, goalInPreferredUnit - consumedInPreferredUnit);

    // Using Card.elevated() for an M3 elevated card appearance if desired,
    // or Card() for a filled card style. Theme default is filled.
    // The existing cardTheme in AppTheme is for M3 Filled Card (elevation 0, surfaceContainerLow).
    // To match original elevation:3, we'd use Card.elevated() and rely on its M3 default elevation (1.0) or theme.
    return Card(
      // This will use the default M3 filled card style from theme.
      // elevation: 1, // Explicitly set if you want the M3 elevated style and not relying on Card.elevated() or a specific theme variant
      // The shape will be picked from the global CardTheme.
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 16.h, horizontal: 16.w), // M3 uses 16dp padding often
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your Daily Goal',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                // fontWeight removed, rely on M3 definition for titleMedium
              ),
            ),
            SizedBox(
                height: 12.h), // Spacing can be adjusted (e.g. to 8.h or 16.h)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.baseline, // Better for text alignment
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style:
                          theme.textTheme.bodyLarge, // Base style for RichText
                      children: [
                        TextSpan(
                          text: AppUtils.formatAmount(consumedInPreferredUnit,
                              decimalDigits:
                                  unit == MeasurementUnit.oz ? 1 : 0),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            // fontWeight removed, rely on M3 definition
                          ),
                        ),
                        TextSpan(
                          text:
                              ' / ${AppUtils.formatAmount(goalInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString',
                          style: theme.textTheme.titleMedium?.copyWith(
                            // Changed from titleLarge to titleMedium for better hierarchy with displaySmall
                            color: theme.colorScheme.onSurfaceVariant,
                            // fontWeight removed
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w), // M3 standard spacing
                if (progress >= 1.0)
                  Icon(Icons.check_circle_rounded,
                      color: theme.colorScheme.tertiary,
                      size: 28.sp) // Adjusted size
                else
                  Text(
                    '${AppUtils.formatAmount(remainingInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString left',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Changed from bodyLarge for visual balance
                      color: theme.colorScheme.primary,
                      // fontWeight removed
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8.h, // Slightly reduced, M3 default is 4.0
              backgroundColor: theme.colorScheme
                  .surfaceContainerHighest, // M3 progress track color
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(4.r), // M3 uses rounded ends
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}% completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  // Changed from bodyMedium
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
