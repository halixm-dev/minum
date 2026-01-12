// test/presentation/screens/home/main_hydration_view_test.dart
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:minum/src/presentation/screens/home/main_hydration_view.dart';
import 'package:minum/src/presentation/widgets/home/hydration_log_list_item.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/services/notification_service.dart';
import 'package:minum/src/presentation/providers/reminder_settings_notifier.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';

// Generate mocks (you might need to run build_runner if you were using it,
// but for now we can just extend/implement or use a simple mock class approach if build_runner isn't active)
// For simplicity in this environment, I'll create manual mocks.

class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override
  UserModel? get userProfile => UserModel(
    id: 'test_user',
    email: 'test@example.com',
    displayName: 'Test User',
    createdAt: DateTime.now(),
    dailyGoalMl: 2000,
    preferredUnit: MeasurementUnit.ml,
    favoriteIntakeVolumes: ['250', '500'],
  );

  @override
  UserProfileStatus get status => UserProfileStatus.loaded;

  @override
  String? get errorMessage => null;

  @override
  bool get isGuestUser => false;

  @override
  Future<void> fetchUserProfile(String uid) async {}

  @override
  Future<void> updateUserProfile(UserModel updatedProfile) async {}

  @override
  Future<void> updateDailyGoal(double newGoalMl) async {}

  @override
  Future<void> updatePreferredUnit(MeasurementUnit newUnit) async {}

  @override
  Future<void> updateFavoriteIntakeVolumes(List<String> newVolumes) async {}

  @override
  Future<void> updateDateOfBirth(DateTime? newDob) async {}

  @override
  Future<void> updateGender(Gender? newGender) async {}

  @override
  Future<void> updateHeight(double? newHeightCm) async {}

  @override
  Future<void> updateWeight(double? newWeightKg) async {}

  @override
  Future<void> updateActivityLevel(ActivityLevel? level) async {}

  @override
  Future<void> updateHealthConditions(
    List<HealthCondition> newConditions,
  ) async {}

  @override
  Future<void> updateSelectedWeather(WeatherCondition newWeather) async {}

  @override
  bool listEquals<T>(List<T>? a, List<T>? b) => true;

  @override
  void dispose() {
    super.dispose();
  }
}

class MockHydrationProvider extends ChangeNotifier
    implements HydrationProvider {
  @override
  DateTime get selectedDate => DateTime.now();

  @override
  double get totalIntakeToday => 500;

  @override
  List<HydrationEntry> get dailyEntries => [
    HydrationEntry(
      id: '1',
      userId: 'test_user',
      amountMl: 250,
      timestamp: DateTime.now(),
      source: 'test',
    ),
    HydrationEntry(
      id: '2',
      userId: 'test_user',
      amountMl: 250,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      source: 'test',
    ),
  ];

  @override
  HydrationLogStatus get logStatus => HydrationLogStatus.loaded;

  @override
  HydrationActionStatus get actionStatus => HydrationActionStatus.idle;

  @override
  String? get errorMessage => null;

  @override
  void setSelectedDate(DateTime date) {}

  @override
  Future<void> fetchHydrationEntriesForDate(DateTime date) async {}

  @override
  Future<void> addHydrationEntry(
    double amount, {
    DateTime? entryTime,
    String? notes,
    String? source,
  }) async {}

  @override
  Future<void> updateHydrationEntry(HydrationEntry entry) async {}

  @override
  Future<void> deleteHydrationEntry(HydrationEntry entry) async {}

  @override
  void resetActionStatus() {}

  @override
  Future<void> processPendingWaterAddition() async {}

  @override
  Stream<List<HydrationEntry>> getEntriesForDateRangeStream(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) => Stream.value([]);

  @override
  void dispose() {
    super.dispose();
  }
}

class MockNotificationService extends Mock implements NotificationService {
  @override
  Future<List<NotificationModel>> listScheduledNotifications() async => [];
}

class MockReminderSettingsNotifier extends ChangeNotifier
    implements ReminderSettingsNotifier {
  @override
  void notifySettingsChanged() {
    notifyListeners();
  }
}

class MockHydrationService extends Mock implements HydrationService {
  @override
  Future<void> syncHealthConnectData(String userId, {DateTime? date}) async {}
}

void main() {
  testWidgets('MainHydrationView renders correctly with CustomScrollView', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(
            create: (_) => MockUserProvider(),
          ),
          ChangeNotifierProvider<HydrationProvider>(
            create: (_) => MockHydrationProvider(),
          ),
          Provider<NotificationService>(
            create: (_) => MockNotificationService(),
          ),
          ChangeNotifierProvider<ReminderSettingsNotifier>(
            create: (_) => MockReminderSettingsNotifier(),
          ),
          Provider<HydrationService>(create: (_) => MockHydrationService()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) =>
              const MaterialApp(home: Scaffold(body: MainHydrationView())),
        ),
      ),
    );

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byKey(const Key('hydration_log_list')), findsOneWidget);
    expect(find.text('Today\'s Log'), findsOneWidget);
    expect(find.byType(HydrationLogListItem), findsNWidgets(2));
  });
}
