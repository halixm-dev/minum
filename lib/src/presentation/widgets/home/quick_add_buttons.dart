// lib/src/presentation/widgets/home/quick_add_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit
import 'package:minum/src/core/utils/app_utils.dart'; // For formatting amount

class QuickAddButtons extends StatelessWidget {
  final List<String>
      favoriteVolumes; // List of volumes in mL as strings e.g., ["250", "500"]
  final MeasurementUnit unit;
  final Function(double volumeMl) onQuickAdd;

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
      return const SizedBox
          .shrink(); // Don't show if no favorite volumes defined
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: 8.h, left: 4.w), // M3 typical spacing
          child: Text(
            'Quick Add',
            style: theme.textTheme.titleMedium, // fontWeight removed
          ),
        ),
        SizedBox(
          height: 48.h, // Adjusted height to better fit M3 chip sizing
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favoriteVolumes.length,
            padding: EdgeInsets.symmetric(
                horizontal: 4.w), // Padding for the list itself
            separatorBuilder: (context, index) =>
                SizedBox(width: 8.w), // M3 standard spacing
            itemBuilder: (context, index) {
              final volumeMlString = favoriteVolumes[index];
              final double volumeMl = double.tryParse(volumeMlString) ?? 0.0;
              if (volumeMl <= 0) return const SizedBox.shrink();

              final double displayVolume =
                  AppUtils.convertToPreferredUnit(volumeMl, unit);
              final String displayAmount = AppUtils.formatAmount(displayVolume,
                  decimalDigits: unit == MeasurementUnit.oz ? 1 : 0);

              // Using the global chipTheme as a base, which is M3 Assist Chip (Outlined)
              // To make these "Filled" ActionChips:
              // 1. Set backgroundColor to colorScheme.secondaryContainer (or another fill color)
              // 2. Set labelStyle color to colorScheme.onSecondaryContainer
              // 3. Set side to BorderSide.none
              // 4. Avatar icon color should also be colorScheme.onSecondaryContainer

              final chipTheme = theme.chipTheme;
              final filledChipStyle = chipTheme.copyWith(
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: chipTheme.labelStyle
                    ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                side: BorderSide.none, // Ensure no border for a filled look
                // Padding is part of chipTheme, use it or override if necessary
              );

              return ActionChip(
                avatar: Icon(
                  Icons.add_circle_outline,
                  size: chipTheme.iconTheme?.size ??
                      18.sp, // Use theme's icon size
                  color: theme.colorScheme
                      .onSecondaryContainer, // Explicitly for this filled style
                ),
                label: Text('$displayAmount $_unitString'),
                labelStyle: filledChipStyle.labelStyle,
                backgroundColor: filledChipStyle.backgroundColor,
                shape: filledChipStyle.shape, // This will be M3 default (8.r)
                side: filledChipStyle.side, // Should be BorderSide.none
                onPressed: () {
                  onQuickAdd(volumeMl);
                },
                elevation: 0, // M3 filled chips often have 0 elevation
                pressElevation:
                    0, // M3 filled chips often have 0 pressElevation
                padding: chipTheme.padding, // Use themed padding
              );
            },
          ),
        ),
      ],
    );
  }
}
