// test/presentation/screens/home/add_water_log_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:minum/src/presentation/screens/home/add_water_log_screen.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';

// Reuse basic mocks for this test
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

  // Implement other required overrides with dummy implementations or throws/nulls
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHydrationProvider extends ChangeNotifier
    implements HydrationProvider {
  @override
  HydrationActionStatus get actionStatus => HydrationActionStatus.idle;

  @override
  String? get errorMessage => null;

  // Implement other required overrides
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('AddWaterLogScreen pumps successfully (verifying initState fix)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(
              create: (_) => MockUserProvider()),
          ChangeNotifierProvider<HydrationProvider>(
              create: (_) => MockHydrationProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: AddWaterLogScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AddWaterLogScreen), findsOneWidget);
    expect(find.text('Date & Time'),
        findsOneWidget); // Verifies date controller initialized
  });
}
