// lib/src/presentation/widgets/home/hydration_log_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart'; // For time formatting
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
    if (entry.source == null) return Symbols.water_drop;
    if (entry.source!.startsWith('quick_add')) return Symbols.bolt;
    if (entry.source!.contains('google_fit')) {
      return Symbols.fitness_center;
    }
    if (entry.source!.contains('health_connect')) {
      return Symbols.health_and_safety;
    }
    return Symbols.water_drop; // Default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double amountInPreferredUnit =
        AppUtils.convertToPreferredUnit(entry.amountMl, unit);

    return Dismissible(
      key: Key(entry.id ??
          DateTime.now().toIso8601String() + entry.amountMl.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDismissed?.call();
      },
      background: Container(
        color: theme.colorScheme.errorContainer, // M3 error container color
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.centerRight,
        child: Icon(Symbols.delete,
            color: theme.colorScheme.onErrorContainer,
            size: 28.sp), // Changed to filled
      ),
      child: ListTile(
        // M3 ListTile has default padding, consider removing explicit padding or ensure it aligns.
        // Default M3 padding is often: horizontal: 16.0, vertical: 8.0 (for one-line) or 4.0 (for two/three-line)
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 4.h), // Adjusted for typical two-line list item
        leading: CircleAvatar(
          backgroundColor:
              theme.colorScheme.primaryContainer, // M3 primary container
          child: Icon(_getSourceIcon(),
              color: theme.colorScheme.onPrimaryContainer,
              size: 24.sp), // M3 on primary container
        ),
        title: Text(
          '${AppUtils.formatAmount(amountInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString',
          style: theme
              .textTheme.titleMedium, // fontWeight removed, rely on M3 theme
        ),
        subtitle: entry.notes != null && entry.notes!.isNotEmpty
            ? Text(
                entry.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme
                        .colorScheme.onSurfaceVariant), // M3 onSurfaceVariant
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Text(
          DateFormat.jm().format(entry.timestamp),
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant), // M3 onSurfaceVariant
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
