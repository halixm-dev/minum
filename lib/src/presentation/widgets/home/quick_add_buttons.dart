// lib/src/presentation/widgets/home/quick_add_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/core/utils/app_utils.dart';

/// A widget that displays a horizontal list of buttons for quickly adding
/// a predefined volume of water.
class QuickAddButtons extends StatelessWidget {
  /// A list of favorite volumes in milliliters, as strings (e.g., ["250", "500"]).
  final List<String> favoriteVolumes;
  /// The measurement unit to display the volumes in.
  final MeasurementUnit unit;
  /// A callback that is called when a quick-add button is tapped. The volume
  /// passed to the callback is always in milliliters.
  final Function(double volumeMl) onQuickAdd;

  /// Creates a `QuickAddButtons` widget.
  const QuickAddButtons({
    super.key,
    required this.favoriteVolumes,
    required this.unit,
    required this.onQuickAdd,
  });

  String get _unitString => unit == MeasurementUnit.ml ? 'mL' : 'oz';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (favoriteVolumes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
          child: Text(
            'Quick Add',
            style: theme.textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 48.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favoriteVolumes.length,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final volumeMlString = favoriteVolumes[index];
              final double volumeMl = double.tryParse(volumeMlString) ?? 0.0;
              if (volumeMl <= 0) return const SizedBox.shrink();

              final double displayVolume =
                  AppUtils.convertToPreferredUnit(volumeMl, unit);
              final String displayAmount = AppUtils.formatAmount(displayVolume,
                  decimalDigits: unit == MeasurementUnit.oz ? 1 : 0);

              final chipTheme = theme.chipTheme;
              final filledChipStyle = chipTheme.copyWith(
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: chipTheme.labelStyle
                    ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                side: BorderSide.none,
              );

              return ActionChip(
                avatar: Icon(
                  Icons.add_circle_outline,
                  size: chipTheme.iconTheme?.size ?? 18.sp,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                label: Text('$displayAmount $_unitString'),
                labelStyle: filledChipStyle.labelStyle,
                backgroundColor: filledChipStyle.backgroundColor,
                shape: filledChipStyle.shape,
                side: filledChipStyle.side,
                onPressed: () {
                  onQuickAdd(volumeMl);
                },
                elevation: 0,
                pressElevation: 0,
                padding: chipTheme.padding,
              );
            },
          ),
        ),
      ],
    );
  }
}
