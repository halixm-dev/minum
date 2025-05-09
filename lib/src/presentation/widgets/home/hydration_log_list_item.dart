// lib/src/presentation/widgets/home/hydration_log_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For time formatting
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit
import 'package:minum/src/core/utils/app_utils.dart'; // For formatting amount
import 'package:minum/src/navigation/app_routes.dart'; // For navigation

class HydrationLogListItem extends StatelessWidget {
  final HydrationEntry entry;
  final MeasurementUnit unit;
  final VoidCallback? onDismissed; // For swipe to delete

  const HydrationLogListItem({
    super.key,
    required this.entry,
    required this.unit,
    this.onDismissed,
  });

  String get _unitString => unit == MeasurementUnit.ml ? 'mL' : 'oz';

  IconData _getSourceIcon() {
    if (entry.source == null) return Icons.water_drop_outlined;
    if (entry.source!.startsWith('quick_add')) return Icons.bolt_outlined;
    if (entry.source!.contains('google_fit')) return Icons.fitness_center_outlined;
    if (entry.source!.contains('health_connect')) return Icons.health_and_safety_outlined;
    return Icons.water_drop_outlined; // Default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double amountInPreferredUnit = AppUtils.convertToPreferredUnit(entry.amountMl, unit);

    return Dismissible(
      key: Key(entry.id ?? DateTime.now().toIso8601String() + entry.amountMl.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDismissed?.call();
      },
      background: Container(
        color: AppColors.errorColor.withAlpha((255 * 0.8).round()),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_outline, color: Colors.white, size: 28.sp),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withAlpha((255 * 0.15).round()),
          child: Icon(_getSourceIcon(), color: AppColors.primaryColor, size: 24.sp),
        ),
        title: Text(
          '${AppUtils.formatAmount(amountInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: entry.notes != null && entry.notes!.isNotEmpty
            ? Text(
          entry.notes!,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round())),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
            : null,
        trailing: Text(
          DateFormat.jm().format(entry.timestamp),
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round())),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.addWaterLog,
            arguments: entry,
          );
        },
      ),
    );
  }
}
