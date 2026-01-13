// lib/src/presentation/widgets/home/hydration_log_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/navigation/app_routes.dart';

/// A list tile widget that displays a single hydration entry.
///
/// This widget is dismissible to allow for swipe-to-delete functionality.
class HydrationLogListItem extends StatelessWidget {
  /// The hydration entry to display.
  final HydrationEntry entry;

  /// The measurement unit to display the volume in.
  final MeasurementUnit unit;

  /// A callback that is called when the item is dismissed.
  final VoidCallback? onDismissed;

  /// Creates a `HydrationLogListItem`.
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

  String _getSourceLabel() {
    if (entry.source == null) return "Manual Entry";
    if (entry.source!.startsWith('quick_add')) return "Quick Add";
    if (entry.source!.contains('google_fit')) {
      return "Google Fit";
    }
    if (entry.source!.contains('health_connect')) {
      return "Health Connect";
    }
    return "Manual Entry"; // Default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double amountInPreferredUnit =
        AppUtils.convertToPreferredUnit(entry.amountMl, unit);
    final sourceLabel = _getSourceLabel();

    return Dismissible(
      key: Key(entry.id ??
          DateTime.now().toIso8601String() + entry.amountMl.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDismissed?.call();
      },
      background: Container(
        color: theme.colorScheme.errorContainer,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.centerRight,
        child: Icon(Symbols.delete,
            color: theme.colorScheme.onErrorContainer, size: 28.sp),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Tooltip(
          message: sourceLabel,
          child: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              _getSourceIcon(),
              color: theme.colorScheme.onPrimaryContainer,
              size: 24.sp,
              semanticLabel: sourceLabel,
            ),
          ),
        ),
        title: Text(
          '${AppUtils.formatAmount(amountInPreferredUnit, decimalDigits: unit == MeasurementUnit.oz ? 1 : 0)} $_unitString',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: entry.notes != null && entry.notes!.isNotEmpty
            ? Text(
                entry.notes!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Text(
          TimeOfDay.fromDateTime(entry.timestamp).format(context),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
