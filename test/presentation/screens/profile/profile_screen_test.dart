import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/screens/profile/profile_screen.dart';
import 'package:minum/src/presentation/widgets/common/custom_text_field.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// --- Mock Classes ---
class MockUserProvider extends Mock implements UserProvider {
  UserModel? _userProfileFromSetter; // Store profile passed via setter
  UserProfileStatus _statusFromSetter = UserProfileStatus.idle; // Store status passed via setter

  // Mocking getters to use values from setters
  @override
  UserModel? get userProfile => _userProfileFromSetter;

  @override
  UserProfileStatus get status => _statusFromSetter;

  // Allow setting the profile for test scenarios
  void setProfile(UserModel? profile) {
    _userProfileFromSetter = profile;
    // notifyListeners(); // Important: Mockito's Mock doesn't have notifyListeners.
    // If the real UserProvider calls notifyListeners, the test setup needs to ensure
    // the widget rebuilds. Provider.value with a real ChangeNotifier or a more complex mock is an option.
    // For this test, we assume Consumer rebuilds when UserProvider instance (mock) changes its state values.
  }

  void setStatus(UserProfileStatus newStatus) {
    _statusFromSetter = newStatus;
    // notifyListeners();
  }
  
  // Mocking methods that might be called by the widget or its lifecycle.
  // For ProfileScreen, loadUserProfile might be called if not data is initially present.
  // updateUserProfile is called on save, not initial display.
  @override
  Future<void> loadUserProfile({bool forceRemote = false}) async {
    // Simulate a load. If a profile was set via setProfile, make it loaded.
    if (_userProfileFromSetter != null) {
      _statusFromSetter = UserProfileStatus.loaded;
    } else {
      _statusFromSetter = UserProfileStatus.error; // or .empty, depending on desired test outcome
    }
    // No notifyListeners() in basic Mock. Test relies on widget rebuilds from initial provider state.
  }

  @override
  Future<void> updateUserProfile(UserModel user, {bool isGuest = false}) async {
    _userProfileFromSetter = user; // Simulate update
    _statusFromSetter = UserProfileStatus.loaded;
  }

  // Mocking isLoading getter, default to false
  @override
  bool get isLoading => false;
  
  // Mocking errorMessage getter, default to null
  @override
  String? get errorMessage => null;

  // Add other methods from UserProvider if they are called and need specific mock behavior.
  // For this test, focusing on properties and loadUserProfile.
}


class MockHydrationService extends Mock implements HydrationService {}

class MockAuthService extends Mock implements AuthService {} // In case UserProvider needs it

// Simple stub for AppStrings if not accessible in test environment
// Ensure these match the actual strings used in ProfileScreen for finding widgets.
class AppStrings {
  static const String email = 'Email';
  static const String weight = 'Weight';
  static const String kg = 'kg';
  static const String activityLevel = 'Activity Level';
  static const String profile = 'Profile'; // For AppBar title
  // Add any other strings used in ProfileScreen labels or widget keys
}


