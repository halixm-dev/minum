// lib/src/presentation/screens/stats/hydration_history_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/bottom_nav_provider.dart'; // Import BottomNavProvider
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:minum/main.dart';
import 'package:minum/src/data/repositories/local/local_hydration_repository.dart' show guestUserId;


enum HistoryViewType { weekly, monthly }

class HydrationHistoryScreen extends StatefulWidget {
  const HydrationHistoryScreen({super.key});

  @override
  State<HydrationHistoryScreen> createState() => _HydrationHistoryScreenState();
}

class _HydrationHistoryScreenState extends State<HydrationHistoryScreen> {
  HistoryViewType _selectedViewType = HistoryViewType.weekly;
  DateTimeRange? _selectedDateRange;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - DateTime.monday));

  List<HydrationEntry> _historyEntries = [];
  Map<DateTime, double> _dailyTotals = {};

  StreamSubscription<List<HydrationEntry>>? _historySubscription;
  bool _isLoadingHistory = false;
  String? _currentDataScopeId;

  late HydrationProvider _hydrationProviderInstance;

  @override
  void initState() {
    super.initState();
    logger.d("HydrationHistoryScreen: initState");

    _hydrationProviderInstance = Provider.of<HydrationProvider>(context, listen: false);
    _hydrationProviderInstance.addListener(_onHydrationProviderChanged);

    _updateSelectedDateRangeAndProcessData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupInitialDataScopeAndFetch();
    });
  }

  void _setupInitialDataScopeAndFetch() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final loggedInUserId = userProvider.userProfile?.id;

    if (loggedInUserId != null) {
      _currentDataScopeId = loggedInUserId;
    } else {
      _currentDataScopeId = guestUserId;
    }
    _fetchHistoryData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    final newScopeId = userProvider.userProfile?.id ?? guestUserId;

    if (newScopeId != _currentDataScopeId) {
      logger.d("HydrationHistoryScreen: Data scope changed from $_currentDataScopeId to $newScopeId. Re-fetching data.");
      _currentDataScopeId = newScopeId;
      _updateSelectedDateRangeAndProcessData();
      _fetchHistoryData();
    }
  }

  void _onHydrationProviderChanged() {
    if (!mounted) return;
    final providerStatus = _hydrationProviderInstance.actionStatus;
    if (providerStatus == HydrationActionStatus.success) {
      logger.d("HydrationHistoryScreen: HydrationProvider reported success. Re-fetching history if not already loading.");
      if (!_isLoadingHistory) {
        _fetchHistoryData();
      }
      _hydrationProviderInstance.resetActionStatus();
    }
  }

  void _updateSelectedDateRangeAndProcessData() {
    _updateSelectedDateRange();
    _processEntriesForSummaries();
  }

  void _updateSelectedDateRange() {
    switch (_selectedViewType) {
      case HistoryViewType.weekly:
        _selectedDateRange = DateTimeRange(
          start: DateTime(_selectedWeekStart.year, _selectedWeekStart.month, _selectedWeekStart.day),
          end: DateTime(_selectedWeekStart.year, _selectedWeekStart.month, _selectedWeekStart.day).add(const Duration(days: 6)),
        );
        break;
      case HistoryViewType.monthly:
        _selectedDateRange = DateTimeRange(
          start: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
          end: DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0),
        );
        break;
    }
    logger.i("History: Date range updated to: ${_selectedDateRange?.start.toIso8601String()} - ${_selectedDateRange?.end.toIso8601String()} for view $_selectedViewType");
  }

  void _fetchHistoryData() {
    _historySubscription?.cancel();
    final dataScopeIdForFetch = _currentDataScopeId;

    if (dataScopeIdForFetch == null || dataScopeIdForFetch.isEmpty || _selectedDateRange == null) {
      if (mounted) setState(() { _historyEntries = []; _isLoadingHistory = false; _processEntriesForSummaries(); });
      return;
    }

    if (mounted) setState(() { _isLoadingHistory = true; _historyEntries = []; _processEntriesForSummaries(); });

    _historySubscription = _hydrationProviderInstance
        .getEntriesForDateRangeStream(dataScopeIdForFetch, _selectedDateRange!.start, _selectedDateRange!.end)
        .listen((entries) {
      if (mounted) {
        setState(() {
          _historyEntries = entries;
          _processEntriesForSummaries();
          _isLoadingHistory = false;
        });
        logger.i("History: Fetched and processed ${entries.length} entries for scope $dataScopeIdForFetch.");
      }
    }, onError: (error, stackTrace) {
      logger.e("Error fetching history data: $error", error: error, stackTrace: stackTrace);
      if (mounted) {
        setState(() { _historyEntries = []; _isLoadingHistory = false; _processEntriesForSummaries(); });
        if (mounted) AppUtils.showSnackBar(context, "Failed to load history.", isError: true);
      }
    });
  }

  void _processEntriesForSummaries() {
    _dailyTotals = {};

    if (_selectedDateRange == null) return;

    for (var entry in _historyEntries) {
      final entryDay = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      _dailyTotals[entryDay] = (_dailyTotals[entryDay] ?? 0) + entry.amountMl;
    }
  }


  void _changeWeek(int direction) {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(Duration(days: 7 * direction));
      _updateSelectedDateRangeAndProcessData();
    });
    _fetchHistoryData();
  }

  void _changeMonth(int direction) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + direction, 1);
      _updateSelectedDateRangeAndProcessData();
    });
    _fetchHistoryData();
  }

  @override
  void dispose() {
    logger.d("HydrationHistoryScreen: dispose");
    _hydrationProviderInstance.removeListener(_onHydrationProviderChanged);
    _historySubscription?.cancel();
    super.dispose();
  }

  Widget _buildViewTypeSelector() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: SegmentedButton<HistoryViewType>(
        segments: const <ButtonSegment<HistoryViewType>>[
          ButtonSegment<HistoryViewType>(value: HistoryViewType.weekly, label: Text('Weekly'), icon: Icon(Icons.calendar_view_week_outlined)),
          ButtonSegment<HistoryViewType>(value: HistoryViewType.monthly, label: Text('Monthly'), icon: Icon(Icons.calendar_today_outlined)),
        ],
        selected: {_selectedViewType},
        onSelectionChanged: (Set<HistoryViewType> newSelection) {
          setState(() {
            _selectedViewType = newSelection.first;
            if (_selectedViewType == HistoryViewType.weekly) {
              _selectedWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - DateTime.monday));
            } else {
              _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
            }
            _updateSelectedDateRangeAndProcessData();
          });
          _fetchHistoryData();
        },
        // Style from SegmentedButtonThemeData in AppTheme
        // If overrides are needed:
        style: SegmentedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          selectedForegroundColor: theme.colorScheme.onSecondaryContainer, // M3 uses onSecondaryContainer for selected text on secondaryContainer fill
          selectedBackgroundColor: theme.colorScheme.secondaryContainer, // M3 uses secondaryContainer for selected segment
          foregroundColor: theme.colorScheme.onSurfaceVariant, // For unselected text/icon
          textStyle: theme.textTheme.labelLarge,
        ),
      ),
    );
  }

  Widget _buildDateNavigation() {
    final theme = Theme.of(context);
    String title = "";
    if (_selectedDateRange != null) {
      if (_selectedViewType == HistoryViewType.weekly) {
        title = "${DateFormat.MMMd().format(_selectedDateRange!.start)} - ${DateFormat.MMMd().format(_selectedDateRange!.end)}";
      } else if (_selectedViewType == HistoryViewType.monthly) {
        title = DateFormat.yMMMM().format(_selectedDateRange!.start);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, size: 28.sp, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () {
              if (_selectedViewType == HistoryViewType.weekly) _changeWeek(-1);
              if (_selectedViewType == HistoryViewType.monthly) _changeMonth(-1);
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface), // fontWeight removed
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 28.sp, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () {
              if (_selectedViewType == HistoryViewType.weekly) _changeWeek(1);
              if (_selectedViewType == HistoryViewType.monthly) _changeMonth(1);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.userProfile != null;
    final UserModel? currentUser = userProvider.userProfile;
    final preferredUnit = currentUser?.preferredUnit ?? MeasurementUnit.ml;

    return Scaffold( // Added Scaffold as this is a top-level screen in the IndexedStack
      body: Column(
        children: [
          _buildViewTypeSelector(),
          _buildDateNavigation(),
          if (!isLoggedIn && _historyEntries.isNotEmpty)
            _buildLoginToSyncPrompt(context, theme), // Pass theme
          Expanded(
            child: _isLoadingHistory && _historyEntries.isEmpty
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                : (_historyEntries.isEmpty && _currentDataScopeId != null)
                ? _buildEmptyState(isLoggedIn, theme)
                : _currentDataScopeId == null
                ? Center(child: Text("Initializing...", style: theme.textTheme.bodyLarge))
                : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildChartSection(preferredUnit, theme)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
                    child: Text(
                      _selectedViewType == HistoryViewType.weekly ? 'Daily Totals' : 'Weekly Totals',
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface), // fontWeight removed
                    ),
                  ),
                ),
                if (_selectedViewType == HistoryViewType.weekly)
                  _buildWeeklySummaryList(context, preferredUnit, theme)
                else if (_selectedViewType == HistoryViewType.monthly)
                  _buildMonthlySummaryList(context, preferredUnit, theme),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginToSyncPrompt(BuildContext context, ThemeData theme) { // Added theme parameter
    return Container(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5), // Use tertiaryContainer for info
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(Icons.sync_outlined, color: theme.colorScheme.onTertiaryContainer, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "You have local data. Log in to sync and backup your history!",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer),
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            // TextButton style will come from theme, ensuring primary color for text
            child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isLoggedIn, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_drinks_outlined, size: 64.sp, color: theme.colorScheme.onSurfaceVariant), // Adjusted size
            SizedBox(height: 20.h),
            Text(
              AppStrings.noDataAvailable,
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface), // Changed to headlineSmall
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              isLoggedIn
                  ? 'No hydration logs found for the selected period.'
                  : 'Log some water to see your history here. Log in to sync across devices!',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (!isLoggedIn) SizedBox(height: 24.h),
            if (!isLoggedIn)
              FilledButton( // Replaced CustomButton
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
                child: const Text("Login to Sync"),
                // style: FilledButton.styleFrom(minimumSize: Size(200.w, 48.h)), // If specific size needed
              )
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(MeasurementUnit unit, ThemeData theme) {
    if (_historyEntries.isEmpty && _selectedDateRange == null) return const SizedBox.shrink();

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    // ... (bar group generation logic remains the same)
    if (_selectedViewType == HistoryViewType.weekly && _selectedDateRange != null) {
      for (int i = 0; i < 7; i++) {
        final day = _selectedDateRange!.start.add(Duration(days: i));
        final totalForDay = _dailyTotals[day] ?? 0.0;
        if (totalForDay > maxY) maxY = totalForDay;
        barGroups.add(
          BarChartGroupData( x: i, barRods: [
              BarChartRodData(
                  toY: AppUtils.convertToPreferredUnit(totalForDay, unit),
                  color: theme.colorScheme.primary, 
                  width: 16.w,
                  borderRadius: BorderRadius.circular(4.r)
              )
            ],
          ),
        );
      }
    } else if (_selectedViewType == HistoryViewType.monthly && _selectedDateRange != null) {
      final List<DateTime> weekStartDays = [];
      DateTime currentDay = _selectedDateRange!.start;
      while(currentDay.isBefore(_selectedDateRange!.end) || currentDay.isAtSameMomentAs(_selectedDateRange!.end)) {
        if (currentDay.weekday == DateTime.monday || weekStartDays.isEmpty) weekStartDays.add(currentDay);
        currentDay = currentDay.add(const Duration(days:1));
      }
      if(weekStartDays.isEmpty && _historyEntries.isNotEmpty) weekStartDays.add(_selectedDateRange!.start);

      for (int i = 0; i < weekStartDays.length; i++) {
        double totalForWeek = 0;
        DateTime weekStart = weekStartDays[i];
        DateTime weekEnd = weekStart.add(const Duration(days: 6));
        if(weekEnd.isAfter(_selectedDateRange!.end)) weekEnd = _selectedDateRange!.end;

        _dailyTotals.forEach((day, total) {
          if (!day.isBefore(weekStart) && !day.isAfter(weekEnd)) totalForWeek += total;
        });
        if (totalForWeek > maxY) maxY = totalForWeek;
        barGroups.add( BarChartGroupData( x: i, barRods: [
              BarChartRodData(
                  toY: AppUtils.convertToPreferredUnit(totalForWeek, unit),
                  color: theme.colorScheme.primary,
                  width: 16.w,
                  borderRadius: BorderRadius.circular(4.r)
              )
            ],
          ),
        );
      }
    }


    if (barGroups.isEmpty) return Padding(padding: EdgeInsets.all(16.w), child: Text("Not enough data to plot for this period.", style: theme.textTheme.bodyMedium));
    maxY = (maxY == 0) ? (unit == MeasurementUnit.ml ? 2000 : 64) : AppUtils.convertToPreferredUnit(maxY, unit);
    maxY = (maxY * 1.2).ceilToDouble(); // Ensure maxY is at least a bit higher than max bar

    return AspectRatio(
      aspectRatio: 1.6, // Adjusted for better M3 feel
      child: Padding(
        padding: EdgeInsets.only(top: 24.h, bottom: 12.h, left: 8.w, right: 24.w),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (BarChartGroupData group) => theme.colorScheme.secondaryContainer, // M3 tooltip background
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String label;
                  if (_selectedViewType == HistoryViewType.weekly) {
                    label = DateFormat.E().format(_selectedDateRange!.start.add(Duration(days: group.x.toInt())));
                  } else {
                    label = 'Week ${group.x.toInt() + 1}';
                  }
                  final unitString = unit == MeasurementUnit.ml ? 'mL' : 'oz';
                  return BarTooltipItem(
                    '$label\n',
                    theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                        text: "${AppUtils.formatAmount(rod.toY, decimalDigits: 1)} $unitString",
                        style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSecondaryContainer),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48.w, // Adjusted for potentially larger numbers
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value == 0 || value == meta.max) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: meta,
                      space: 8.0,
                      child: Text(AppUtils.formatAmount(value, decimalDigits: 0), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    );
                  },
                  interval: (maxY / 4).ceilToDouble() > 0 ? (maxY / 4).ceilToDouble() : 1, // Adjusted interval
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32.h, // Changed from 30.h to 32.h
                  getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta, theme), // Pass theme
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY / 4).ceilToDouble() > 0 ? (maxY / 4).ceilToDouble() : 1, // Adjusted interval
              getDrawingHorizontalLine: (value) => FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), strokeWidth: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta, ThemeData theme) { // Added theme parameter
    String text = '';
    final TextStyle style = theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSurfaceVariant); // M3 style

    if (_selectedViewType == HistoryViewType.weekly && _selectedDateRange != null) {
      if (value.toInt() >=0 && value.toInt() < 7) {
        final day = _selectedDateRange!.start.add(Duration(days: value.toInt()));
        text = DateFormat.E().format(day).substring(0,1); // Single letter for days
      }
    } else if (_selectedViewType == HistoryViewType.monthly) {
      text = 'W${value.toInt() + 1}';
    }
    return SideTitleWidget(
      meta: meta,
      space: 4.0,
      child: Text(text, style: style),
    );
  }

  Widget _buildWeeklySummaryList(BuildContext context, MeasurementUnit unit, ThemeData theme) {
    if (_selectedDateRange == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    List<Widget> dayTiles = [];
    for (int i = 0; i < 7; i++) {
      final day = _selectedDateRange!.start.add(Duration(days: i));
      final totalForDay = _dailyTotals[day] ?? 0.0;
      final displayTotal = AppUtils.formatAmount(AppUtils.convertToPreferredUnit(totalForDay, unit), decimalDigits: unit == MeasurementUnit.oz ? 1 : 0);
      final unitString = unit == MeasurementUnit.ml ? "mL" : "oz";

      dayTiles.add(
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(DateFormat.E().format(day).substring(0,1), style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ),
            title: Text(DateFormat('EEEE, MMM d').format(day), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
            trailing: Text('$displayTotal $unitString', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            onTap: () {
              Provider.of<HydrationProvider>(context, listen: false).setSelectedDate(day);
              Provider.of<BottomNavProvider>(context, listen: false).setCurrentIndex(0);
              logger.i("Tapped on day ${DateFormat.yMd().format(day)}. Switched to Home tab and set date.");
            },
            dense: true, // M3 ListTiles can be denser
          )
      );
    }
    return SliverList(delegate: SliverChildListDelegate(dayTiles));
  }

  List<DateTimeRange> _getWeeksInMonth(DateTime monthStart, DateTime monthEnd) {
    List<DateTimeRange> weeks = [];
    DateTime currentWeekStart = monthStart;
    while(currentWeekStart.isBefore(monthEnd) || currentWeekStart.isAtSameMomentAs(monthEnd)){
      DateTime currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
      if(currentWeekEnd.isAfter(monthEnd)) currentWeekEnd = monthEnd;
      weeks.add(DateTimeRange(start: currentWeekStart, end: currentWeekEnd));
      currentWeekStart = DateTime(currentWeekEnd.year, currentWeekEnd.month, currentWeekEnd.day).add(const Duration(days:1));
      if(currentWeekStart.month != monthStart.month && currentWeekStart.isAfter(monthEnd)) break;
    }
    return weeks;
  }

  Widget _buildMonthlySummaryList(BuildContext context, MeasurementUnit unit, ThemeData theme) {
    if (_selectedDateRange == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final List<DateTimeRange> weeksInMonth = _getWeeksInMonth(_selectedDateRange!.start, _selectedDateRange!.end);
    List<Widget> weekTiles = [];

    for (int i=0; i < weeksInMonth.length; i++) {
      final weekRange = weeksInMonth[i];
      double totalForWeek = 0;
      _dailyTotals.forEach((day, total) {
        if (!day.isBefore(weekRange.start) && (day.isBefore(weekRange.end) || day.isAtSameMomentAs(weekRange.end))) {
          totalForWeek += total;
        }
      });

      final displayTotal = AppUtils.formatAmount(AppUtils.convertToPreferredUnit(totalForWeek, unit), decimalDigits: unit == MeasurementUnit.oz ? 1 : 0);
      final unitString = unit == MeasurementUnit.ml ? "mL" : "oz";
      final weekLabel = "Week ${i + 1} (${DateFormat.MMMd().format(weekRange.start)} - ${DateFormat.MMMd().format(weekRange.end)})";

      weekTiles.add(
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Text('W${i+1}', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
            ),
            title: Text(weekLabel, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
            trailing: Text('$displayTotal $unitString', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            onTap: () {
              setState(() {
                _selectedViewType = HistoryViewType.weekly;
                _selectedWeekStart = weekRange.start;
                _updateSelectedDateRangeAndProcessData();
              });
              _fetchHistoryData();
            },
            dense: true, // M3 ListTiles can be denser
          )
      );
    }
    return SliverList(delegate: SliverChildListDelegate(weekTiles));
  }

}
