// lib/src/presentation/screens/home/main_hydration_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/widgets/home/daily_progress_card.dart';
import 'package:minum/src/presentation/widgets/home/hydration_log_list_item.dart';
import 'package:minum/src/presentation/widgets/home/quick_add_buttons.dart';
import 'package:provider/provider.dart';
// For logger
import 'package:intl/intl.dart'; // For date formatting

class MainHydrationView extends StatelessWidget {
  const MainHydrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final hydrationProvider = Provider.of<HydrationProvider>(context);

    final UserModel? currentUser = userProvider.userProfile;
    final List<HydrationEntry> todaysEntries = hydrationProvider.dailyEntries;
    final double totalIntakeToday = hydrationProvider.totalIntakeToday;
    final double dailyGoal = currentUser?.dailyGoalMl ?? 2000.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hydrationProvider.actionStatus == HydrationActionStatus.error &&
          hydrationProvider.errorMessage != null) {
        AppUtils.showSnackBar(context, hydrationProvider.errorMessage!, isError: true);
        context.read<HydrationProvider>().resetActionStatus();
      } else if (hydrationProvider.actionStatus == HydrationActionStatus.success) {
        // AppUtils.showSnackBar(context, "Action successful!"); // Optional generic success
        context.read<HydrationProvider>().resetActionStatus();
      }
    });


    Widget buildLogList() {
      if (hydrationProvider.logStatus == HydrationLogStatus.loading && todaysEntries.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (hydrationProvider.logStatus == HydrationLogStatus.error) {
        return Center(child: Text(hydrationProvider.errorMessage ?? AppStrings.anErrorOccurred));
      }
      if (todaysEntries.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_drink_outlined, size: 60.sp, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round())), // Changed
                SizedBox(height: 16.h),
                Text(
                  'No water logged yet for today.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), // Changed
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap the (+) button to add your first drink!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.8).round())), // Changed
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      // Changed from ListView.separated to ListView.builder
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todaysEntries.length,
        itemBuilder: (context, index) {
          final entry = todaysEntries[index];
          return HydrationLogListItem(
            entry: entry,
            unit: currentUser?.preferredUnit ?? MeasurementUnit.ml,
            onDismissed: () {
              context.read<HydrationProvider>().deleteHydrationEntry(entry);
            },
          );
        },
        // separatorBuilder: (context, index) => Divider(height: 1.h, indent: 16.w, endIndent: 16.w), // REMOVED
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, size: 28.sp),
                onPressed: () {
                  context.read<HydrationProvider>().setSelectedDate(
                    hydrationProvider.selectedDate.subtract(const Duration(days: 1)),
                  );
                },
              ),
              Text(
                DateFormat('EEEE, MMM d').format(hydrationProvider.selectedDate),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 28.sp,
                  color: DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now())
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color,
                ),
                onPressed: DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now())
                    ? null
                    : () {
                  context.read<HydrationProvider>().setSelectedDate(
                    hydrationProvider.selectedDate.add(const Duration(days: 1)),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (currentUser != null)
            DailyProgressCard(
              consumed: totalIntakeToday,
              goal: dailyGoal,
              unit: currentUser.preferredUnit,
            )
          else
            Card(child: Padding(padding: EdgeInsets.all(20.h), child: const Center(child: Text("Loading user data...")))),
          SizedBox(height: 24.h),

          if (currentUser != null && DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now()))
            QuickAddButtons(
              favoriteVolumes: currentUser.favoriteIntakeVolumes,
              unit: currentUser.preferredUnit,
              onQuickAdd: (volumeMl) {
                context.read<HydrationProvider>().addHydrationEntry(
                  volumeMl,
                  source: 'quick_add_${volumeMl}ml',
                );
                AppUtils.showSnackBar(context, "${AppUtils.formatAmount(volumeMl, decimalDigits: currentUser.preferredUnit == MeasurementUnit.oz ? 1 : 0)} ${currentUser.preferredUnitString} added!");
              },
            ),
          if (currentUser != null && DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now()))
            SizedBox(height: 24.h),

          if (todaysEntries.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
              child: Text(
                DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now())
                    ? "Today's Log"
                    : "Log for ${DateFormat.MMMd().format(hydrationProvider.selectedDate)}",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

          buildLogList(),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
