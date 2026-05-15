// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:minum/src/app.dart';
import 'package:minum/firebase_options.dart';
import 'package:minum/src/core/utils/logger.dart';

// Data Layer: Repositories
import 'package:minum/src/features/auth/data/repositories/auth_repository.dart';
import 'package:minum/src/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:minum/src/features/user/data/repositories/user_repository.dart';
import 'package:minum/src/features/user/data/datasources/firebase_user_data_source.dart';
import 'package:minum/src/features/hydration/data/repositories/hydration_repository.dart';
import 'package:minum/src/features/hydration/data/datasources/firebase_hydration_data_source.dart';
import 'package:minum/src/features/hydration/data/datasources/local_hydration_data_source.dart';
import 'package:minum/src/features/hydration/data/repositories/syncable_hydration_repository.dart';

// Service Layer
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/services/notification_service.dart';
import 'package:minum/src/services/hydration_service.dart';

import 'package:minum/src/services/health_service.dart';

import 'package:minum/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/presentation/providers/bottom_nav_provider.dart';
import 'package:minum/src/features/settings/presentation/bloc/reminder_settings_cubit.dart';
import 'package:minum/src/features/settings/presentation/bloc/next_reminder_cubit.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_history_cubit.dart';

/// The main entry point for the application.
///
/// This function initializes Firebase, sets up all the necessary services and
/// providers, and runs the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully");
  } catch (e) {
    logger.e("Firebase initialization failed: $e");
  }

  final notificationService = NotificationService();
  await notificationService.init();
  logger.i("NotificationService initialized");

  try {
    await notificationService.scheduleDailyRemindersIfNeeded();
    logger.i("Attempted to schedule daily reminders on startup.");
  } catch (e) {
    logger.e("Error calling scheduleDailyRemindersIfNeeded on startup: $e");
  }

  final UserRepository userRepository = FirebaseUserDataSource();
  final AuthRepository authRepository =
      FirebaseAuthDataSource(userRepository: userRepository);

  final LocalHydrationDataSource localHydrationRepository =
      LocalHydrationDataSource();
  final FirebaseHydrationDataSource firebaseHydrationRepository =
      FirebaseHydrationDataSource();

  final AuthService authService = AuthService(
    authRepository: authRepository,
    userRepository: userRepository,
  );

  final HydrationRepository syncableHydrationRepository =
      SyncableHydrationRepository(
    localRepository: localHydrationRepository,
    firebaseRepository: firebaseHydrationRepository,
    authService: authService,
  );

  final HealthService healthService = HealthService();

  final HydrationService hydrationService = HydrationService(
    hydrationRepository: syncableHydrationRepository,
    healthService: healthService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<HydrationService>.value(value: hydrationService),
        Provider<HealthService>.value(value: healthService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<UserRepository>.value(value: userRepository),
        Provider<HydrationRepository>.value(value: syncableHydrationRepository),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        BlocProvider(create: (_) => ReminderSettingsCubit()),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: context.read<AuthService>(),
          ),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            authService: context.read<AuthService>(),
            userRepository: context.read<UserRepository>(),
          ),
        ),
        BlocProvider<HydrationBloc>(
          create: (context) => HydrationBloc(
            authService: context.read<AuthService>(),
            hydrationService: context.read<HydrationService>(),
          ),
        ),
        BlocProvider<HydrationHistoryCubit>(
          create: (context) => HydrationHistoryCubit(
            hydrationService: context.read<HydrationService>(),
          ),
        ),
        BlocProvider<NextReminderCubit>(
          create: (context) => NextReminderCubit(
            notificationService: context.read<NotificationService>(),
          ),
        ),
      ],
      child: const MinumApp(),
    ),
  );
}