void main() {
  late MockUserProvider mockUserProvider;
  late MockHydrationService mockHydrationService;
  // late MockAuthService mockAuthService; // Only if needed for UserProvider instantiation

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockHydrationService = MockHydrationService();
    // mockAuthService = MockAuthService();
  });

  final testDateOfBirth = DateTime(1990, 5, 15);
  final sampleUser = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    dailyGoalMl: 2500.0,
    gender: Gender.female,
    activityLevel: ActivityLevel.active,
    dateOfBirth: testDateOfBirth,
    healthConditions: const [HealthCondition.none],
    selectedWeatherCondition: WeatherCondition.hot,
    weightKg: 70.0,
    heightCm: 170.0,
    preferredUnit: MeasurementUnit.ml,
    createdAt: DateTime.now(),
    favoriteIntakeVolumes: const ['250', '500']
  );

  testWidgets('ProfileScreen displays user data correctly when UserProvider is loaded', (WidgetTester tester) async {
    // --- Setup Mocks ---
    // Configure the mock UserProvider
    mockUserProvider.setProfile(sampleUser); // Use the setter
    mockUserProvider.setStatus(UserProfileStatus.loaded); // Use the setter

    // --- Pump the Widget ---
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // IMPORTANT: For UserProvider which is a ChangeNotifier, if your mock
          // needs to simulate notifyListeners() behavior effectively for Consumer,
          // it should BE a ChangeNotifier. Mockito's Mock class does NOT automatically
          // handle listener notification.
          // A common approach is to use a real ChangeNotifier instance as a mock,
          // or use a package like `mocktail` which supports this better.
          // For this example, we rely on the initial state of the mock being correct
          // and `pumpAndSettle` to reflect that.
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          Provider<HydrationService>.value(value: mockHydrationService),
          // Provider<AuthService>.value(value: mockAuthService), // If UserProvider needs it
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812), // Standard design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return const MaterialApp(
              home: ProfileScreen(),
            );
          },
        ),
      ),
    );

    // pumpAndSettle() for all async operations and UI updates to complete.
    await tester.pumpAndSettle();

    // --- Verify Initial Values ---

    // Verify AppBar Title (as a basic check the screen is there)
    expect(find.text(AppStrings.profile), findsOneWidget);

    // Verify Display Name
    final displayNameField = tester.widget<CustomTextField>(find.byWidgetPredicate(
      (Widget widget) => widget is CustomTextField && widget.labelText == 'Display Name',
    ));
    expect(displayNameField.controller!.text, 'Test User');

    // Verify Email
    final emailField = tester.widget<CustomTextField>(find.byWidgetPredicate(
      (Widget widget) => widget is CustomTextField && widget.labelText == AppStrings.email,
    ));
    expect(emailField.controller!.text, 'test@example.com');
    
    // Verify Daily Goal
    final dailyGoalField = tester.widget<CustomTextField>(find.byWidgetPredicate(
      (Widget widget) => widget is CustomTextField && widget.labelText == 'Daily Goal (mL)', // Assumes mL
    ));
    expect(dailyGoalField.controller!.text, '2500');

    // Verify Height
    final heightField = tester.widget<CustomTextField>(find.byWidgetPredicate(
      (Widget widget) => widget is CustomTextField && widget.labelText == 'Height (cm)',
    ));
    expect(heightField.controller!.text, '170.0');

    // Verify Weight
    final weightField = tester.widget<CustomTextField>(find.byWidgetPredicate(
      (Widget widget) => widget is CustomTextField && widget.labelText == '${AppStrings.weight} (${AppStrings.kg})',
    ));
    expect(weightField.controller!.text, '70.0');

    // Verify Date of Birth
    // This relies on _buildDatePickerField rendering the date in yMMMd format.
    expect(find.text(DateFormat.yMMMd().format(testDateOfBirth)), findsOneWidget);
    
    // Verify Gender
    final genderDropdown = tester.widget<DropdownButtonFormField<Gender?>>(find.byWidgetPredicate(
      (Widget widget) => widget is DropdownButtonFormField<Gender?> && widget.decoration?.labelText == 'Gender',
    ));
    expect(genderDropdown.value, Gender.female);

    // Verify Activity Level
    final activityLevelDropdown = tester.widget<DropdownButtonFormField<ActivityLevel?>>(find.byWidgetPredicate(
      (Widget widget) => widget is DropdownButtonFormField<ActivityLevel?> && widget.decoration?.labelText == AppStrings.activityLevel,
    ));
    expect(activityLevelDropdown.value, ActivityLevel.active);
    
    // Verify Weather Condition
    final weatherDropdown = tester.widget<DropdownButtonFormField<WeatherCondition>>(find.byWidgetPredicate(
      (Widget widget) => widget is DropdownButtonFormField<WeatherCondition> && widget.decoration?.labelText == 'Typical Weather',
    ));
    expect(weatherDropdown.value, WeatherCondition.hot);

    // Verify Health Conditions (FilterChip)
    // Check that "None" chip is selected.
    // Need to ensure the text "None" uniquely identifies the chip's label.
    final noneChip = tester.widget<FilterChip>(find.ancestor(
        of: find.text('None'), // This is the label of the chip
        matching: find.byType(FilterChip),
    ));
    expect(noneChip.selected, isTrue);

    // Example: If "Pregnancy" was a condition and should be selected:
    // final pregnancyChip = tester.widget<FilterChip>(find.ancestor(of: find.text('Pregnancy'), matching: find.byType(FilterChip)));
    // expect(pregnancyChip.selected, isTrue);
  });
}

// Note on MockUserProvider:
// Using `extends Mock implements UserProvider` is standard for Mockito.
// However, for ChangeNotifiers, if `notifyListeners()` is crucial for the widget under test
// to react, the mock itself needs to be a ChangeNotifier or use a mocking framework
// that better supports this (like mocktail).
// In this test, we are setting the state *before* pumpWidget, so the initial build
// should reflect the mock's state. `pumpAndSettle` helps ensure this.
// If ProfileScreen were to call a method on UserProvider that then calls notifyListeners
// to trigger a rebuild *during* the test, this basic mock might not be sufficient.
// The current ProfileScreen structure calls _loadInitialProfileData from the build method
// if user != _lastProcessedUserProfile, which then populates controllers. This should work.
```

The previous version of the test file was nearly complete but had a few issues:

1.  **MockUserProvider and ChangeNotifier**: The `MockUserProvider` was using `extends Mock implements UserProvider`. While this is standard Mockito, `Mock` itself doesn't implement `ChangeNotifier`'s `notifyListeners()` mechanism. If `ProfileScreen` strictly relies on `notifyListeners` being called by the provider to rebuild (which `Consumer` widgets do), a simple mock might not trigger rebuilds correctly *after* the initial build.
    *   **Correction**: For this test, we are setting the state of the mock (`userProfile` and `status`) *before* `pumpWidget`. `ProfileScreen`'s `Consumer` will read this initial state. The `_loadInitialProfileData` method (which updates text controllers) is called within the `build` method itself based on conditions, so it should correctly populate the fields with the mock data on the first `pumpAndSettle`. The mock was adjusted to ensure its properties directly return what's set by `setProfile` and `setStatus`. No actual `notifyListeners` call is made by the pure `Mock` object.
2.  **Finding Widgets**: `find.widgetWithText(WidgetType, 'Text')` is a convenient finder, but it can be ambiguous if the text appears in multiple places or isn't a direct property of the widget being sought (e.g., label text in `InputDecoration`).
    *   **Correction**: Changed finders for `CustomTextField` and `DropdownButtonFormField` to use `find.byWidgetPredicate`. This allows for more precise matching based on widget properties like `labelText` for `CustomTextField` or `decoration.labelText` for `DropdownButtonFormField`. This is generally more robust.
3.  **AppStrings**: The stubbed `AppStrings` class was good. Added `AppStrings.profile` for the AppBar title check.
4.  **ScreenUtilInit**: Including `ScreenUtilInit` was correct and important.
5.  **Mock Methods**: The `MockUserProvider`'s mock methods (`loadUserProfile`, `updateUserProfile`) were refined to simply set the internal state, as they would in a real scenario affecting `userProfile` and `status`.

The refined version addresses these points for a more robust and accurate test.
The test file is now more robust in how it finds widgets and how the mock provider is set up for the initial state rendering.
I'll submit this corrected version.
