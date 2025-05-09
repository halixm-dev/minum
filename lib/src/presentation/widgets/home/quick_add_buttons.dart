// lib/src/presentation/widgets/home/quick_add_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit
import 'package:minum/src/core/utils/app_utils.dart'; // For formatting amount

class QuickAddButtons extends StatelessWidget {
  final List<String> favoriteVolumes; // List of volumes in mL as strings e.g., ["250", "500"]
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
      return const SizedBox.shrink(); // Don't show if no favorite volumes defined
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.h, left: 4.w),
          child: Text(
            'Quick Add',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 50.h, // Fixed height for the horizontal list
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favoriteVolumes.length,
            separatorBuilder: (context, index) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final volumeMlString = favoriteVolumes[index];
              final double volumeMl = double.tryParse(volumeMlString) ?? 0.0;
              if (volumeMl <= 0) return const SizedBox.shrink(); // Skip invalid volumes

              final double displayVolume = AppUtils.convertToPreferredUnit(volumeMl, unit);
              final String displayAmount = AppUtils.formatAmount(displayVolume, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0);

              return ActionChip(
                avatar: Icon(Icons.add_circle_outline, size: 20.sp, color: AppColors.primaryColor),
                label: Text('$displayAmount $_unitString'),
                labelStyle: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
                backgroundColor: AppColors.primaryColor.withAlpha((255 * 0.1).round()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  side: BorderSide(color: AppColors.primaryColor.withAlpha((255 * 0.3).round()), width: 1.w),
                ),
                onPressed: () {
                  onQuickAdd(volumeMl);
                },
                elevation: 0,
                pressElevation: 1, // Slight press elevation
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              );
            },
          ),
        ),
      ],
    );
  }
}
