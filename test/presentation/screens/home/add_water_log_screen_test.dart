// test/presentation/screens/home/add_water_log_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minum/src/features/hydration/presentation/pages/home/add_water_log_screen.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_event.dart';
import 'package:minum/src/features/user/presentation/bloc/user_state.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_bloc.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_event.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_state.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/features/user/data/repositories/user_repository.dart';
import 'package:minum/src/services/hydration_service.dart';

// Reuse basic mocks for this test
class MockUserBloc extends Bloc<UserEvent, UserState> implements UserBloc {
  @override
  late final AuthService authService;
  
  @override
  late final UserRepository userRepository;

  MockUserBloc() : super(UserLoaded(
    user: UserModel(
      id: 'test_user',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
      dailyGoalMl: 2000,
      preferredUnit: MeasurementUnit.ml,
      favoriteIntakeVolumes: const ['250', '500'],
    ),
    isGuest: false,
  )) {
    on<UserEvent>((event, emit) {});
  }
}

class MockHydrationBloc extends Bloc<HydrationEvent, HydrationState> implements HydrationBloc {
  @override
  late final AuthService authService;
  
  @override
  late final HydrationService hydrationService;

  MockHydrationBloc() : super(HydrationState(selectedDate: DateTime.now())) {
    on<HydrationEvent>((event, emit) {});
  }
}

void main() {
  testWidgets('AddWaterLogScreen pumps successfully (verifying initState fix)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          BlocProvider<UserBloc>(
              create: (_) => MockUserBloc()),
          BlocProvider<HydrationBloc>(
              create: (_) => MockHydrationBloc()),
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
